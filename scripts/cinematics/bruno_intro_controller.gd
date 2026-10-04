extends Node

@export_category("References")
@export var bruno: Node
@export var point_1: Marker3D
@export var player: CharacterBody3D
@export var camera_tv_point: Marker3D
@export var camera_reveal_point: Marker3D
@export var camera_stand_point: Marker3D
@export var cinematic_lights: Array[Light3D] = []
@export var tv_music_audio: AudioStreamPlayer3D

@export_category("Camera / Video Timeline")
@export var video_lead_before_camera: float = 0.75
@export var camera_move_to_tv_time: float = 11.00
@export var flicker_start_time: float = 12.00
@export var blackout_time: float = 17.00
@export var reveal_time: float = 18.00
@export var camera_move_to_reveal_time: float = 1.80
@export var camera_move_to_stand_time: float = 3.00
@export var camera_smooth_transition: Tween.TransitionType = Tween.TRANS_CUBIC
@export var camera_smooth_ease: Tween.EaseType = Tween.EASE_IN_OUT

@export_category("Flicker")
@export var flicker_min_interval: float = 0.06
@export var flicker_max_interval: float = 0.22
@export_range(0.0, 1.0, 0.01) var flicker_off_chance: float = 0.42

@export_category("Purple Reveal")
@export var reveal_light_color: Color = Color("9a36ff")
@export_range(0.0, 3.0, 0.05) var reveal_energy_multiplier: float = 0.75

@export_category("Dialogue Audio")
@export var dialogue_audio: AudioStream
@export_range(-40.0, 12.0, 0.5) var dialogue_volume_db: float = 3.0
@export var dialogue_bus: StringName = &"Master"
@export_range(-60.0, 6.0, 0.5) var tv_dialogue_volume_db: float = -28.0
@export_range(0.0, 3.0, 0.05) var tv_duck_time: float = 0.65

@export_category("Dialogue Animation Timeline")
@export var sitting_clap_animation: StringName = &"mie/sitting_clap1"
@export var sitting_talk_animation: StringName = &"mie/sitting_talk"
@export var sitting_laugh_animation: StringName = &"mie/sitting_laughing"
@export var sitting_pose_time: float = 0.0

# Timeline relativa all'inizio di dialogoBruno.mp3.
# Prima prova: curiamo soprattutto l'apertura seduta.
@export var initial_clap_playback_speed: float = 1.00
@export var first_sitting_laugh_time: float = 19.50
@export var stand_start_time: float = 23.00
@export var walk_start_time: float = 26.00
@export var standing_talk_start_time: float = 28.00
@export var standing_talk_first_end_time: float = 56.00
@export var first_laugh_time: float = 57.00
@export var angry_talk_start_time: float = 70.00
@export var angry_talk_end_time: float = 82.00

@export var stand_animation: StringName = &"mie/sit_to_to stand"
@export var standing_idle_animation: StringName = &"mie/idle"
@export var walk_animation: StringName = &"mie/walking"

@export_category("Standing Dialogue Animations")
@export var talk_hands_open_animation: StringName = &"mie/talking1"
@export var talk_right_hand_animation: StringName = &"mie/talking2"
@export var talk_passionately_animation: StringName = &"mie/talking_mano_dx"
@export var talk_left_animation: StringName = &"mie/talking_sfida"
@export var extra_idle_1_animation: StringName = &"mie/idle"
@export var extra_idle_2_animation: StringName = &"mie/breathing_idle"
@export var laugh_animation: StringName = &""
@export var angry_talk_animation: StringName = &"mie/talking_angry"

@export_range(0.05, 2.0, 0.05) var standing_anim_blend_time: float = 0.20
@export_range(0.05, 2.0, 0.05) var face_camera_turn_time: float = 0.45

@export_category("Existing Bruno Test")
@export var delay_after_stand: float = 0.25
@export var wait_after_arrival: float = 0.75

@export_category("Test Sequence")
@export var lock_player_during_test: bool = true

@export_category("Intro Collision Blockers")
@export var intro_blocker_group: StringName = &"bruno_intro_blocker"

var intro_started: bool = false
var intro_start_msec: int = 0
var dialogue_start_msec: int = 0

var cinematic_camera: Camera3D = null
var player_camera: Camera3D = null
var bruno_animation_player: AnimationPlayer = null
var dialogue_player: AudioStreamPlayer = null

var rng := RandomNumberGenerator.new()

