extends CharacterBody3D

const WALK_SPEED := 5.0
const SPRINT_SPEED := 8.0
const JUMP_VELOCITY := 4.5
const MOUSE_SENSITIVITY := 0.004

@export var max_health := 100

@onready var head: Node3D = $Head
@onready var weapon: Node3D = $Head/Camera3D/WeaponHolder

var health: int
var is_dead := false


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

	if event.is_action_pressed("fire"):
		weapon.fire()

	if event.is_action_pressed("reload"):
		weapon.reload()

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector3.ZERO
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if (
		Input.is_action_just_pressed("jump")
		and is_on_floor()
	):
		velocity.y = JUMP_VELOCITY

	var is_sprinting := Input.is_action_pressed(
		"sprint"
	)

	var speed := WALK_SPEED

	if is_sprinting:
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

	move_and_slide()

	weapon.set_movement_state(
		is_moving,
		is_sprinting
	)


func equip_pistol() -> void:
	weapon.equip_pistol()


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

	get_tree().call_group(
		"hud",
		"show_death_screen"
	)
