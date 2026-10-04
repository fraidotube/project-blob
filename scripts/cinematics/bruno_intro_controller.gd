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
@export var hud_root: Node

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
@export var dialogue_audio_part1: AudioStream
@export var dialogue_audio_part2: AudioStream
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
# Prima regia guidata dal parlato reale:
# clap -> dialogo seduto -> alzata -> cammino -> bow -> talking
# -> risata -> talking mano dx -> seconda risata -> look away -> happy hand.
@export var initial_clap_playback_speed: float = 1.00

# PARTE 1 - tempi relativi a dialogoBruno2_p1.mp3
@export var part1_laugh_time: float = 11.55

# PARTE 2 - tempi relativi a dialogoBruno2_p2.mp3.
# La parte 2 parte SOLO dopo alzata + cammino + arrivo + rotazione.
@export var p2_bow_time: float = 4.20
@export var p2_laugh_1_time: float = 23.75
@export var p2_tennis_look_time: float = 25.00
@export var p2_happy_hand_time: float = 27.35
@export var p2_stretching_time: float = 30.25
@export var p2_laugh_2_time: float = 44.95
@export var p2_angry_time: float = 48.10
@export var p2_challenge_time: float = 50.20
@export var p2_disappointed_time: float = 58.70
@export var p2_laugh_3_time: float = 68.05
@export var p2_final_yell_time: float = 74.20

@export var short_laugh_max_duration: float = 3.50
@export_range(0.0, 2.0, 0.05) var boss_start_delay_after_camera_return: float = 0.75

@export var stand_animation: StringName = &"mie/sit_to_to stand"
@export var standing_idle_animation: StringName = &"mie/idle"
@export var walk_animation: StringName = &"mie/walking"
@export_range(0.40, 2.00, 0.05) var intro_cinematic_walk_speed: float = 1.10

@export_category("Standing Dialogue Animations")
@export var talk_hands_open_animation: StringName = &"mie/talking1"
@export var talk_right_hand_animation: StringName = &"mie/talking2"
@export var talk_3_animation: StringName = &"mie/talking3"
@export var talk_4_animation: StringName = &"mie/talking4"
@export var talk_5_animation: StringName = &"mie/talking5"
@export var talk_6_animation: StringName = &"mie/talking6"
@export var talk_passionately_animation: StringName = &"mie/talking_mano_dx"
@export var talk_left_animation: StringName = &"mie/talking_sfida"
@export var stretching_animation: StringName = &"mie/talking_stretching"
@export var extra_idle_1_animation: StringName = &"mie/idle"
@export var extra_idle_2_animation: StringName = &"mie/breathing_idle"
@export var bow_animation: StringName = &"mie/bow"
@export var laugh_animation: StringName = &"mie/laughing"
@export var look_away_animation: StringName = &"mie/look_away"
@export var happy_hand_animation: StringName = &"mie/happy_hand"
@export var angry_talk_animation: StringName = &"mie/talking_angry"

@export_range(0.05, 2.0, 0.05) var standing_anim_blend_time: float = 0.20
@export_range(0.05, 2.0, 0.05) var face_camera_turn_time: float = 0.45

@export_category("Existing Bruno Test")
@export var delay_after_stand: float = 0.25
@export var wait_after_arrival: float = 0.75

@export_category("Test Sequence")
@export var lock_player_during_test: bool = true

@export_category("Dialogue Preview")
@export var dialogue_preview_mode: bool = false
@export var dialogue_preview_auto_start: bool = false
@export_range(0.0, 136.0, 0.5) var dialogue_preview_start_time: float = 0.0
@export var dialogue_preview_keep_player_free: bool = true
@export var dialogue_preview_trigger_key: Key = KEY_F9

@export_category("F9 Combat Debug")
@export var combat_debug_f9_enabled: bool = true
@export var combat_debug_restore_intro_blockers: bool = true

@export_category("Intro Collision Blockers")
@export var intro_blocker_group: StringName = &"bruno_intro_blocker"

@export_category("Debug")
@export var debug_animation_timeline: bool = true

var intro_started: bool = false
var intro_start_msec: int = 0
var dialogue_start_msec: int = 0