var original_tv_music_volume_db: float = 0.0
var original_light_states: Dictionary = {}

# SAFE: stato originale dei collider degli oggetti della intro.
var intro_blocker_collision_states: Dictionary = {}
var intro_blockers_disabled: bool = false


func _ready() -> void:
	rng.randomize()

	if player == null:
		player = (
			get_tree()
			.get_first_node_in_group("player")
			as CharacterBody3D
		)

	_resolve_player_camera()
	_resolve_bruno_animation_player()
	_setup_dialogue_player()
	_capture_original_light_states()

	if tv_music_audio != null:
		original_tv_music_volume_db = (
			tv_music_audio.volume_db
		)

	# Bruno esiste già nella scena, ma resta invisibile e fermo
	# nella posa seduta fino al reveal.
	_prepare_bruno_hidden_pose()


func start_intro() -> void:
	if intro_started:
		return

	if player == null:
		push_error(
			"BrunoIntroController: riferimento Player mancante."
		)
		return

	if bruno == null:
		push_error(
			"BrunoIntroController: riferimento Bruno mancante."
		)
		return

	if point_1 == null:
		push_error(
			"BrunoIntroController: BrunoCinematicPoint1 mancante."
		)
		return

	if camera_tv_point == null:
		push_error(
			"BrunoIntroController: Camera TV Point mancante."
		)
		return

	if camera_reveal_point == null:
		push_error(
			"BrunoIntroController: Camera Reveal Point mancante."
		)
		return

	if camera_stand_point == null:
		push_error(
			"BrunoIntroController: Camera Stand Point mancante."
		)
		return

	if cinematic_lights.is_empty():
		push_error(
			"BrunoIntroController: assegna almeno una luce in Cinematic Lights."
		)
		return

	if dialogue_audio == null:
		push_error(
			"BrunoIntroController: Dialogue Audio mancante."
		)
		return

	_resolve_player_camera()
	_resolve_bruno_animation_player()

	if player_camera == null:
		push_error(
			"BrunoIntroController: Player/Head/Camera3D non trovata."
		)
		return

	intro_started = true
	intro_start_msec = Time.get_ticks_msec()

	_disable_intro_blockers()

	if bruno.has_method("cinematic_lock"):
		bruno.call("cinematic_lock")

	_prepare_bruno_hidden_pose()

	_run_intro_timeline()


# ============================================================
# INTRO TIMELINE
# ============================================================

func _run_intro_timeline() -> void:
	if lock_player_during_test:
		_lock_player()

	# TV/video/audio sono già partiti dal telecomando PRIMA di start_intro().
	if video_lead_before_camera > 0.0:
		await get_tree().create_timer(
			video_lead_before_camera
		).timeout

	if not is_inside_tree():
		return

	_create_cinematic_camera()

	if cinematic_camera == null:
		push_error(
			"BrunoIntroController: impossibile creare Camera3D cinematica."
		)
		return

	# Movimento lento verso la TV.
	await _move_cinematic_camera_to(
		camera_tv_point,
		camera_move_to_tv_time
	)

	if not is_inside_tree():
		return

	# 12 s: inizio flicker.
	await _wait_until_intro_time(
		flicker_start_time
	)

	if not is_inside_tree():
		return

	await _run_light_flicker_until(
		blackout_time
	)

	if not is_inside_tree():
		return

	# 17 s: blackout.
	_set_all_cinematic_lights_enabled(
		false
	)

	if bruno.has_method("cinematic_set_visible"):
		bruno.call(
			"cinematic_set_visible",
			false
		)

	# 18 s: reveal.
	await _wait_until_intro_time(
		reveal_time
	)

	if not is_inside_tree():
		return

	_apply_purple_reveal_lights()

	if bruno.has_method("cinematic_set_visible"):
		bruno.call(
			"cinematic_set_visible",
			true
		)

	_freeze_bruno_sitting_pose()

	# Camera indietro: durante questo movimento Bruno resta immobile.
	await _move_cinematic_camera_to(
		camera_reveal_point,
		camera_move_to_reveal_time
	)

	if not is_inside_tree():
		return

	# Arrivati sull'inquadratura larga:
	# musica TV in sottofondo + dialogo + primi clap.
	_start_dialogue_sequence()

	await _run_dialogue_animation_timeline()


# ============================================================
# VIDEO / DIALOGUE AUDIO
# ============================================================

