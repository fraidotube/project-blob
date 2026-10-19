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
@export_group("Boss fight")
## Carica sonora riprodotta mentre il corpo principale si rimpicciolisce.
@export var shrink_aura_stream: AudioStream
## Voce del principale all'avvio della trasformazione.
@export var shrink_voice_stream: AudioStream
## Lampo sonoro breve che accompagna l'emissione di ogni copia.
@export var duplicate_aura_stream: AudioStream
## Varianti pop delle copie; vengono alternate evitando ripetizioni consecutive.
@export var duplicate_pop_streams: Array[AudioStream] = []
## Suoni associati nell'ordine alle clip throw, trow2 e trow_grenade.
@export var sphere_launch_streams: Array[AudioStream] = []
## Impatto della sfera quando causa danno al giocatore.
@export var sphere_impact_stream: AudioStream
@export_group("Tagli audio boss")
## Secondo iniziale da saltare nella carica aura; rimuove il silenzio registrato.
@export_range(0.0, 5.0, 0.01) var shrink_aura_start_offset := 1.08
## Durata utile della carica durante la trasformazione.
@export_range(0.05, 5.0, 0.05) var shrink_aura_play_seconds := 1.8
## Secondo iniziale da saltare nella battuta di trasformazione.
@export_range(0.0, 1.0, 0.01) var shrink_voice_start_offset := 0.13
## Durata massima della battuta, esclusa la lunga coda muta.
@export_range(0.05, 5.0, 0.05) var shrink_voice_play_seconds := 1.9
## Inizio del frammento utile della carica aura alla duplicazione.
@export_range(0.0, 5.0, 0.01) var duplicate_aura_start_offset := 1.08
## Durata breve della carica aura alla duplicazione.
@export_range(0.05, 2.0, 0.05) var duplicate_aura_play_seconds := 0.55
## Silenzio iniziale da saltare nei pop, nello stesso ordine delle varianti.
@export var duplicate_pop_start_offsets := PackedFloat32Array([0.18, 0.145])
## Durata dei pop prima della coda muta, nello stesso ordine delle varianti.
@export var duplicate_pop_play_seconds := PackedFloat32Array([0.17, 0.14])
## Silenzio iniziale da saltare nei suoni di lancio, nello stesso ordine delle clip.
@export var sphere_launch_start_offsets := PackedFloat32Array([0.03, 0.04, 0.03])
## Durata utile dei suoni di lancio; tronca la coda muta dei file originali.
@export var sphere_launch_play_seconds := PackedFloat32Array([0.88, 0.92, 0.92])
## Silenzio iniziale da saltare nel suono d'impatto.
@export_range(0.0, 1.0, 0.01) var sphere_impact_start_offset := 0.06
## Durata utile dell'impatto, prima del silenzio finale.
@export_range(0.05, 5.0, 0.05) var sphere_impact_play_seconds := 2.2
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
var last_pop := -1
var voice_cutoff: Timer

func _ready() -> void:
	voice = _player("Voice", voice_volume_db, 18)
	footsteps = _player("Footsteps", step_volume_db, step_hearing_distance)
	footsteps.unit_size = step_unit_size
	footsteps.max_polyphony = 3
	footsteps.stream = footstep_stream
	effect = _player("Action", effect_volume_db, 14)
	last_position = get_parent().global_position
	get_parent().get_node("MouthPresentation").bind_voice(voice)
	voice_cutoff = Timer.new()
	voice_cutoff.name = "VoiceCueCutoff"
	voice_cutoff.one_shot = true
	add_child(voice_cutoff)
	voice_cutoff.timeout.connect(voice.stop)

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

func play_one_shot(stream: AudioStream, start_offset: float, duration: float, use_override_position := false, override_position := Vector3.ZERO) -> void:
	if stream == null or not is_inside_tree():return
	var world := get_tree().current_scene
	if world == null:return
	var player := AudioStreamPlayer3D.new()
	player.name = "BroccoloOneShot"
	player.bus = &"SFX"
	player.volume_db = effect_volume_db
	player.max_distance = step_hearing_distance
	player.unit_size = step_unit_size
	player.stream = stream
	world.add_child(player)
	player.global_position = override_position if use_override_position else get_parent().global_position
	player.finished.connect(player.queue_free)
	var start := clampf(start_offset, 0.0, maxf(stream.get_length() - 0.02, 0.0))
	player.play(start)
	var cutoff := duration if duration > 0.0 else stream.get_length() - start
	if cutoff > 0.0:
		get_tree().create_timer(cutoff, false).timeout.connect(func():
			if is_instance_valid(player):
				player.stop()
				player.queue_free()
		)

func play_shrink_cue() -> void:
	play_one_shot(shrink_aura_stream, shrink_aura_start_offset, shrink_aura_play_seconds)
	if shrink_voice_stream == null:return
	voice.stop()
	voice.stream = shrink_voice_stream
	voice.volume_db = voice_volume_db
	voice.pitch_scale = 1.0
	voice.play(shrink_voice_start_offset)
	voice_cutoff.start(shrink_voice_play_seconds)

func play_duplicate_cues() -> void:
	play_one_shot(duplicate_aura_stream, duplicate_aura_start_offset, duplicate_aura_play_seconds)
	if duplicate_pop_streams.is_empty():return
	var index := randi_range(0, duplicate_pop_streams.size() - 1)
	if index == last_pop and duplicate_pop_streams.size() > 1:index = (index + 1) % duplicate_pop_streams.size()
	last_pop = index
	var start := duplicate_pop_start_offsets[index] if index < duplicate_pop_start_offsets.size() else 0.0
	var duration := duplicate_pop_play_seconds[index] if index < duplicate_pop_play_seconds.size() else 0.0
	play_one_shot(duplicate_pop_streams[index], start, duration)

func play_sphere_launch(clip: StringName) -> void:
	var index := [&"mie/throw", &"mie/trow2", &"mie/trow_grenade"].find(clip)
	if index < 0 or index >= sphere_launch_streams.size():return
	var start := sphere_launch_start_offsets[index] if index < sphere_launch_start_offsets.size() else 0.0
	var duration := sphere_launch_play_seconds[index] if index < sphere_launch_play_seconds.size() else 0.0
	play_one_shot(sphere_launch_streams[index], start, duration)

func set_paused(paused: bool) -> void:
	voice.stream_paused = paused
	footsteps.stream_paused = paused
	effect.stream_paused = paused

func stop_voice() -> void:
	voice.stop()
	voice_cutoff.stop()
	var mouth = get_parent().get_node("MouthPresentation")
	if is_instance_valid(mouth.motion): mouth.motion.reset_mouth()
