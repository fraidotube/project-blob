extends Node

const SLIDING := preload("res://scripts/interactables/sliding_door.gd")
const SWING := preload("res://scripts/interactables/door.gd")
const PC := preload("res://scripts/interactables/save_pc_station.gd")
const PERSIST := preload("res://scripts/systems/persistent_object.gd")
const LOOT := preload("res://scripts/systems/boss_loot_drop.gd")
@export_range(0.25, 0.4, 0.01) var player_passage_radius := 0.35
var lab_door: Node3D
var bathroom_door: Node3D
var regia_door: Node3D
var pc: Node3D
var loot: Node
var scene: Node3D

func _ready() -> void:
	call_deferred("_setup")

func _setup() -> void:
	scene = get_parent() as Node3D
	# The current 79.5 cm doorways cannot clear the default 80 cm capsule.
	# Use a private shape for this map; preserve height/crouch/camera/controller.
	var player_shape := scene.get_node("Player/CollisionShape3D") as CollisionShape3D
	if player_shape.shape is CapsuleShape3D:
		var capsule := player_shape.shape.duplicate() as CapsuleShape3D
		capsule.radius = player_passage_radius
		player_shape.shape = capsule
	SaveManager.select_scene_slot(scene.scene_file_path)
	if not SaveManager.restoring:
		SaveManager.start_new_game(scene.scene_file_path)
	var building := scene.get_node("connesi_building_test2")
	lab_door = _sliding(building.get_node("Porta Lab/Porta_011"), &"main.door.lab", true)
	bathroom_door = _sliding(building.get_node("Porta Bagno Regia"), &"main.door.bath_regia", false)
	regia_door = _swing(building.get_node("Porta Regia"))
	pc = _pc(building.get_node("PCRegia/Collada visual scene group_003/Computer_Low"))
	loot = LOOT.new()
	loot.name = "BrunoLoot"
	loot.persistent_id = &"main.bruno"
	loot.loot_id = &"main.bruno_key"
	loot.boss = scene.get_node("BrunoBuozzi")
	loot.cinematic_controller = scene.get_node("BrunoIntroController")
	add_child(loot)
	_persistent(scene.get_node("ConnesiPower"), &"main.power", 4)
	_persistent(building.get_node("Monitor Appeso"), &"main.tv", 5)
	_persistent(scene.get_node("MeteoriteAudioTrigger"), &"main.meteorite", 3)
	_persistent(scene.get_node("BrunoFightEnvironment"), &"main.boss_environment", 6)
	_persistent(building.get_node("Porta Lab Esterna "), &"main.door.lab_external", 2)
	for node in scene.get_children():
		if node.has_method("interact") and _has_property(node, &"collected"):
			_persistent(node, StringName("main.pickup." + String(node.name)), 1)
	print("REGIA_MAP_INTEGRATED doors=3 pc=1 loot=1 participants=", SaveManager.participants.size())

func _has_property(node: Node, property: StringName) -> bool:
	for info in node.get_property_list():
		if StringName(info.name) == property:
			return true
	return false

func _persistent(target: Node, id: StringName, kind: int) -> void:
	var adapter := PERSIST.new()
	adapter.persistent_id = id
	adapter.target = target
	adapter.kind = kind
	# Pickup adapters must exit together with their collected target so the
	# collected flag survives queue_free and no freed target stays registered.
	target.add_child(adapter)