func _setup_dialogue_player() -> void:
	if dialogue_player != null:
		return

	dialogue_player = AudioStreamPlayer.new()
	dialogue_player.name = "BrunoDialogueAudio"
	dialogue_player.bus = dialogue_bus
	dialogue_player.volume_db = dialogue_volume_db
	add_child(dialogue_player)


func _start_dialogue_sequence() -> void:
	dialogue_start_msec = Time.get_ticks_msec()

	_duck_tv_music()

	if dialogue_player == null:
		_setup_dialogue_player()

	dialogue_player.stop()
	dialogue_player.stream = dialogue_audio
	dialogue_player.bus = dialogue_bus
	dialogue_player.volume_db = dialogue_volume_db
	dialogue_player.play()

	_play_bruno_animation(
		sitting_clap_animation,
		0.10,
		initial_clap_playback_speed
	)

	print(
		"[BrunoIntro] Dialogo iniziato. Timeline animazioni = 0.0 s"
	)


func _duck_tv_music() -> void:
	if tv_music_audio == null:
		return

	if tv_duck_time <= 0.0:
		tv_music_audio.volume_db = (
			tv_dialogue_volume_db
		)
		return

	var tween := create_tween()

	tween.set_trans(
		Tween.TRANS_SINE
	)

	tween.set_ease(
		Tween.EASE_IN_OUT
	)

	tween.tween_property(
		tv_music_audio,
		"volume_db",
		tv_dialogue_volume_db,
		tv_duck_time
	)


func restore_tv_music_volume() -> void:
	if tv_music_audio == null:
		return

	tv_music_audio.volume_db = (
		original_tv_music_volume_db
	)


# ============================================================
# DIALOGUE ANIMATION TIMELINE
# ============================================================

func _run_dialogue_animation_timeline() -> void:
	# Apertura: clap breve, poi Bruno parla seduto.
	# La quota sitting viene impostata dal Bruno stesso.
	if bruno != null and bruno.has_method("cinematic_play_sitting"):
		bruno.call("cinematic_play_sitting")
	else:
		_play_bruno_animation(
			sitting_clap_animation,
			0.0,
			initial_clap_playback_speed
		)

	await _wait_current_animation_end(
		sitting_clap_animation
	)

	if not is_inside_tree():
		return

	# Dopo il clap passa subito al talking seduto.
	_play_bruno_animation(
		sitting_talk_animation,
		0.12,
		1.0
	)

	# Prima risata del dialogo, circa 19/20 secondi.
	await _wait_until_dialogue_time(
		first_sitting_laugh_time
	)

	if not is_inside_tree():
		return

	await _play_one_animation_and_wait(
		sitting_laugh_animation,
		0.12,
		1.0
	)

	if not is_inside_tree():
		return

	# Finita la risata torna subito a parlare seduto.
	_play_bruno_animation(
		sitting_talk_animation,
		0.12,
		1.0
	)

	await _wait_until_dialogue_time(
		stand_start_time
	)

	if not is_inside_tree():
		return

	# Alzata + movimento camera verso BrunoCameraStandPoint.
	_start_cinematic_camera_move(
		camera_stand_point,
		camera_move_to_stand_time
	)

	var stand_available_time := maxf(
		walk_start_time
		- stand_start_time,
		0.10
	)

	var stand_speed := (
		_get_animation_speed_to_fit(
			stand_animation,
			stand_available_time
		)
	)

	if bruno.has_method(
		"cinematic_play_animation_and_wait"
	):
		await bruno.call(
			"cinematic_play_animation_and_wait",
			stand_animation,
			0.10,
			stand_speed
		)
	else:
		_play_bruno_animation(
			stand_animation,
			0.10,
			stand_speed
		)

	if (
		bruno_animation_player != null
		and _dialogue_elapsed_seconds()
			< walk_start_time
	):
		_play_bruno_animation(
			standing_idle_animation,
			0.10,
			1.0
		)

	await _wait_until_dialogue_time(
		walk_start_time
	)

	if not is_inside_tree():
		return

	# 26 s: cammina verso il marker già validato.
	if bruno.has_method(
		"cinematic_move_to"
	):
		bruno.call(
			"cinematic_move_to",
			point_1.global_position,
			walk_animation
		)

	while (
		is_inside_tree()
		and bruno != null
		and bruno.has_method(
			"cinematic_is_moving"
		)
		and bool(
			bruno.call(
				"cinematic_is_moving"
			)
		)
	):
		await get_tree().process_frame

	if not is_inside_tree():
		return

	if bruno.has_method(
		"cinematic_stop_move"
	):
		bruno.call(
			"cinematic_stop_move",
			talk_hands_open_animation
		)

	# Da qui in poi Bruno guarda la camera.
	await _turn_bruno_toward_camera()

	# 28 -> 56 s: mix di idle e talking, senza animazione angry.
	await _wait_until_dialogue_time(
		standing_talk_start_time
	)

	if not is_inside_tree():
		return

	await _play_standing_mix_until(
		standing_talk_first_end_time
	)

	# 57 s: risata.
	await _wait_until_dialogue_time(
		first_laugh_time
	)

	if not is_inside_tree():
		return

	if laugh_animation != &"" and _animation_exists(laugh_animation):
		await _play_one_animation_and_wait(
			laugh_animation,
			standing_anim_blend_time,
			1.0
		)

	# Dopo questo punto torna al mix normale fino a 1:10.
	if _dialogue_elapsed_seconds() < angry_talk_start_time:
		await _play_standing_mix_until(
			angry_talk_start_time
		)

	if not is_inside_tree():
		return

	# 1:10 -> 1:22: talking angry.
	await _wait_until_dialogue_time(
		angry_talk_start_time
	)

	if not is_inside_tree():
		return

	await _loop_animation_until(
		angry_talk_animation,
		angry_talk_end_time
	)

	if not is_inside_tree():
		return

	# 1:22: la risata in piedi verrà agganciata quando fissiamo
	# il nome definitivo della nuova animazione.
	if laugh_animation != &"" and _animation_exists(laugh_animation):
		await _play_one_animation_and_wait(
			laugh_animation,
			standing_anim_blend_time,
			1.0
		)

	if not is_inside_tree():
		return

	# Poi torna ai talking normali fino alla fine dell'audio.
	await _play_standing_mix_until_dialogue_end()

	print(
		"[BrunoIntro] Timeline dialogo completata fino alla fine audio."
	)


