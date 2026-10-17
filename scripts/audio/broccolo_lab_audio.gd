extends Node3D
## Audio 3D locale del laboratorio, senza alterare sorgenti o mix condiviso.
@export_group("Stream")
## Esclamazioni del principale, selezione casuale senza ripetizione consecutiva.
@export var exclamations: Array[AudioStream] = []
## Varianti mostro per le copie.
@export var copy_exclamations: Array[AudioStream] = []
## Passi originali del giocatore, riprodotti piu acuti solo qui.
@export var footstep_stream: AudioStream
## Salto e atterraggio del player riutilizzati.
@export var jump_stream: AudioStream
## Contatto col suolo dopo un salto, riprodotto una volta all'atterraggio.
@export var landing_stream: AudioStream
## Impatto fisico condiviso con gli altri boss.
@export var hit_stream: AudioStream
## Reazioni mostro ai colpi subiti, selezionate senza ripetizione consecutiva.
@export var hurt_streams: Array[AudioStream] = []
## Secondi iniziali da saltare per ciascuna reazione, nello stesso ordine degli stream.
@export var hurt_start_offsets := PackedFloat32Array()
@export_group("Mix e cadenza")
## Pitch dei piccoli passi;1 e' l'originale.
@export_range(0.5, 2.5, 0.05) var step_pitch := 1.7
## Volume passi in dB, prima dell'attenuazione spaziale.
@export_range(-40.0, 0.0, 1.0) var step_volume_db := -4.0
## Distanza di riferimento per l'attenuazione dei passi, metri.
@export_range(1.0, 12.0, 0.5) var step_unit_size := 6.0
## Distanza massima udibile dei passi, metri.
@export_range(4.0, 30.0, 1.0) var step_hearing_distance := 16.0
## Volume esclamazioni in dB.
@export_range(-30.0, 6.0, 1.0) var voice_volume_db := -3.0
## Guadagno delle reazioni registrate a basso livello, dB; pitch mostro originale.
@export_range(-20.0, 18.0, 1.0) var hurt_volume_db := 8.0
## Volume colpi/salti in dB.
@export_range(-30.0, 0.0, 1.0) var effect_volume_db := -8.0
## Distanza percorsa fra piccoli passi, metri.
@export_range(0.05, 0.5, 0.01) var step_stride := 0.2
## Intervallo minimo fra passi, secondi.
@export_range(0.05, 0.4, 0.01) var minimum_step_interval := 0.12
var voice: AudioStreamPlayer3D
var footsteps: AudioStreamPlayer3D
var effect: AudioStreamPlayer3D
var last_position := Vector3.ZERO
var travel := 0.0
var step_wait := 0.0
var last_voice := -1
var last_hurt := -1
var hurts_played := 0
var steps_played := 0
var impacts_played := 0

func _ready() -> void:
	voice = _player("Voice", voice_volume_db, 18)
	footsteps = _player("Footsteps", step_volume_db, step_hearing_distance)
	footsteps.unit_size = step_unit_size
	footsteps.max_polyphony = 3
	footsteps.stream = footstep_stream
	effect = _player("Action", effect_volume_db, 14)
	last_position = get_parent().global_position
	get_parent().get_node("MouthPresentation").bind_voice(voice)

func _player(title: String, volume: float, distance: float) -> AudioStreamPlayer3D:
	var sound := AudioStreamPlayer3D.new()
	sound.name = title
	sound.bus = &"SFX"
	sound.volume_db = volume
	sound.max_distance = distance
	sound.unit_size = 3
	add_child(sound)
	return sound

func tick(delta: float) -> void:
	var actor = get_parent()
	var position: Vector3 = actor.global_position
	var motion := position - last_position
	last_position = position
	motion.y = 0
	step_wait = maxf(0, step_wait - delta)
	if not actor.is_on_floor() or actor.state in ["preview", "dead", "shrink", "hurt", "attack", "throw"]:
		travel = 0
		return
	travel += minf(motion.length(), 0.2)
	if travel >= step_stride and step_wait <= 0 and footstep_stream != null:
		travel = 0
		step_wait = minimum_step_interval
		footsteps.pitch_scale = step_pitch * randf_range(0.94, 1.06)
		footsteps.play()
		steps_played += 1

func exclaim() -> bool:
	if voice.playing: return false
	var streams: Array[AudioStream] = exclamations if get_parent().principal else copy_exclamations
	if streams.is_empty(): return false
	var index := randi_range(0, streams.size() - 1)
	if index == last_voice and streams.size() > 1: index = (index + 1) % streams.size()
	last_voice = index
	voice.stream = streams[index]
	voice.volume_db = voice_volume_db
	voice.pitch_scale = 1.0
	voice.play()
	return true

func action(kind: String) -> void:
	if kind == "hurt":
		if hurt_streams.is_empty(): return
		var index := randi_range(0, hurt_streams.size() - 1)
		if index == last_hurt and hurt_streams.size() > 1: index = (index + 1) % hurt_streams.size()
		last_hurt = index
		voice.stop()
		voice.stream = hurt_streams[index]
		voice.volume_db = hurt_volume_db
		voice.pitch_scale = 1.0
		var offset := hurt_start_offsets[index] if index < hurt_start_offsets.size() else 0.0
		voice.play(clampf(offset, 0, maxf(0, voice.stream.get_length() - 0.05)))
		hurts_played += 1
		return
	var stream := hit_stream
	if kind == "jump": stream = jump_stream
	elif kind == "land": stream = landing_stream
	if stream == null: return
	effect.stream = stream
	effect.pitch_scale = step_pitch if kind in ["jump", "land"] else 1.25
	effect.play()
	if kind == "hit": impacts_played += 1

func set_paused(paused: bool) -> void:
	voice.stream_paused = paused
	footsteps.stream_paused = paused
	effect.stream_paused = paused

func stop_voice() -> void:
	voice.stop()
	var mouth = get_parent().get_node("MouthPresentation")
	if is_instance_valid(mouth.motion): mouth.motion.reset_mouth()
