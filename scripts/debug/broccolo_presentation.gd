extends Node

signal intro_ready
signal combat_ready
signal stage_changed(stage: String)

const DISCOURSE_PATH := "res://assets/models/enemies/broccolo/discorso_broccolo.mp3"
const TALKS: Array[StringName] = [&"mie/talk1", &"mie/talk2", &"mie/talk4"]
const DANCES: Array[StringName] = [&"mie/dancing3", &"mie/dancing2", &"mie/dancing"]
var studio: Node
var stage := ""
var elapsed := 0.0
var walk_cycles := 0
var talk_index := 0
var dance_index := 0
var voice_finished := false
var discourse: AudioStreamMP3
var history: Array[Dictionary] = []
var walk_distance := 0.0
var walk_origin := Vector3.ZERO
var music_fade: Tween
var music_fade_paused := false

func _ready() -> void:
	process_priority=25
	discourse=AudioStreamMP3.new()
	discourse.data=FileAccess.get_file_as_bytes(DISCOURSE_PATH)
	studio.voice.finished.connect(_voice_finished)

func stop() -> void:
	if music_fade!=null:music_fade.kill()
	stage=""
	elapsed=0
	stage_changed.emit(stage)

func active() -> bool:
	return not stage.is_empty()

func stationary() -> bool:
	return stage in ["answer", "phone", "phone_idle", "dialogue", "intro_ready", "dance_tail", "shrinking", "combat_ready"]

func start_phone() -> void:
	studio.reset_preview()
	history.clear()
	voice_finished=false
	walk_cycles=0
	walk_distance=0
	studio.closeup=false
	studio.travel=true
	studio.voice.stream=studio.voice_stream
	_set_stage("answer")
	_play(&"mie/phone_answer_talk")

func start_discourse() -> void:
	studio.reset_preview()
	history.clear()
	voice_finished=false
	talk_index=0
	dance_index=0
	studio.closeup=false
	studio.travel=true
	studio.voice.stream=discourse
	_set_stage("dialogue")
	_play(TALKS[0])
	_start_voice()
	studio.music.volume_db=-16.0
	studio.music.stream_paused=false
	studio.music.play()

func _start_voice() -> void:
	studio.voice.stream_paused=false
	studio.component.bind_voice(studio.voice)
	studio.voice.play()

func _voice_finished() -> void:
	voice_finished=true
	studio.component.bind_voice(null)
	if stage=="dance_tail":_begin_shrink()

func _set_stage(next:String) -> void:
	stage=next
	elapsed=0
	history.append({"stage":stage,"voice_seconds":studio.voice.get_playback_position(),"position":studio.actor.position})
	print("BROCCOLO_PRESENTATION ",stage," voice_seconds=",studio.voice.get_playback_position())
	stage_changed.emit(stage)

func _play(name:StringName) -> void:
	# Capture the position before restarting the next root curve. The mixer
	# advances normally, retaining the outgoing pose during the crossfade.
	studio.clip_prefix=studio.actor.position
	var same:bool=studio.animation.assigned_animation==name
	studio.animation.play(name,studio.presentation_blend_seconds)
	if same:studio.animation.seek(0,false)
	studio.selector.select(studio.clip_names.find(name))
	studio.timeline.max_value=studio.animation.get_animation(name).length

func _begin_throw() -> void:
	studio.voice.stream_paused=true
	_set_stage("throw")
	_play(&"mie/trow2")

func _begin_walk() -> void:
	studio.voice.stream_paused=false
	walk_origin=studio.actor.position
	_set_stage("walk")
	_play(&"mie/walking")

func _begin_dance() -> void:
	dance_index=0
	_set_stage("dance")
	_play(DANCES[0])

func _begin_shrink() -> void:
	_set_stage("shrinking")
	_play(&"mie/idle")
	studio.shrink_preview()
	music_fade=create_tween()
	music_fade_paused=false
	music_fade.tween_property(studio.music,"volume_db",-60.0,1.0)
	music_fade.tween_callback(studio.music.stop)
	music_fade.finished.connect(func():music_fade=null)

func _process(delta:float) -> void:
	if music_fade!=null and music_fade.is_valid() and studio.preview_paused!=music_fade_paused:
		if studio.preview_paused:music_fade.pause()
		else:music_fade.play()
		music_fade_paused=studio.preview_paused
	if not active() or studio.preview_paused:return
	elapsed+=delta
	match stage:
		"answer":
			if elapsed>=studio.phone_answer_seconds:
				_set_stage("phone")
				_start_voice()
		"phone":
			if studio.voice.get_playback_position()>=studio.phone_throw_seconds:_begin_throw()
		"throw":
			if not studio.animation.is_playing():_begin_walk()
		"walk":
			if not studio.animation.is_playing():
				walk_cycles+=1
				if walk_cycles<studio.phone_walk_cycles:_play(&"mie/walking")
				else:
					walk_distance=studio.actor.position.distance_to(walk_origin)
					_set_stage("phone_idle")
					_play(&"mie/idle")
		"phone_idle":
			if voice_finished:
				_set_stage("intro_ready")
				intro_ready.emit()
		"dialogue":
			if studio.voice.get_playback_position()>=studio.discourse_dance_seconds:
				_begin_dance()
			elif not studio.animation.is_playing():
				talk_index=(talk_index+1)%TALKS.size()
				_play(TALKS[talk_index])
		"dance":
			if not studio.animation.is_playing():
				dance_index+=1
				if dance_index<DANCES.size():_play(DANCES[dance_index])
				elif voice_finished:_begin_shrink()
				else:
					_set_stage("dance_tail")
					_play(&"mie/idle")
		"shrinking":
			if studio.shrink_tween!=null and not studio.shrink_tween.is_running():
				_set_stage("combat_ready")
				combat_ready.emit()
		"intro_ready", "combat_ready", "dance_tail":
			if not studio.animation.is_playing():_play(&"mie/idle")

func description() -> String:
	var names:Dictionary={"answer":"Risponde al telefono", "phone":"Telefonata", "throw":"Lancio telefono · audio in attesa", "walk":"Camminata", "phone_idle":"Fine telefonata", "intro_ready":"Intro conclusa · prova il secondo discorso", "dialogue":"Discorso con gesti", "dance":"Danza 3 → 2 → 1", "dance_tail":"Fine discorso", "shrinking":"Riduzione a 20 cm", "combat_ready":"Pronto per la battaglia (fase successiva)"}
	return String(names.get(stage,""))