var cinematic_camera: Camera3D = null
var player_camera: Camera3D = null
var bruno_animation_player: AnimationPlayer = null
var dialogue_player: AudioStreamPlayer = null
var dialogue_preview_started: bool = false

var bruno_original_cinematic_walk_speed: float = 0.0
var bruno_cinematic_walk_speed_captured: bool = false

var rng := RandomNumberGenerator.new()

var original_tv_music_volume_db: float = 0.0
var original_light_states: Dictionary = {}

# SAFE: stato originale dei collider degli oggetti della intro.
var intro_blocker_collision_states: Dictionary = {}
var intro_blockers_disabled: bool = false

var hud_visibility_captured: bool = false
var hud_original_visible: bool = true


func _ready() -> void:
	rng.randomize()

	# V29 NORMAL TEST:
	# forza la modalità reale TV -> cinematic -> boss.
	dialogue_preview_mode = false
	dialogue_preview_auto_start = false

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

	if dialogue_preview_mode:
		_prepare_dialogue_preview()

		if dialogue_preview_auto_start:
			dialogue_preview_started = true
			_start_dialogue_preview.call_deferred()

		return

	# Modalità gioco normale:
	# Bruno esiste già nella scena, ma resta invisibile e fermo
	# nella posa seduta fino al reveal.
	_prepare_bruno_hidden_pose()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey

	if not key_event.pressed or key_event.echo:
		return

	if key_event.keycode != KEY_F9:
		return

	if combat_debug_f9_enabled and not dialogue_preview_mode:
		_start_combat_debug_from_cinematic_end()
		return

	if not dialogue_preview_mode:
		return

	if dialogue_preview_started:
		print(
			"[BrunoIntro][PREVIEW] già avviata."
		)
		return

	dialogue_preview_started = true
	_start_dialogue_preview.call_deferred()


func _start_combat_debug_from_cinematic_end() -> void:
	if bruno == null:
		push_error(
			"BrunoIntroController COMBAT DEBUG: Bruno mancante."
		)
		return

	if point_1 == null:
		push_error(
			"BrunoIntroController COMBAT DEBUG: Point1 mancante."
		)
		return

	if player == null:
		push_error(
			"BrunoIntroController COMBAT DEBUG: Player mancante."
		)
		return

	print(
		"[BrunoIntro][COMBAT DEBUG] F9: salto diretto a fine cinematic."
	)

	if dialogue_player != null:
		dialogue_player.stop()

	_restore_player_camera()
	_unlock_player()
	_restore_hud_visibility()

	if bruno.has_method("cinematic_lock"):
		bruno.call("cinematic_lock")

	if bruno.has_method("cinematic_set_visible"):
		bruno.call(
			"cinematic_set_visible",
			true
		)

	if bruno is Node3D:
		var bruno_3d := bruno as Node3D
		bruno_3d.global_position = point_1.global_position

		var direction := (
			player.global_position
			- bruno_3d.global_position
		)
		direction.y = 0.0

		if direction.length_squared() > 0.000001:
			bruno_3d.rotation.y = atan2(
				direction.x,
				direction.z
			)

	print(
		"[BrunoIntro][COMBAT DEBUG] Bruno posizionato a ",
		point_1.global_position
	)

	if combat_debug_restore_intro_blockers:
		restore_intro_blockers()
	else:
		_disable_intro_blockers()

	start_boss_fight()


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

	if dialogue_audio_part1 == null:
		push_error(
			"BrunoIntroController: Dialogue Audio Part1 mancante."
		)
		return

	if dialogue_audio_part2 == null:
		push_error(
			"BrunoIntroController: Dialogue Audio Part2 mancante."
		)
		return

	_resolve_player_camera()
	_resolve_bruno_animation_player()

	if bruno_animation_player == null:
		push_error(
			"BrunoIntroController: cutscene annullata, AnimationPlayer di Bruno non disponibile."
		)
		return

	if player_camera == null:
		push_error(
			"BrunoIntroController: Player/Head/Camera3D non trovata."
		)
		return

	intro_started = true
	intro_start_msec = Time.get_ticks_msec()

	_capture_and_hide_hud()
	_disable_intro_blockers()

	if bruno.has_method("cinematic_lock"):
		bruno.call("cinematic_lock")

	_prepare_bruno_hidden_pose()

	_run_intro_timeline()


