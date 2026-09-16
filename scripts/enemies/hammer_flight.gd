extends Area3D

signal reached_hand
signal flight_finished(reason: StringName, final_position: Vector3)

enum Mode {
	NONE,
	RECALL,
	HUNT
}

@export_category("Flight")
@export var recall_speed: float = 18.0
@export var hunt_speed: float = 12.0
@export var hunt_turn_rate_deg: float = 105.0
@export var lifetime: float = 8.0
@export var catch_distance: float = 0.30

@export_category("Spin")
@export var spin_speed_deg: float = 900.0
@export var visual_path: NodePath = NodePath("Visual")

var mode: Mode = Mode.NONE
var target: Node3D = null
var shooter: Node = null
var damage: int = 0
var velocity: Vector3 = Vector3.ZERO
var remaining_lifetime: float = 0.0
var visual: Node3D = null
var finished: bool = false

func _ready() -> void:
	remaining_lifetime = lifetime
	visual = get_node_or_null(visual_path) as Node3D
	body_entered.connect(_on_body_entered)

func setup_recall(new_target: Node3D, new_shooter: Node) -> void:
	mode = Mode.RECALL
	target = new_target
	shooter = new_shooter
	remaining_lifetime = lifetime

	if target != null:
		var direction := (target.global_position - global_position).normalized()
		velocity = direction * recall_speed

func setup_hunt(new_target: Node3D, new_damage: int, new_shooter: Node) -> void:
	mode = Mode.HUNT
	target = new_target
	damage = new_damage
	shooter = new_shooter
	remaining_lifetime = lifetime

	if target != null:
		var aim_point := _target_point()
		var direction := (aim_point - global_position).normalized()
		velocity = direction * hunt_speed

func _physics_process(delta: float) -> void:
	if finished:
		return

	remaining_lifetime -= delta

	if remaining_lifetime <= 0.0:
		_finish(&"expired")
		return

	_spin_visual(delta)

	match mode:
		Mode.RECALL:
			_process_recall(delta)
		Mode.HUNT:
			_process_hunt(delta)
		Mode.NONE:
			pass

func _process_recall(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		_finish(&"target_lost")
		return

	var to_target := target.global_position - global_position
	var distance := to_target.length()

	if distance <= catch_distance:
		finished = true
		reached_hand.emit()
		queue_free()
		return

	var direction := to_target.normalized()
	velocity = direction * recall_speed
	global_position += velocity * delta

func _process_hunt(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		_finish(&"target_lost")
		return

	var desired := (_target_point() - global_position).normalized()

	if velocity.length_squared() <= 0.0001:
		velocity = desired * hunt_speed
	else:
		var current := velocity.normalized()
		var angle := current.angle_to(desired)
		var max_turn := deg_to_rad(hunt_turn_rate_deg) * delta
		var t := 1.0

		if angle > 0.0001:
			t = minf(1.0, max_turn / angle)

		var new_direction := current.slerp(desired, t).normalized()
		velocity = new_direction * hunt_speed

	global_position += velocity * delta

func _target_point() -> Vector3:
	if target == null:
		return global_position

	return target.global_position + Vector3.UP * 0.85

func _spin_visual(delta: float) -> void:
	if visual == null:
		return

	visual.rotate_object_local(
		Vector3.RIGHT,
		deg_to_rad(spin_speed_deg) * delta
	)

func _on_body_entered(body: Node) -> void:
	if finished:
		return

	if body == shooter:
		return

	if mode == Mode.RECALL:
		return

	if mode == Mode.HUNT:
		if body.is_in_group("player"):
			if body.has_method("take_damage"):
				body.take_damage(damage)

			_finish(&"hit")
			return

		# Primo prototipo: il martello non si distrugge sulle pareti.
		# Continua a inseguire il giocatore.

func _finish(reason: StringName) -> void:
	if finished:
		return

	finished = true
	flight_finished.emit(reason, global_position)
	queue_free()
