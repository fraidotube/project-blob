extends Area3D


@export var meteorite_audio: AudioStreamPlayer
@export var play_only_once: bool = true

@export_group("Cinematic")
@export var cinematic_enabled: bool = true
@export var building_view: Node3D
@export var meteorite_view: Node3D

@export_range(0.1, 10.0, 0.1) var move_to_building_duration: float = 2.2
@export_range(0.0, 10.0, 0.1) var building_hold_duration: float = 1.0
@export_range(0.1, 10.0, 0.1) var move_to_meteorite_duration: float = 2.4
@export_range(0.0, 10.0, 0.1) var meteorite_hold_duration: float = 2.0
@export_range(0.1, 10.0, 0.1) var return_duration: float = 1.6

var _already_played: bool = false
var _cinematic_running: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)

	if building_view == null:
		building_view = get_node_or_null("BuildingView")

	if meteorite_view == null:
		meteorite_view = get_node_or_null("MeteoriteView")


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	if play_only_once and _already_played:
		return

	if _cinematic_running:
		return

	_already_played = true

	if meteorite_audio != null:
		meteorite_audio.play()

	if not cinematic_enabled:
		return

	await _play_cinematic(body)


func _play_cinematic(player: Node3D) -> void:
	if building_view == null:
		push_warning(
			"Meteorite cinematic: BuildingView non assegnato."
		)
		return

	if meteorite_view == null:
		push_warning(
			"Meteorite cinematic: MeteoriteView non assegnato."
		)
		return

	var player_camera := (
		player.get_node_or_null("Head/Camera3D")
		as Camera3D
	)

	if player_camera == null:
		push_warning(
			"Meteorite cinematic: Camera3D del Player non trovata."
		)
		return

	_cinematic_running = true

	var interaction_system := (
		player.get_node_or_null("InteractionSystem")
	)

	var weapon_holder := (
		player.get_node_or_null(
			"Head/Camera3D/WeaponHolder"
		)
		as Node3D
	)

	var old_weapon_visibility := true

	if weapon_holder != null:
		old_weapon_visibility = weapon_holder.visible
		weapon_holder.visible = false

	if player is CharacterBody3D:
		(player as CharacterBody3D).velocity = Vector3.ZERO

	player.set_physics_process(false)
	player.set_process_unhandled_input(false)

	if interaction_system != null:
		interaction_system.set_process(false)

	var cinematic_camera := Camera3D.new()
	cinematic_camera.name = "MeteoriteCinematicCamera"

	get_tree().current_scene.add_child(
		cinematic_camera
	)

	cinematic_camera.global_transform = (
		player_camera.global_transform
	)

	cinematic_camera.fov = player_camera.fov
	cinematic_camera.near = player_camera.near
	cinematic_camera.far = player_camera.far
	cinematic_camera.cull_mask = player_camera.cull_mask

	cinematic_camera.current = true

	await _move_camera(
		cinematic_camera,
		building_view.global_transform,
		move_to_building_duration
	)

	if building_hold_duration > 0.0:
		await get_tree().create_timer(
			building_hold_duration
		).timeout

	await _move_camera(
		cinematic_camera,
		meteorite_view.global_transform,
		move_to_meteorite_duration
	)

	if meteorite_hold_duration > 0.0:
		await get_tree().create_timer(
			meteorite_hold_duration
		).timeout

	await _move_camera(
		cinematic_camera,
		player_camera.global_transform,
		return_duration
	)

	player_camera.current = true
	cinematic_camera.queue_free()

	if interaction_system != null:
		interaction_system.set_process(true)

	player.set_process_unhandled_input(true)
	player.set_physics_process(true)

	if weapon_holder != null:
		weapon_holder.visible = old_weapon_visibility

	_cinematic_running = false


func _move_camera(
	camera: Camera3D,
	target_transform: Transform3D,
	duration: float
) -> void:
	var tween := create_tween()

	tween.set_trans(
		Tween.TRANS_SINE
	)

	tween.set_ease(
		Tween.EASE_IN_OUT
	)

	tween.tween_property(
		camera,
		"global_transform",
		target_transform,
		duration
	)

	await tween.finished