func _start_cinematic_camera_move(
	target: Marker3D,
	duration: float
) -> void:
	if cinematic_camera == null:
		return

	if target == null:
		return

	var target_position := target.global_position
	var target_quaternion := (
		target.global_transform.basis
		.get_rotation_quaternion()
		.normalized()
	)

	if duration <= 0.0:
		cinematic_camera.global_position = (
			target_position
		)

		cinematic_camera.quaternion = (
			target_quaternion
		)

		return

	var tween := create_tween()

	tween.set_parallel(
		true
	)

	tween.set_trans(
		camera_smooth_transition
	)

	tween.set_ease(
		camera_smooth_ease
	)

	tween.tween_property(
		cinematic_camera,
		"global_position",
		target_position,
		duration
	)

	tween.tween_property(
		cinematic_camera,
		"quaternion",
		target_quaternion,
		duration
	)


func _play_standing_mix_until(
	end_time_seconds: float
) -> void:
	var talk_sequence: Array[StringName] = [
		talk_hands_open_animation,
		talk_right_hand_animation,
		talk_passionately_animation,
		talk_left_animation,
		talk_hands_open_animation,
		talk_passionately_animation,
		talk_right_hand_animation,
		talk_left_animation
	]

	await _play_continuous_talk_until(
		end_time_seconds,
		talk_sequence,
		false
	)


func _play_standing_mix_until_dialogue_end() -> void:
	var talk_sequence: Array[StringName] = [
		talk_hands_open_animation,
		talk_passionately_animation,
		talk_right_hand_animation,
		talk_left_animation,
		talk_passionately_animation,
		talk_hands_open_animation,
		talk_right_hand_animation,
		talk_left_animation
	]

	await _play_continuous_talk_until(
		136.10,
		talk_sequence,
		true
	)


func _play_continuous_talk_until(
	end_time_seconds: float,
	talk_sequence: Array[StringName],
	stop_when_audio_ends: bool
) -> void:
	if talk_sequence.is_empty():
		await _wait_until_dialogue_time(
			end_time_seconds
		)
		return

	var index: int = 0

	while (
		is_inside_tree()
		and _dialogue_elapsed_seconds()
			< end_time_seconds
	):
		if stop_when_audio_ends:
			if (
				dialogue_player == null
				or not dialogue_player.playing
			):
				return

		var animation_name: StringName = (
			talk_sequence[
				index % talk_sequence.size()
			]
		)

		index += 1

		if not _animation_exists(
			animation_name
		):
			continue

		var remaining := (
			end_time_seconds
			- _dialogue_elapsed_seconds()
		)

		await _play_animation_for_max_time(
			animation_name,
			remaining
		)


