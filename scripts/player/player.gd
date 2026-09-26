extends CharacterBody3D

const WALK_SPEED := 5.0
const SPRINT_SPEED := 8.0
const CROUCH_SPEED := 2.8
const JUMP_VELOCITY := 4.5
const MOUSE_SENSITIVITY := 0.004

const STAND_HEIGHT := 1.8
const CROUCH_HEIGHT := 1.2

const STAND_HEAD_Y := 0.9
const CROUCH_HEAD_Y := 0.45

const CROUCH_TRANSITION_SPEED := 8.0

const FOOTSTEP_WALK_INTERVAL := 0.45
const FOOTSTEP_SPRINT_INTERVAL := 0.30
const FOOTSTEP_CROUCH_INTERVAL := 0.60

const LAND_MIN_SPEED := -2.0

@export var max_health := 100

@export var footsteps_parquet: AudioStream

@export var footsteps_tile: AudioStream
@export var footsteps_tile_run: AudioStream

@export var footsteps_rock: AudioStream
@export var footsteps_rock_run: AudioStream

@export var jump_tile_start: AudioStream
@export var jump_tile_land: AudioStream

@export var jump_rock_start: AudioStream
@export var jump_rock_land: AudioStream

@onready var head: Node3D = $Head
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var weapon: Node3D = $Head/Camera3D/WeaponHolder
@onready var interact_ray: RayCast3D = $Head/Camera3D/InteractRay

@onready var footstep_audio: AudioStreamPlayer3D = $FootstepAudio
@onready var footstep_timer: Timer = $FootstepTimer
@onready var footstep_ray: RayCast3D = $FootstepRay

@onready var jump_audio: AudioStreamPlayer3D = $JumpAudio
@onready var land_audio: AudioStreamPlayer3D = $LandAudio

var health: int
var is_dead := false
var is_crouched := false


func _ready() -> void:
	health = max_health
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	get_tree().call_group(
		"hud",
		"update_health",
		health,
		max_health
	)


func _unhandled_input(event: InputEvent) -> void:
	if is_dead:
		if event.is_action_pressed("restart"):
			get_tree().reload_current_scene()

		return

	if event is InputEventMouseMotion:
		rotate_y(
			-event.relative.x * MOUSE_SENSITIVITY
		)

		head.rotate_x(
			-event.relative.y * MOUSE_SENSITIVITY
		)

		head.rotation.x = clamp(
			head.rotation.x,
			deg_to_rad(-89.0),
			deg_to_rad(89.0)
		)

	if event.is_action_pressed("interact"):
		try_interact()

	if event.is_action_pressed("weapon_slot_1"):
		weapon.select_weapon_slot(1)

	if event.is_action_pressed("weapon_slot_2"):
		weapon.select_weapon_slot(2)

	if event.is_action_pressed("weapon_slot_3"):
		weapon.select_weapon_slot(3)

	if event.is_action_pressed("flashlight_toggle"):
		weapon.toggle_flashlight()

	if event.is_action_pressed("fire"):
		weapon.fire()

	if event.is_action_pressed("reload"):
		weapon.reload()

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func try_interact() -> void:
	interact_ray.force_raycast_update()

	if not interact_ray.is_colliding():
		return

	var collider := interact_ray.get_collider()

	print("INTERACT COLLIDER: ", collider)

	if collider == null:
		return

	var current_node: Node = collider

	while current_node != null:
		if current_node.has_method("interact"):
			current_node.interact()
			return

		current_node = current_node.get_parent()


func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector3.ZERO
		footstep_timer.stop()
		return

	var was_on_floor := is_on_floor()

	_update_crouch(delta)

	if not is_on_floor():
		velocity += get_gravity() * delta

	if (
		Input.is_action_just_pressed("jump")
		and is_on_floor()
		and not is_crouched
	):
		_play_jump_sound()
		velocity.y = JUMP_VELOCITY

	var is_sprinting := (
		Input.is_action_pressed("sprint")
		and not is_crouched
	)

	var speed := WALK_SPEED

	if is_crouched:
		speed = CROUCH_SPEED
	elif is_sprinting:
		speed = SPRINT_SPEED

	var input_dir := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)

	var direction := (
		transform.basis
		* Vector3(
			input_dir.x,
			0.0,
			input_dir.y
		)
	).normalized()

	var is_moving := direction != Vector3.ZERO

	if is_moving:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(
			velocity.x,
			0.0,
			speed
		)

		velocity.z = move_toward(
			velocity.z,
			0.0,
			speed
		)

	var vertical_speed_before_move := velocity.y

	move_and_slide()

	var just_landed := (
		not was_on_floor
		and is_on_floor()
	)

	if just_landed:
		_play_landing_sound(
			vertical_speed_before_move
		)

	weapon.set_movement_state(
		is_moving,
		is_sprinting
	)

	_update_footsteps(
		is_sprinting,
		just_landed
	)


