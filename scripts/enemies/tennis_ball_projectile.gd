extends Area3D

signal impacted(
	world_position: Vector3,
	explosive: bool
)

@export_category("Flight")
@export var projectile_gravity: float = 9.8
@export var default_flight_time: float = 0.9
@export var max_lifetime: float = 6.0

@export_category("Damage")
@export var normal_damage_radius: float = 0.80
@export var explosive_damage_radius: float = 2.50

@export_category("Visual")
@export var spin_speed: float = 12.0

@onready var ball_visual: Node3D = $tennis_ball

var velocity: Vector3 = Vector3.ZERO

var damage: int = 0
var explosive: bool = false
var shooter: Node = null

var launched: bool = false
var has_impacted: bool = false
var lifetime: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if not launched:
		return

	if has_impacted:
		return

	lifetime += delta

	if lifetime >= max_lifetime:
		queue_free()
		return

	if ball_visual != null:
		ball_visual.rotate_x(spin_speed * delta)
		ball_visual.rotate_z(spin_speed * 0.45 * delta)

	velocity.y -= projectile_gravity * delta

	var old_position := global_position
	var new_position := old_position + velocity * delta

	if _sweep_for_collision(
		old_position,
		new_position
	):
		return

	global_position = new_position


func launch(
	start_position: Vector3,
	target_position: Vector3,
	new_damage: int,
	new_explosive: bool,
	new_shooter: Node,
	flight_time: float = -1.0
) -> void:
	global_position = start_position

	damage = new_damage
	explosive = new_explosive
	shooter = new_shooter

	var time := flight_time

	if time <= 0.0:
		time = default_flight_time

	time = maxf(time, 0.05)

	var displacement := (
		target_position
		- start_position
	)

	velocity.x = displacement.x / time
	velocity.z = displacement.z / time

	velocity.y = (
		displacement.y
		+ 0.5
		* projectile_gravity
		* time
		* time
	) / time

	lifetime = 0.0
	has_impacted = false
	launched = true


func _sweep_for_collision(
	from_position: Vector3,
	to_position: Vector3
) -> bool:
	var query := (
		PhysicsRayQueryParameters3D.create(
			from_position,
			to_position
		)
	)

	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = collision_mask

	if (
		shooter != null
		and shooter is CollisionObject3D
	):
		query.exclude = [
			(shooter as CollisionObject3D).get_rid()
		]

	var result := (
		get_world_3d()
		.direct_space_state
		.intersect_ray(query)
	)

	if result.is_empty():
		return false

	var hit_position: Vector3 = result.get(
		"position",
		to_position
	)

	_impact(hit_position)

	return true


func _on_body_entered(
	body: Node3D
) -> void:
	if not launched:
		return

	if has_impacted:
		return

	if body == shooter:
		return

	_impact(global_position)


func _impact(
	world_position: Vector3
) -> void:
	if has_impacted:
		return

	has_impacted = true
	launched = false

	global_position = world_position

	_apply_area_damage()

	impacted.emit(
		global_position,
		explosive
	)

	queue_free()


func _apply_area_damage() -> void:
	if damage <= 0:
		return

	var radius := normal_damage_radius

	if explosive:
		radius = explosive_damage_radius

	for node: Node in (
		get_tree()
		.get_nodes_in_group("player")
	):
		if not is_instance_valid(node):
			continue

		if not node is Node3D:
			continue

		var target := node as Node3D

		var distance := (
			global_position
			.distance_to(
				target.global_position
			)
		)

		if distance > radius:
			continue

		if node.has_method("take_damage"):
			node.take_damage(damage)