func _loop_animation_until(
	animation_name: StringName,
	end_time_seconds: float
) -> void:
	if not _animation_exists(
		animation_name
	):
		return

	while (
		is_inside_tree()
		and _dialogue_elapsed_seconds()
			< end_time_seconds
	):
		var remaining := (
			end_time_seconds
			- _dialogue_elapsed_seconds()
		)

		await _play_animation_for_max_time(
			animation_name,
			remaining
		)


func _play_animation_for_max_time(
	animation_name: StringName,
	max_seconds: float
) -> void:
	if max_seconds <= 0.0:
		return

	if not _animation_exists(
		animation_name
	):
		return

	var animation := (
		bruno_animation_player.get_animation(
			animation_name
		)
	)

	if animation == null:
		return

	var play_time := minf(
		animation.length,
		max_seconds
	)

	_play_bruno_animation(
		animation_name,
		standing_anim_blend_time,
		1.0
	)

	await get_tree().create_timer(
		play_time
	).timeout


func _play_one_animation_and_wait(
	animation_name: StringName,
	blend_time: float,
	playback_speed: float
) -> void:
	if not _animation_exists(
		animation_name
	):
		return

	var animation := (
		bruno_animation_player.get_animation(
			animation_name
		)
	)

	if animation == null:
		return

	var safe_speed := maxf(
		absf(playback_speed),
		0.01
	)

	var duration := (
		animation.length
		/ safe_speed
	)

	_play_bruno_animation(
		animation_name,
		blend_time,
		playback_speed
	)

	await get_tree().create_timer(
		duration
	).timeout


func _wait_current_animation_end(
	animation_name: StringName
) -> void:
	if not _animation_exists(animation_name):
		return

	var animation := bruno_animation_player.get_animation(
		animation_name
	)

	if animation == null:
		return

	var speed := maxf(
		absf(bruno_animation_player.speed_scale),
		0.01
	)

	await get_tree().create_timer(
		animation.length / speed
	).timeout


func _animation_exists(
	animation_name: StringName
) -> bool:
	if bruno_animation_player == null:
		return false

	if bruno_animation_player.has_animation(
		animation_name
	):
		return true

	push_warning(
		"BrunoIntroController: animazione non trovata: "
		+ String(animation_name)
	)

	return false


func _wait_until_dialogue_time(
	target_seconds: float
) -> void:
	if target_seconds <= 0.0:
		return

	var remaining := (
		target_seconds
		- _dialogue_elapsed_seconds()
	)

	if remaining <= 0.0:
		return

	await get_tree().create_timer(
		remaining
	).timeout


func _dialogue_elapsed_seconds() -> float:
	if dialogue_start_msec <= 0:
		return 0.0

	return (
		(Time.get_ticks_msec() - dialogue_start_msec)
		/ 1000.0
	)


func _get_animation_speed_to_fit(
	animation_name: StringName,
	target_duration: float
) -> float:
	if bruno_animation_player == null:
		return 1.0

	if not bruno_animation_player.has_animation(
		animation_name
	):
		return 1.0

	var animation := (
		bruno_animation_player.get_animation(
			animation_name
		)
	)

	if animation == null:
		return 1.0

	var animation_length := maxf(
		animation.length,
		0.01
	)

	return animation_length / maxf(
		target_duration,
		0.01
	)


func _play_bruno_animation(
	animation_name: StringName,
	blend_time: float,
	playback_speed: float
) -> void:
	if bruno_animation_player == null:
		return

	if not bruno_animation_player.has_animation(
		animation_name
	):
		push_warning(
			"BrunoIntroController: animazione non trovata: "
			+ String(animation_name)
		)
		return

	bruno_animation_player.play(
		animation_name,
		blend_time,
		playback_speed
	)


