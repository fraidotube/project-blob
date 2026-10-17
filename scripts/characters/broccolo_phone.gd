extends Node
## Gestisce il telefono di scena senza alterare la posa preparata sulla mano.

signal thrown_phone_floor_contacted
signal thrown_phone_impact(body: Node)

@export_group("Collegamenti")
## Istanza originale agganciata alla mano: lo script ne cambia solo la visibilita.
@export var phone_visual: Node3D
## Modello separato usato esclusivamente durante il lancio.
@export var phone_scene: PackedScene
## AnimationPlayer che riproduce la clip trow2.
@export var animation_player: AnimationPlayer

@export_group("Lancio")
## Istante della clip trow2 in cui sostituire il telefono in mano.
@export_range(0.0, 3.0, 0.01) var hide_at_throw_seconds := 0.76
## Velocita' iniziale orizzontale approssimativa della copia (m/s).
@export_range(0.5, 10.0, 0.1) var throw_speed := 3.2
## Spinta verticale iniziale della copia (m/s).
@export_range(0.0, 8.0, 0.1) var throw_upward_speed := 2.0
## Rotazione della copia durante il volo (radianti/s).
@export_range(0.0, 20.0, 0.1) var throw_spin := 7.0
## Tempo massimo prima di rimuovere la copia lanciata.
@export_range(2.0, 15.0, 0.5) var throw_lifetime_seconds := 9.0
@export_range(0.0, 1.0, 0.05) var bounce := 0.35

var sequence: Node
var thrown_phone: RigidBody3D
var throw_elapsed := 0.0
var last_hand_position := Vector3.ZERO
var has_hand_sample := false
var throw_pending := false
var throw_started := false
var completed := false
var initial_visibility := false
var last_throw_direction := Vector3.ZERO
var throw_direction_from_hand := false

func _ready() -> void:
	if phone_visual == null or phone_scene == null or animation_player == null:
		push_error("BroccoloPhone: collegare telefono in mano, modello lanciato e AnimationPlayer.")
		set_process(false)
		return
	initial_visibility = phone_visual.visible
	phone_visual.hide()
	set_process(true)

func bind_sequence(value: Node) -> void:
	sequence = value
	if sequence != null and sequence.has_signal("stage_changed"):
		var callback := Callable(self, "_on_stage_changed")
		if not sequence.stage_changed.is_connected(callback):
			sequence.stage_changed.connect(callback)

func _on_stage_changed(stage: String) -> void:
	if stage in ["answer", "phone"]:
		if not completed and not throw_started:
			phone_visual.show()
			throw_pending = false
	elif stage == "throw":
		throw_pending = true
		throw_started = false
		phone_visual.show()
	else:
		if not throw_started:
			phone_visual.hide()
		if stage in ["walk", "phone_idle", "intro_ready"]:
			completed = true

func _process(delta: float) -> void:
	if thrown_phone != null and is_instance_valid(thrown_phone):
		throw_elapsed += delta
		if throw_elapsed >= throw_lifetime_seconds and is_instance_valid(thrown_phone):
			thrown_phone.queue_free()
			thrown_phone = null
	if phone_visual == null or not is_instance_valid(phone_visual):
		return
	var hand_velocity := Vector3.ZERO
	var current_hand_position := phone_visual.global_position
	if has_hand_sample and delta > 0.0001:
		hand_velocity = (current_hand_position - last_hand_position) / delta
	if throw_pending and not throw_started and _throw_animation_reached_release():
		_launch_copy(hand_velocity)
	if phone_visual.visible:
		last_hand_position = current_hand_position
		has_hand_sample = true

func _throw_animation_reached_release() -> bool:
	if animation_player == null or animation_player.assigned_animation != &"mie/trow2":
		return false
	return animation_player.current_animation_position >= hide_at_throw_seconds