func _meshes(node: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	if node is MeshInstance3D:
		result.append(node)
	for child in node.get_children():
		result.append_array(_meshes(child))
	return result

func _bounds(source: Node3D, frame: Transform3D) -> AABB:
	var bounds := AABB()
	var first := true
	for mesh in _meshes(source):
		var box := frame.affine_inverse() * mesh.global_transform * mesh.get_aabb()
		bounds = box if first else bounds.merge(box)
		first = false
	return bounds

func _disable_old_collisions(node: Node) -> void:
	if node is CollisionObject3D:
		node.collision_layer = 0
		node.collision_mask = 0
	for child in node.get_children():
		_disable_old_collisions(child)

func _move_visual(source: Node3D, body: Node3D, frame: Transform3D) -> void:
	var pose := source.global_transform
	_disable_old_collisions(source)
	source.get_parent().remove_child(source)
	body.add_child(source)
	source.top_level = false
	source.transform = frame.affine_inverse() * pose

func _box(parent: Node3D, box: AABB) -> void:
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(maxf(box.size.x, 0.06), maxf(box.size.y, 0.06), maxf(box.size.z, 0.06))
	collider.shape = shape
	collider.position = box.get_center()
	parent.add_child(collider)

func _area(parent: Node3D, box: AABB, name: String) -> Area3D:
	var area := Area3D.new()
	area.name = name
	area.collision_layer = 0
	area.collision_mask = 1
	_box(area, AABB(box.position - Vector3(0.12, 0, 0.4), box.size + Vector3(0.24, 0, 0.8)))
	parent.add_child(area)
	return area

func _sliding(source: Node3D, id: StringName, keyed: bool) -> Node3D:
	var frame := Transform3D(Basis.IDENTITY, source.global_position)
	var bounds := _bounds(source, frame)
	var door := SLIDING.new()
	door.name = "LabSlidingDoor" if keyed else "BathroomSlidingDoor"
	door.persistent_id = id
	door.required_key = &"bruno_key" if keyed else &""
	door.generate_test_geometry = false
	# Both verified panels lie across world X. Left from their +Z front.
	door.open_offset = Vector3(-bounds.size.x - 0.08, 0, 0)
	door.transform = scene.global_transform.affine_inverse() * frame
	var panel := AnimatableBody3D.new()
	panel.name = "Panel"
	panel.collision_layer = 3
	panel.sync_to_physics = false
	door.add_child(panel)
	_box(panel, bounds)
	_area(door, bounds, "Passage")
	_move_visual(source, panel, frame)
	scene.add_child(door)
	return door

func _swing(source: Node3D) -> Node3D:
	var panel := source.get_node("Porta_009") as Node3D
	# Restore the imported closed panel orientation; preserve its pivot/scale.
	panel.rotation = Vector3.ZERO
	var frame := Transform3D(Basis.IDENTITY, panel.global_position)
	var bounds := _bounds(source, frame)
	var door := SWING.new()
	door.name = "RegiaSwingDoor"
	door.interaction_name = "PORTA REGIA"
	door.open_sound = load("res://assets/audio/interactions/door/lab_metal-door-open.wav")
	door.close_sound = load("res://assets/audio/interactions/door/lab_metal-door-closing.wav")
	door.transform = scene.global_transform.affine_inverse() * frame
	door.open_angle = -90.0
	var body := AnimatableBody3D.new()
	body.name = "DoorBody"
	body.collision_layer = 3
	body.sync_to_physics = false
	door.add_child(body)
	_box(body, bounds)
	_area(door, bounds, "Area3D")
	_move_visual(source, body, frame)
	scene.add_child(door)
	_persistent(door, &"main.door.regia", 2)
	return door

func _pc(monitor: Node3D) -> Node3D:
	var station := PC.new()
	station.name = "RegiaSavePC"
	station.persistent_id = &"main.pc.regia"
	station.generate_test_geometry = false
	var scale := monitor.global_basis.get_scale()
	station.transform = scene.global_transform.affine_inverse() * Transform3D(monitor.global_basis.orthonormalized(), monitor.global_position)
	# Front display plane verified in the current monitor triangles (normal +Z).
	station.screen_origin = Vector3(-0.1552 * scale.x, 0.17645 * scale.y, -0.228 * scale.z)
	station.screen_size = Vector2(1.42 * scale.x, 0.865 * scale.y)
	scene.add_child(station)
	return station