func _turn_bruno_toward_camera() -> void:
	if bruno == null:
		return

	if cinematic_camera == null:
		return

	if not bruno is Node3D:
		return

	var bruno_3d := bruno as Node3D

	var direction := (
		cinematic_camera.global_position
		- bruno_3d.global_position
	)

	direction.y = 0.0

	if direction.length_squared() <= 0.000001:
		return

	var target_yaw := atan2(
		direction.x,
		direction.z
	)

	if face_camera_turn_time <= 0.0:
		bruno_3d.rotation.y = target_yaw
		return

	var tween := create_tween()

	tween.set_trans(
		Tween.TRANS_SINE
	)

	tween.set_ease(
		Tween.EASE_IN_OUT
	)

	tween.tween_property(
		bruno_3d,
		"rotation:y",
		target_yaw,
		face_camera_turn_time
	)

	await tween.finished


# ============================================================
# CAMERA
# ============================================================

func _resolve_player_camera() -> void:
	player_camera = null

	if player == null:
		return

	var camera_node := player.get_node_or_null(
		"Head/Camera3D"
	)

	if camera_node is Camera3D:
		player_camera = camera_node as Camera3D


func _create_cinematic_camera() -> void:
	if player_camera == null:
		return

	if (
		cinematic_camera != null
		and is_instance_valid(cinematic_camera)
	):
		cinematic_camera.queue_free()

	cinematic_camera = Camera3D.new()
	cinematic_camera.name = "BrunoCinematicCamera"
	cinematic_camera.top_level = true

	get_tree().current_scene.add_child(
		cinematic_camera
	)

	cinematic_camera.global_transform = (
		player_camera.global_transform
	)

	cinematic_camera.fov = player_camera.fov
	cinematic_camera.near = player_camera.near
	cinematic_camera.far = player_camera.far
	cinematic_camera.keep_aspect = player_camera.keep_aspect
	cinematic_camera.cull_mask = player_camera.cull_mask

	cinematic_camera.make_current()


func _move_cinematic_camera_to(
	target: Marker3D,
	duration: float
) -> void:
	if cinematic_camera == null:
		return

	if target == null:
		return

	var target_position := target.global_position
	var target_quaternion := (
		target.global_transform.basis
		.get_rotation_quaternion()
		.normalized()
	)

	if duration <= 0.0:
		cinematic_camera.global_position = (
			target_position
		)

		cinematic_camera.quaternion = (
			target_quaternion
		)

		return

	var tween := create_tween()

	tween.set_parallel(
		true
	)

	tween.set_trans(
		camera_smooth_transition
	)

	tween.set_ease(
		camera_smooth_ease
	)

	tween.tween_property(
		cinematic_camera,
		"global_position",
		target_position,
		duration
	)

	tween.tween_property(
		cinematic_camera,
		"quaternion",
		target_quaternion,
		duration
	)

	await tween.finished


func _wait_until_intro_time(
	target_seconds: float
) -> void:
	if target_seconds <= 0.0:
		return

	var elapsed_seconds := (
		(Time.get_ticks_msec() - intro_start_msec)
		/ 1000.0
	)

	var remaining := (
		target_seconds
		- elapsed_seconds
	)

	if remaining <= 0.0:
		return

	await get_tree().create_timer(
		remaining
	).timeout


# ============================================================
# LIGHTING
# ============================================================

func _capture_original_light_states() -> void:
	original_light_states.clear()

	for light: Light3D in cinematic_lights:
		if light == null:
			continue

		original_light_states[light] = {
			"visible": light.visible,
			"color": light.light_color,
			"energy": light.light_energy
		}


func _run_light_flicker_until(
	end_time_seconds: float
) -> void:
	while is_inside_tree():
		var elapsed_seconds := (
			(Time.get_ticks_msec() - intro_start_msec)
			/ 1000.0
		)

		if elapsed_seconds >= end_time_seconds:
			break

		var lights_on := (
			rng.randf()
			>= flicker_off_chance
		)

		_set_all_cinematic_lights_enabled(
			lights_on
		)

		var interval := rng.randf_range(
			flicker_min_interval,
			flicker_max_interval
		)

		var remaining := (
			end_time_seconds
			- elapsed_seconds
		)

		await get_tree().create_timer(
			minf(interval, remaining)
		).timeout


func _set_all_cinematic_lights_enabled(
	enabled: bool
) -> void:
	for light: Light3D in cinematic_lights:
		if light == null:
			continue

		light.visible = enabled


func _apply_purple_reveal_lights() -> void:
	for light: Light3D in cinematic_lights:
		if light == null:
			continue

		var base_energy := light.light_energy

		if original_light_states.has(light):
			var state: Dictionary = (
				original_light_states[light]
			)

			base_energy = float(
				state.get(
					"energy",
					light.light_energy
				)
			)

		light.light_color = reveal_light_color
		light.light_energy = (
			base_energy
			* reveal_energy_multiplier
		)

		light.visible = true