func _launch_copy(hand_velocity: Vector3) -> void:
	throw_started = true
	throw_pending = false
	var source_transform: Transform3D = phone_visual.global_transform
	var actor := get_parent() as Node3D
	var hand_direction := Vector3(hand_velocity.x, 0.0, hand_velocity.z)
	throw_direction_from_hand = hand_direction.length_squared() > 0.0025
	if throw_direction_from_hand:
		last_throw_direction = hand_direction.normalized()
	else:
		last_throw_direction = -actor.global_basis.z if actor != null else Vector3.FORWARD
		last_throw_direction.y = 0.0
		if last_throw_direction.length_squared() < 0.001:last_throw_direction = Vector3.FORWARD
		last_throw_direction = last_throw_direction.normalized()
	var horizontal := last_throw_direction * throw_speed
	phone_visual.hide()
	var thrown_visual := phone_scene.instantiate() as Node3D
	if thrown_visual == null:
		push_error("BroccoloPhone: la scena del telefono lanciato non ha una radice Node3D.")
		return
	thrown_phone = RigidBody3D.new()
	thrown_phone.set_script(preload("res://scripts/characters/broccolo_thrown_phone.gd"))
	thrown_phone.name = "BroccoloThrownPhone"
	thrown_phone.mass = 0.18
	thrown_phone.gravity_scale = 1.0
	thrown_phone.collision_layer = 0
	thrown_phone.collision_mask = 1
	thrown_phone.continuous_cd = true
	thrown_phone.contact_monitor = true
	thrown_phone.max_contacts_reported = 4
	var material := PhysicsMaterial.new()
	material.bounce = bounce
	material.friction = 0.65
	thrown_phone.physics_material_override = material
	thrown_phone.angular_damp = 3.0
	var collider := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.055
	collider.shape = sphere
	thrown_phone.add_child(collider)
	get_tree().current_scene.add_child(thrown_phone)
	thrown_phone.global_transform = Transform3D(source_transform.basis.orthonormalized(), source_transform.origin)
	thrown_phone.add_child(thrown_visual)
	thrown_visual.global_transform = source_transform
	thrown_phone.body_entered.connect(_on_thrown_body_entered)
	thrown_phone.floor_contacted.connect(_on_thrown_floor_contacted)
	var actor_body := get_parent() as CollisionObject3D
	if actor_body != null:thrown_phone.add_collision_exception_with(actor_body)
	var player_body := get_tree().get_first_node_in_group("player") as CollisionObject3D
	if player_body != null:thrown_phone.add_collision_exception_with(player_body)
	thrown_phone.linear_velocity = horizontal + Vector3.UP * throw_upward_speed
	thrown_phone.angular_velocity = Vector3(1.0, 0.35, 0.2).normalized() * throw_spin
	throw_elapsed = 0.0
	print("BROCCOLO_PHONE_THROW origin=", source_transform.origin, " direction=", last_throw_direction, " hand_driven=", throw_direction_from_hand, " velocity=", thrown_phone.linear_velocity)

func _on_thrown_body_entered(body: Node) -> void:
	thrown_phone_impact.emit(body)

func _on_thrown_floor_contacted() -> void:
	if not is_instance_valid(thrown_phone):return
	thrown_phone_floor_contacted.emit()
	thrown_phone.queue_free()
	thrown_phone = null

func get_save_state() -> Dictionary:
	return {"thrown": completed or throw_started, "completed": completed}

func apply_save_state(data: Dictionary) -> void:
	_remove_thrown_phone()
	throw_pending = false
	throw_started = false
	completed = bool(data.get("completed", data.get("thrown", false)))
	phone_visual.visible = initial_visibility and not completed

func reset_phone() -> void:
	_remove_thrown_phone()
	throw_pending = false
	throw_started = false
	completed = false
	phone_visual.hide()

func _remove_thrown_phone() -> void:
	if is_instance_valid(thrown_phone):
		thrown_phone.queue_free()
	thrown_phone = null
	throw_elapsed = 0.0