# ============================================================
# DIALOGUE PREVIEW MODE
# ============================================================

func _prepare_dialogue_preview() -> void:
	if bruno == null:
		push_error(
			"BrunoIntroController PREVIEW: riferimento Bruno mancante."
		)
		return

	_resolve_bruno_animation_player()

	if bruno_animation_player == null:
		push_error(
			"BrunoIntroController PREVIEW: AnimationPlayer Bruno non disponibile."
		)
		return

	if bruno.has_method("cinematic_lock"):
		bruno.call("cinematic_lock")

	if bruno.has_method("cinematic_set_visible"):
		bruno.call(
			"cinematic_set_visible",
			true
		)

	# In preview non tocchiamo TV, luci, camera o collision blocker.
	# Prepariamo solo Bruno nella posa iniziale della timeline.
	if dialogue_preview_start_time <= 0.001:
		if bruno.has_method("cinematic_play_sitting"):
			bruno.call("cinematic_play_sitting")

		_freeze_bruno_sitting_pose()
	else:
		# Per ora gli start intermedi servono soprattutto per ascolto/debug.
		# Bruno parte in posa neutra; la timeline verrà sincronizzata
		# al tempo richiesto senza eseguire l'intro TV.
		_play_bruno_animation(
			talk_hands_open_animation,
			0.0,
			1.0
		)

	if dialogue_preview_keep_player_free:
		_unlock_player()

	print(
		"[BrunoIntro][PREVIEW] pronto | start=",
		"%.2f" % dialogue_preview_start_time,
		" | player_free=",
		dialogue_preview_keep_player_free
	)

	if not dialogue_preview_auto_start:
		print(
			"[BrunoIntro][PREVIEW] premi ",
			OS.get_keycode_string(dialogue_preview_trigger_key),
			" per avviare audio + timeline."
		)


func _debug_print_dialogue_animation_lengths() -> void:
	if not debug_animation_timeline:
		return

	if bruno_animation_player == null:
		return

	var names: Array[StringName] = [
		talk_hands_open_animation,
		talk_right_hand_animation,
		talk_3_animation,
		talk_4_animation,
		talk_5_animation,
		talk_6_animation,
		stretching_animation,
		angry_talk_animation,
		talk_left_animation,
		&"mie/disappointed",
		laugh_animation,
		&"mie/talking_urla"
	]

	print("[BrunoIntro][ANIM LENGTHS] -----")

	for animation_name in names:
		if not bruno_animation_player.has_animation(animation_name):
			print(
				"[BrunoIntro][ANIM LENGTHS] MISSING ",
				String(animation_name)
			)
			continue

		var animation := bruno_animation_player.get_animation(
			animation_name
		)

		if animation == null:
			continue

		print(
			"[BrunoIntro][ANIM LENGTHS] ",
			String(animation_name),
			" = ",
			"%.3f" % animation.length,
			" s"
		)


func _start_dialogue_preview() -> void:
	if not dialogue_preview_mode:
		return

	_capture_and_hide_hud()

	if dialogue_player == null:
		_setup_dialogue_player()

	if dialogue_audio_part1 == null:
		push_error(
			"BrunoIntroController PREVIEW: Dialogue Audio Part1 mancante."
		)
		return

	if dialogue_audio_part2 == null:
		push_error(
			"BrunoIntroController PREVIEW: Dialogue Audio Part2 mancante."
		)
		return

	_resolve_bruno_animation_player()

	if bruno_animation_player == null:
		push_error(
			"BrunoIntroController PREVIEW: AnimationPlayer Bruno non disponibile."
		)
		return

	_debug_print_dialogue_animation_lengths()

	# Con la nuova regia a due file la preview completa parte sempre da p1.
	# Start Time resta nell'Inspector per compatibilità, ma non viene usato.
	if dialogue_preview_start_time > 0.001:
		push_warning(
			"BrunoIntroController PREVIEW: Start Time ignorato nella modalità audio a due parti."
		)

	_play_dialogue_part1()

	print(
		"[BrunoIntro][PREVIEW] F9 -> PARTE 1 + movimento silenzioso + PARTE 2"
	)

	await _run_dialogue_animation_timeline()


func _run_dialogue_preview_from_time(
	_start_time: float
) -> void:
	push_warning(
		"BrunoIntroController: preview da timestamp disabilitata nella modalità audio a due parti."
	)


