extends "res://scripts/interactables/persistent_interactable.gd"
class_name SlidingKeyDoor

@export var required_key: StringName = &"bruno_key"
@export var open_offset := Vector3(2.1, 0, 0)
@export var slide_speed := 1.8
@export var generate_test_geometry := true
@export var panel_path: NodePath = NodePath("Panel")
@export var passage_path: NodePath = NodePath("Passage")
@export var open_sound: AudioStream
@export var close_sound: AudioStream
var unlocked := false
var is_open := false
var moving := false
var panel: AnimatableBody3D
var passage: Area3D
var _closed := Vector3.ZERO
var _audio: AudioStreamPlayer3D

func _ready() -> void:
	interaction_name = "PORTA SCORREVOLE"
	unlocked = required_key.is_empty()
	if generate_test_geometry:
		panel = AnimatableBody3D.new()
		panel.name = "Panel"
		panel.collision_layer = 3
		panel.sync_to_physics = false
		add_child(panel)
		_box(panel, Vector3(1.8, 2.4, 0.16), Vector3(0, 1.2, 0), Color(0.24, 0.32, 0.4))
		var collider := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = Vector3(1.8, 2.4, 0.16)
		collider.shape = shape
		collider.position.y = 1.2
		panel.add_child(collider)
		_box(self, Vector3(2.2, 0.18, 0.26), Vector3(0, 2.5, 0), Color(0.1, 0.14, 0.19))
		_interaction_box(Vector3(1.9, 2.5, 0.22), Vector3(0, 1.25, 0))
		passage = Area3D.new()
		passage.name = "Passage"
		passage.collision_layer = 0
		passage.collision_mask = 1
		var zone := CollisionShape3D.new()
		var zone_shape := BoxShape3D.new()
		zone_shape.size = Vector3(2.0, 2.5, 0.9)
		zone.shape = zone_shape
		zone.position.y = 1.25
		passage.add_child(zone)
		add_child(passage)
	else:
		panel = get_node_or_null(panel_path) as AnimatableBody3D
		passage = get_node_or_null(passage_path) as Area3D
	if panel == null or passage == null:
		push_error("Sliding door: assign an AnimatableBody3D panel and a passage Area3D.")
		set_physics_process(false)
		return
	panel.sync_to_physics = false
	_closed = panel.position
	_audio = AudioStreamPlayer3D.new()
	_audio.bus = &"SFX"
	add_child(_audio)
	super._ready()

func get_interaction_action() -> String:
	if moving:
		return "IN MOVIMENTO"
	if not unlocked:
		return "SBLOCCA" if InventoryManager.has_item(required_key) else "SERVE LA CHIAVE"
	return "CHIUDI" if is_open else "APRI"

func interact(_player: Node) -> void:
	if moving or panel == null:
		return
	if not unlocked:
		if not InventoryManager.has_item(required_key):
			GameplayUI.notify("Serve la chiave di Bruno.")
			return
		unlocked = true
	if is_open and _occupied():
		GameplayUI.notify("Passaggio occupato.")
		return
	is_open = not is_open
	moving = true
	_audio.stream = open_sound if is_open else close_sound
	if _audio.stream != null:
		_audio.play()

func _physics_process(delta: float) -> void:
	if not moving or panel == null:
		return
	if not is_open and _occupied():
		is_open = true
	var target_position := _closed + open_offset if is_open else _closed
	panel.position = panel.position.move_toward(target_position, slide_speed * delta)
	if panel.position.is_equal_approx(target_position):
		moving = false

func _occupied() -> bool:
	for body: Node3D in passage.get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false

func blocks_saving() -> bool:
	return moving

func get_persistent_state() -> Dictionary:
	return {"unlocked": unlocked, "open": is_open}

func apply_persistent_state(state: Dictionary) -> void:
	unlocked = required_key.is_empty() or bool(state.get("unlocked", false))
	is_open = unlocked and bool(state.get("open", false))
	moving = false
	panel.position = _closed + open_offset if is_open else _closed