func restore_original_lights() -> void:
	for light_value: Variant in (
		original_light_states.keys()
	):
		if not light_value is Light3D:
			continue

		var light := light_value as Light3D

		if not is_instance_valid(light):
			continue

		var state: Dictionary = (
			original_light_states[light]
		)

		light.visible = bool(
			state.get(
				"visible",
				true
			)
		)

		light.light_color = state.get(
			"color",
			Color.WHITE
		)

		light.light_energy = float(
			state.get(
				"energy",
				1.0
			)
		)


# ============================================================
# BRUNO REVEAL / SITTING POSE
# ============================================================

func _resolve_bruno_animation_player() -> void:
	bruno_animation_player = null

	if bruno == null:
		return

	var candidate := bruno.get_node_or_null(
		"Meshy_AI_Mutated_Tennis_Player_All_Animations/AnimationPlayer"
	)

	if candidate is AnimationPlayer:
		bruno_animation_player = (
			candidate as AnimationPlayer
		)


func _prepare_bruno_hidden_pose() -> void:
	if bruno == null:
		return

	if bruno.has_method("cinematic_set_visible"):
		bruno.call(
			"cinematic_set_visible",
			false
		)

	if bruno.has_method("cinematic_play_sitting"):
		bruno.call("cinematic_play_sitting")

	_freeze_bruno_sitting_pose()


func _freeze_bruno_sitting_pose() -> void:
	if bruno_animation_player == null:
		return

	if not bruno_animation_player.has_animation(
		sitting_clap_animation
	):
		push_error(
			"BrunoIntroController: animazione Sitting_Clap non trovata."
		)
		return

	bruno_animation_player.play(
		sitting_clap_animation,
		0.0,
		1.0
	)

	bruno_animation_player.seek(
		sitting_pose_time,
		true
	)

	bruno_animation_player.pause()


# ============================================================
# INTRO COLLISION BLOCKERS
# ============================================================

func _disable_intro_blockers() -> void:
	if intro_blockers_disabled:
		return

	intro_blocker_collision_states.clear()

	var blocker_roots: Array[Node] = (
		get_tree()
		.get_nodes_in_group(
			intro_blocker_group
		)
	)

	for blocker_root: Node in blocker_roots:
		_collect_and_disable_collision_shapes(
			blocker_root
		)

	intro_blockers_disabled = true

	print(
		"[BrunoIntro] Collisioni intro disabilitate: ",
		intro_blocker_collision_states.size()
	)


func _collect_and_disable_collision_shapes(
	node: Node
) -> void:
	if node is CollisionShape3D:
		var collision_shape := (
			node as CollisionShape3D
		)

		if not intro_blocker_collision_states.has(
			collision_shape
		):
			intro_blocker_collision_states[
				collision_shape
			] = collision_shape.disabled

			collision_shape.set_deferred(
				"disabled",
				true
			)

	for child: Node in node.get_children():
		_collect_and_disable_collision_shapes(
			child
		)


func restore_intro_blockers() -> void:
	if not intro_blockers_disabled:
		return

	for collision_shape_value: Variant in (
		intro_blocker_collision_states.keys()
	):
		if not collision_shape_value is CollisionShape3D:
			continue

		var collision_shape := (
			collision_shape_value
			as CollisionShape3D
		)

		if not is_instance_valid(
			collision_shape
		):
			continue

		var original_disabled_value: Variant = (
			intro_blocker_collision_states.get(
				collision_shape,
				false
			)
		)

		collision_shape.set_deferred(
			"disabled",
			bool(original_disabled_value)
		)

	intro_blocker_collision_states.clear()
	intro_blockers_disabled = false

	print(
		"[BrunoIntro] Collisioni intro ripristinate."
	)


func start_boss_fight() -> void:
	restore_intro_blockers()

	if (
		bruno != null
		and bruno.has_method(
			"start_boss_fight"
		)
	):
		bruno.call(
			"start_boss_fight"
		)


# ============================================================
# PLAYER LOCK
# ============================================================

func _lock_player() -> void:
	if player == null:
		return

	player.velocity = Vector3.ZERO
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)


func _unlock_player() -> void:
	if player == null:
		return

	player.set_physics_process(true)
	player.set_process_unhandled_input(true)