# ============================================================
# INTRO TIMELINE
# ============================================================

func _run_intro_timeline() -> void:
	if (
		lock_player_during_test
		and not dialogue_preview_mode
	):
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
	_duck_tv_music()

	if dialogue_player == null:
		_setup_dialogue_player()

	_play_dialogue_part1()

	print(
		"[BrunoIntro] Dialogo PARTE 1 iniziato."
	)


func _play_dialogue_part1() -> void:
	if dialogue_player == null:
		_setup_dialogue_player()

	if dialogue_audio_part1 == null:
		push_error(
			"BrunoIntroController: Dialogue Audio Part1 mancante."
		)
		return

	dialogue_start_msec = Time.get_ticks_msec()

	dialogue_player.stop()
	dialogue_player.stream = dialogue_audio_part1
	dialogue_player.bus = dialogue_bus
	dialogue_player.volume_db = dialogue_volume_db
	dialogue_player.play()


func _play_dialogue_part2() -> void:
	if dialogue_player == null:
		_setup_dialogue_player()

	if dialogue_audio_part2 == null:
		push_error(
			"BrunoIntroController: Dialogue Audio Part2 mancante."
		)
		return

	# IMPORTANTE:
	# la timeline torna a zero qui. Tutti i cue p2_* sono relativi
	# all'inizio del secondo MP3, non all'inizio della cinematic.
	dialogue_start_msec = Time.get_ticks_msec()

	dialogue_player.stop()
	dialogue_player.stream = dialogue_audio_part2
	dialogue_player.bus = dialogue_bus
	dialogue_player.volume_db = dialogue_volume_db
	dialogue_player.play()

	print(
		"[BrunoIntro] Dialogo PARTE 2 iniziato: timeline p2 = 0.0 s"
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

func _bruno_has_property(
	property_name: StringName
) -> bool:
	if bruno == null:
		return false

	for property_info: Dictionary in bruno.get_property_list():
		if StringName(String(property_info.get("name", ""))) == property_name:
			return true

	return false


func _apply_intro_walk_speed() -> void:
	if not _bruno_has_property(&"cinematic_walk_speed"):
		push_warning(
			"BrunoIntroController: Bruno non espone cinematic_walk_speed."
		)
		return

	if not bruno_cinematic_walk_speed_captured:
		bruno_original_cinematic_walk_speed = float(
			bruno.get("cinematic_walk_speed")
		)
		bruno_cinematic_walk_speed_captured = true

	bruno.set(
		"cinematic_walk_speed",
		intro_cinematic_walk_speed
	)

	print(
		"[BrunoIntro] cinematic_walk_speed intro = ",
		"%.2f" % intro_cinematic_walk_speed
	)


func _restore_bruno_cinematic_walk_speed() -> void:
	if not bruno_cinematic_walk_speed_captured:
		return

	if not _bruno_has_property(&"cinematic_walk_speed"):
		return

	bruno.set(
		"cinematic_walk_speed",
		bruno_original_cinematic_walk_speed
	)

	print(
		"[BrunoIntro] cinematic_walk_speed ripristinata = ",
		"%.2f" % bruno_original_cinematic_walk_speed
	)

	bruno_cinematic_walk_speed_captured = false


func _run_dialogue_animation_timeline() -> void:
	if debug_animation_timeline:
		print("[BrunoIntro][TIMELINE] TWO-PART START")

	# ========================================================
	# PARTE 1 - 13.009 s
	# Bruno è seduto. Clap -> sitting talk -> risata finale.
	# ========================================================
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

	_play_bruno_animation(
		sitting_talk_animation,
		0.12,
		1.0
	)

	await _wait_until_dialogue_time(
		part1_laugh_time
	)

	if not is_inside_tree():
		return

	# La risata audio della p1 è corta: l'animazione viene interrotta
	# naturalmente quando termina il file e comincia l'alzata.
	_play_bruno_animation(
		laugh_animation,
		0.12,
		1.0
	)

	if dialogue_player != null and dialogue_player.playing:
		await dialogue_player.finished

	if not is_inside_tree():
		return

	print(
		"[BrunoIntro][TIMELINE] P1 FINITA -> movimento silenzioso"
	)

	# ========================================================
	# SILENZIO REALE TRA P1 E P2
	# Nessun timer artificiale: il secondo audio aspetta Bruno.
	# ========================================================

	# Alzata a velocità naturale.
	_start_cinematic_camera_move(
		camera_stand_point,
		camera_move_to_stand_time
	)

	if bruno.has_method("cinematic_play_animation_and_wait"):
		await bruno.call(
			"cinematic_play_animation_and_wait",
			stand_animation,
			0.10,
			1.0
		)
	else:
		await _play_one_animation_and_wait(
			stand_animation,
			0.10,
			1.0
		)

	if not is_inside_tree():
		return

	# Cammino verso Point1.
	# Velocità cinematicamente più lenta; la velocità originale
	# viene ripristinata prima della boss battle.
	_apply_intro_walk_speed()

	if bruno.has_method("cinematic_move_to"):
		bruno.call(
			"cinematic_move_to",
			point_1.global_position,
			walk_animation
		)

	while (
		is_inside_tree()
		and bruno != null
		and bruno.has_method("cinematic_is_moving")
		and bool(bruno.call("cinematic_is_moving"))
	):
		await get_tree().process_frame

	if not is_inside_tree():
		return

	# Arrivo: niente idle. Talking leggero mentre si gira.
	if bruno.has_method("cinematic_stop_move"):
		bruno.call(
			"cinematic_stop_move",
			talk_6_animation
		)

	await _turn_bruno_toward_focus()

	if not is_inside_tree():
		return

	# ========================================================
	# PARTE 2
	# Parte ESATTAMENTE quando Bruno è arrivato e ci sta guardando.
	# Da qui tutti i tempi tornano a 0.
	# ========================================================
	_play_dialogue_part2()

	_play_bruno_animation(
		talk_6_animation,
		standing_anim_blend_time,
		1.0
	)

	# --------------------------------------------------------
	# 0 -> 4.20
	# "Visto che sei arrivato... possiamo presentarci."
	# Gesti piccoli/naturali.
	# --------------------------------------------------------
	await _play_continuous_talk_until(
		p2_bow_time,
		[
			talk_6_animation,
			talk_5_animation,
			talk_hands_open_animation
		],
		false
	)

	if not is_inside_tree():
		return

	# --------------------------------------------------------
	# ~4.20
	# "Bruno Buozzi. Responsabile acquisti."
	# BOW completo.
	# --------------------------------------------------------
	await _play_one_shot_then_talk_until(
		bow_animation,
		p2_laugh_1_time
	)

	if not is_inside_tree():
		return

	# --------------------------------------------------------
	# Fino a ~23.75:
	# offerte / prezzi / Blob / firme / autorizzazioni.
	# Mix vario. talking3 compare poco.
	# --------------------------------------------------------
	# _play_one_shot_then_talk_until ha già coperto questo tratto.

	# --------------------------------------------------------
	# ~23.75: risata dopo "se la viene a prendere".
	# Deve finire PRIMA del tennis.
	# --------------------------------------------------------
	await _wait_until_dialogue_time(
		p2_laugh_1_time
	)

	await _play_animation_for_max_time(
		laugh_animation,
		maxf(
			p2_tennis_look_time
			- _dialogue_elapsed_seconds(),
			0.05
		)
	)

	if not is_inside_tree():
		return

	# --------------------------------------------------------
	# ~25.00: "E poi... c'è il tennis."
	# --------------------------------------------------------
	await _wait_until_dialogue_time(
		p2_tennis_look_time
	)

	await _play_one_shot_then_talk_until(
		look_away_animation,
		p2_happy_hand_time
	)

	if not is_inside_tree():
		return

	# --------------------------------------------------------
	# ~27.35: "Ahhh... il tennis."
	# --------------------------------------------------------
	await _wait_until_dialogue_time(
		p2_happy_hand_time
	)

	await _play_one_shot_then_talk_until(
		happy_hand_animation,
		p2_stretching_time
	)

	if not is_inside_tree():
		return

	# --------------------------------------------------------
	# ~30.25: blocco stretching.
	# La clip dura 8.867 s e qui viene lasciata completa.
	# --------------------------------------------------------
	await _wait_until_dialogue_time(
		p2_stretching_time
	)

	await _play_one_animation_and_wait(
		stretching_animation,
		standing_anim_blend_time,
		1.0
	)

	if not is_inside_tree():
		return

	# Dritto / rovescio / servizio / stile / Roger:
	# gesti piccoli di testa e sguardo, niente idle.
	if _dialogue_elapsed_seconds() < p2_laugh_2_time:
		await _play_continuous_talk_until(
			p2_laugh_2_time,
			[
				talk_4_animation,
				talk_6_animation,
				talk_5_animation,
				talk_hands_open_animation
			],
			false
		)

	if not is_inside_tree():
		return

	# --------------------------------------------------------
	# ~44.95: risata dopo "Quasi alla Roger".
	# --------------------------------------------------------
	await _play_animation_for_max_time(
		laugh_animation,
		maxf(
			p2_angry_time
			- _dialogue_elapsed_seconds(),
			0.05
		)
	)

	if not is_inside_tree():
		return

	# --------------------------------------------------------
	# ~48.10: "[annoyed] Che c'è? Non mi credi?"
	# talking_angry SOLO per questa finestra: viene tagliato.
	# --------------------------------------------------------
	await _wait_until_dialogue_time(
		p2_angry_time
	)

	await _play_animation_for_max_time(
		angry_talk_animation,
		maxf(
			p2_challenge_time
			- _dialogue_elapsed_seconds(),
			0.05
		)
	)

	if not is_inside_tree():
		return

	# --------------------------------------------------------
	# ~50.20: "Allora facciamo così. Ti sfido."
	# talking_sfida una sola volta.
	# --------------------------------------------------------
	await _wait_until_dialogue_time(
		p2_challenge_time
	)

	await _play_one_animation_and_wait(
		talk_left_animation,
		standing_anim_blend_time,
		1.0
	)

	if not is_inside_tree():
		return

	# Dopo la sfida: torna a parlare normalmente.
	if _dialogue_elapsed_seconds() < p2_disappointed_time:
		await _play_continuous_talk_until(
			p2_disappointed_time,
			[
				talk_hands_open_animation,
				talk_5_animation,
				talk_right_hand_animation,
				talk_6_animation
			],
			false
		)

	if not is_inside_tree():
		return

	# --------------------------------------------------------
	# ~58.70: "Però... aspetta. Mi manca la racchetta."
	# disappointed completo (4.183 s).
	# --------------------------------------------------------
	await _wait_until_dialogue_time(
		p2_disappointed_time
	)

	await _play_one_animation_and_wait(
		&"mie/disappointed",
		standing_anim_blend_time,
		1.0
	)

	if not is_inside_tree():
		return

	# "È qui fuori... io vado a prenderla... puoi correre,
	# spararmi, nasconderti..." -> talking vari.
	if _dialogue_elapsed_seconds() < p2_laugh_3_time:
		await _play_continuous_talk_until(
			p2_laugh_3_time,
			[
				talk_4_animation,
				talk_passionately_animation,
				talk_6_animation,
				talk_5_animation,
				talk_hands_open_animation,
				talk_3_animation,
				talk_right_hand_animation
			],
			false
		)

	if not is_inside_tree():
		return

	# --------------------------------------------------------
	# ~68.05: ultima risata.
	# --------------------------------------------------------
	await _wait_until_dialogue_time(
		p2_laugh_3_time
	)

	await _play_animation_for_max_time(
		laugh_animation,
		minf(
			short_laugh_max_duration,
			maxf(
				p2_final_yell_time
				- _dialogue_elapsed_seconds()
				- 0.20,
				0.05
			)
		)
	)

	if not is_inside_tree():
		return

	# "Poi vediamo quanto sei bravo." + raccordo verso finale.
	if _dialogue_elapsed_seconds() < p2_final_yell_time:
		await _play_continuous_talk_until(
			p2_final_yell_time,
			[
				talk_6_animation,
				talk_5_animation,
				talk_hands_open_animation
			],
			false
		)

	if not is_inside_tree():
		return

	# --------------------------------------------------------
	# ~74.20:
	# talking_urla parte prima della parola finale, così il gesto
	# costruisce l'urlo e "SERVIZIO!" cade nella parte conclusiva.
	# L'audio resta il master della chiusura.
	# --------------------------------------------------------
	await _wait_until_dialogue_time(
		p2_final_yell_time
	)

	if not is_inside_tree():
		return

	_play_bruno_animation(
		&"mie/talking_urla",
		0.10,
		1.0
	)

	if (
		dialogue_player != null
		and dialogue_player.playing
	):
		await dialogue_player.finished

	if not is_inside_tree():
		return

	if debug_animation_timeline:
		print(
			"[BrunoIntro][TIMELINE] AUDIO P2 FINITO -> ritorno camera/player | t_p2=",
			"%.2f" % _dialogue_elapsed_seconds()
		)

	await _finish_cinematic_and_start_boss()


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


func _default_talking_mix() -> Array[StringName]:
	return [
		talk_hands_open_animation,
		talk_3_animation,
		talk_right_hand_animation,
		talk_5_animation,
		talk_4_animation,
		talk_passionately_animation,
		talk_6_animation,
		talk_hands_open_animation,
		talk_4_animation,
		talk_right_hand_animation,
		talk_3_animation,
		talk_6_animation,
		talk_5_animation
	]


func _play_one_shot_then_talk_until(
	animation_name: StringName,
	next_event_time: float
) -> void:
	var remaining := (
		next_event_time
		- _dialogue_elapsed_seconds()
	)

	if remaining > 0.0:
		await _play_animation_for_max_time(
			animation_name,
			remaining
		)

	if not is_inside_tree():
		return

	if _dialogue_elapsed_seconds() < next_event_time:
		await _play_continuous_talk_until(
			next_event_time,
			_default_talking_mix(),
			false
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
			# SAFE: mai ciclare senza yield. Un nome errato non deve
			# poter congelare il main thread di Godot.
			await get_tree().process_frame
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

	if debug_animation_timeline:
		print(
			"[BrunoIntro][ANIM] WAIT ONE ",
			String(animation_name),
			" | duration=",
			"%.3f" % duration
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

	var wait_time := animation.length / speed

	if debug_animation_timeline:
		print(
			"[BrunoIntro][ANIM] WAIT CURRENT ",
			String(animation_name),
			" | len=",
			"%.3f" % animation.length,
			" | speed=",
			"%.3f" % speed,
			" | wait=",
			"%.3f" % wait_time
		)

	await get_tree().create_timer(
		wait_time
	).timeout


func _animation_exists(
	animation_name: StringName
) -> bool:
	if bruno_animation_player == null:
		push_error(
			"BrunoIntroController: AnimationPlayer nullo mentre cerco: "
			+ String(animation_name)
		)
		return false

	if bruno_animation_player.has_animation(
		animation_name
	):
		return true

	push_warning(
		"BrunoIntroController: animazione non trovata: "
		+ String(animation_name)
	)

	if debug_animation_timeline:
		print(
			"[BrunoIntro][ANIM] Disponibili: ",
			bruno_animation_player.get_animation_list()
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

	if debug_animation_timeline:
		var anim := bruno_animation_player.get_animation(
			animation_name
		)

		print(
			"[BrunoIntro][ANIM] PLAY ",
			String(animation_name),
			" | t_dialogo=",
			"%.2f" % _dialogue_elapsed_seconds(),
			" | len=",
			"%.3f" % (anim.length if anim != null else -1.0),
			" | speed=",
			"%.3f" % playback_speed
		)

	bruno_animation_player.play(
		animation_name,
		blend_time,
		playback_speed
	)


func _turn_bruno_toward_focus() -> void:
	if bruno == null:
		return

	if not bruno is Node3D:
		return

	var bruno_3d := bruno as Node3D
	var focus_position := Vector3.ZERO
	var focus_valid := false

	# Modalità cinematica normale: guarda la camera della cutscene.
	if (
		cinematic_camera != null
		and is_instance_valid(cinematic_camera)
	):
		focus_position = cinematic_camera.global_position
		focus_valid = true

	# Modalità preview F9: non esiste la camera cinematica,
	# quindi Bruno guarda il player reale.
	elif (
		dialogue_preview_mode
		and player != null
		and is_instance_valid(player)
	):
		focus_position = player.global_position
		focus_valid = true

	# Fallback: usa la camera del player se disponibile.
	elif (
		player_camera != null
		and is_instance_valid(player_camera)
	):
		focus_position = player_camera.global_position
		focus_valid = true

	if not focus_valid:
		return

	var direction := (
		focus_position
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
		push_error(
			"BrunoIntroController: Bruno non assegnato, impossibile risolvere AnimationPlayer."
		)
		return

	var candidate := bruno.get_node_or_null(
		"BetterBuozzi/AnimationPlayer"
	)

	if not candidate is AnimationPlayer:
		push_error(
			"BrunoIntroController: BetterBuozzi/AnimationPlayer non trovato."
		)
		return

	bruno_animation_player = candidate as AnimationPlayer

	if debug_animation_timeline:
		print(
			"[BrunoIntro][ANIM] AnimationPlayer risolto: ",
			bruno_animation_player.get_path()
		)

		print(
			"[BrunoIntro][ANIM] Animazioni disponibili: ",
			bruno_animation_player.get_animation_list()
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


func _finish_cinematic_and_start_boss() -> void:
	# IMPORTANTE:
	# la velocità lenta vale SOLO per il movimento cinematografico.
	# Prima del combattimento ripristiniamo il valore originale.
	_restore_bruno_cinematic_walk_speed()

	# Terminato l'audio, prima restituisce la visuale al Player.
	_restore_player_camera()

	# Ridà il controllo al Player.
	_unlock_player()

	# La HUD è rimasta nascosta per tutta la cinematic e torna ora.
	_restore_hud_visibility()

	# Breve assestamento sulla visuale del Player.
	if boss_start_delay_after_camera_return > 0.0:
		await get_tree().create_timer(
			boss_start_delay_after_camera_return
		).timeout

	if not is_inside_tree():
		return

	# Ripristina i blocker temporaneamente disabilitati.
	restore_intro_blockers()

	# NON tocchiamo la logica di combattimento:
	# richiama il metodo esistente di Bruno, già validato nel poligono
	# (SEEK_RACKET / MOVE_TO_PLAYER / navigation / velocità di fase).
	start_boss_fight()

	print(
		"[BrunoIntro] NORMAL: camera/HUD ripristinati -> start_boss_fight esistente."
	)


func _restore_player_camera() -> void:
	if (
		player_camera == null
		or not is_instance_valid(player_camera)
	):
		_resolve_player_camera()

	if (
		player_camera != null
		and is_instance_valid(player_camera)
	):
		player_camera.make_current()

	if (
		cinematic_camera != null
		and is_instance_valid(cinematic_camera)
	):
		cinematic_camera.queue_free()

	cinematic_camera = null


func _capture_and_hide_hud() -> void:
	if hud_root == null:
		push_warning(
			"[HUD DEBUG] HUD Root NON assegnato: la HUD non può sparire."
		)
		return

	print(
		"[HUD DEBUG] root=",
		hud_root.get_path(),
		" class=",
		hud_root.get_class()
	)

	if not hud_visibility_captured:
		if hud_root is CanvasLayer:
			hud_original_visible = (
				hud_root as CanvasLayer
			).visible
			hud_visibility_captured = true

		elif hud_root is CanvasItem:
			hud_original_visible = (
				hud_root as CanvasItem
			).visible
			hud_visibility_captured = true

		else:
			push_warning(
				"[HUD DEBUG] HUD Root non è CanvasLayer/CanvasItem."
			)
			return

	print(
		"[HUD DEBUG] visible PRIMA=",
		hud_original_visible
	)

	if hud_root is CanvasLayer:
		(hud_root as CanvasLayer).visible = false

	elif hud_root is CanvasItem:
		(hud_root as CanvasItem).visible = false

	var visible_after := true

	if hud_root is CanvasLayer:
		visible_after = (
			hud_root as CanvasLayer
		).visible

	elif hud_root is CanvasItem:
		visible_after = (
			hud_root as CanvasItem
		).visible

	print(
		"[HUD DEBUG] visible DOPO hide=",
		visible_after
	)


func _restore_hud_visibility() -> void:
	if hud_root == null:
		return

	if not hud_visibility_captured:
		return

	if hud_root is CanvasLayer:
		(hud_root as CanvasLayer).visible = (
			hud_original_visible
		)

	elif hud_root is CanvasItem:
		(hud_root as CanvasItem).visible = (
			hud_original_visible
	)

	hud_visibility_captured = false


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