func _update_footsteps(
	is_sprinting: bool,
	just_landed: bool
) -> void:
	if not is_on_floor():
		footstep_timer.stop()
		return

	var horizontal_speed := Vector2(
		velocity.x,
		velocity.z
	).length()

	if horizontal_speed < 0.2:
		footstep_timer.stop()
		return

	var interval := _get_footstep_interval(
		is_sprinting
	)

	if just_landed:
		footstep_timer.start(interval)
		return

	if footstep_timer.is_stopped():
		var footstep_stream := _get_footstep_stream(
			is_sprinting
		)

		if footstep_stream == null:
			return

		footstep_audio.stream = footstep_stream
		footstep_audio.play()

		footstep_timer.start(interval)


func _get_footstep_interval(
	is_sprinting: bool
) -> float:
	if is_crouched:
		return FOOTSTEP_CROUCH_INTERVAL

	if is_sprinting:
		return FOOTSTEP_SPRINT_INTERVAL

	return FOOTSTEP_WALK_INTERVAL


func _get_surface_type() -> String:
	footstep_ray.force_raycast_update()

	if not footstep_ray.is_colliding():
		return ""

	var collider := footstep_ray.get_collider()

	if collider == null:
		return ""

	var current_node: Node = collider

	while current_node != null:
		if current_node.is_in_group("surface_rock"):
			return "rock"

		if current_node.is_in_group("surface_tile"):
			return "tile"

		if current_node.is_in_group("surface_parquet"):
			return "parquet"

		current_node = current_node.get_parent()

	return ""


func _get_footstep_stream(
	is_sprinting: bool
) -> AudioStream:
	var surface_type := _get_surface_type()

	match surface_type:
		"rock":
			if (
				is_sprinting
				and footsteps_rock_run != null
			):
				return footsteps_rock_run

			return footsteps_rock

		"tile":
			if (
				is_sprinting
				and footsteps_tile_run != null
			):
				return footsteps_tile_run

			return footsteps_tile

		"parquet":
			return footsteps_parquet

	return null


func _play_jump_sound() -> void:
	var surface_type := _get_surface_type()

	match surface_type:
		"rock":
			if jump_rock_start != null:
				jump_audio.stream = jump_rock_start
				jump_audio.play()

		"tile":
			if jump_tile_start != null:
				jump_audio.stream = jump_tile_start
				jump_audio.play()


func _play_landing_sound(
	vertical_speed: float
) -> void:
	if vertical_speed > LAND_MIN_SPEED:
		return

	var surface_type := _get_surface_type()

	match surface_type:
		"rock":
			if jump_rock_land != null:
				land_audio.stream = jump_rock_land
				land_audio.play()

		"tile":
			if jump_tile_land != null:
				land_audio.stream = jump_tile_land
				land_audio.play()


func _update_crouch(delta: float) -> void:
	var wants_to_crouch := Input.is_action_pressed("crouch")

	if wants_to_crouch:
		is_crouched = true
	elif is_crouched and _can_stand_up():
		is_crouched = false

	var target_height := STAND_HEIGHT
	var target_head_y := STAND_HEAD_Y

	if is_crouched:
		target_height = CROUCH_HEIGHT
		target_head_y = CROUCH_HEAD_Y

	var capsule := collision_shape.shape as CapsuleShape3D

	if capsule == null:
		return

	var new_height := move_toward(
		capsule.height,
		target_height,
		CROUCH_TRANSITION_SPEED * delta
	)

	capsule.height = new_height

	collision_shape.position.y = -(
		STAND_HEIGHT - new_height
	) * 0.5

	head.position.y = move_toward(
		head.position.y,
		target_head_y,
		CROUCH_TRANSITION_SPEED * delta
	)


func _can_stand_up() -> bool:
	var capsule := collision_shape.shape as CapsuleShape3D

	if capsule == null:
		return true

	var missing_height := STAND_HEIGHT - capsule.height

	if missing_height <= 0.01:
		return true

	return not test_move(
		global_transform,
		Vector3.UP * missing_height
	)


func equip_pistol() -> void:
	weapon.equip_pistol()


func equip_flashlight() -> void:
	weapon.equip_flashlight()


func add_ammo(amount: int) -> void:
	weapon.add_ammo(amount)


func take_damage(amount: int) -> void:
	if is_dead:
		return

	health -= amount
	health = max(health, 0)

	get_tree().call_group(
		"hud",
		"update_health",
		health,
		max_health
	)

	get_tree().call_group(
		"hud",
		"show_damage_flash"
	)

	if health <= 0:
		die()


func die() -> void:
	is_dead = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	footstep_timer.stop()

	get_tree().call_group(
		"hud",
		"show_death_screen"
	)
