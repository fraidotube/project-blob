extends SceneTree
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func own_branch(node: Node, scene: Node) -> void:
	for child in node.get_children():
		child.owner = scene
		own_branch(child, scene)
func run() -> void:
	var world := Node3D.new()
	var leaf := Node3D.new()
	leaf.name = "Leaf"
	world.add_child(leaf)
	for index in 3:
		var mesh := MeshInstance3D.new()
		mesh.name = "Part" + str(index)
		mesh.mesh = BoxMesh.new()
		mesh.mesh.size = Vector3(0.05, 0.1, 1.0)
		mesh.position.y = index * 0.95 + 0.05
		leaf.add_child(mesh)
	var manager = load("res://scripts/systems/warehouse_doors_integration.gd").new()
	manager.name = "WarehouseDoors"
	var config = load("res://scripts/interactables/warehouse_door_setup.gd").new()
	config.name = "Composite"
	config.source_visual = leaf
	config.runtime_name = &"CompoundDoor"
	config.persistent_id = &"test.compound.door"
	config.open_angle = -75.0
	config.hinge_at_max = false
	for index in 3: config.panel_parts.append(NodePath("../../Leaf/Part" + str(index)))
	manager.add_child(config)
	world.add_child(manager)
	own_branch(world,world)
	var packed := PackedScene.new()
	check(packed.pack(world) == OK, "Anta composta non serializzabile")
	check(ResourceSaver.save(packed,"res://.godot/compound_door_fixture.tscn") == OK,"Fixture non salvata")
	world.free()
	packed = load("res://.godot/compound_door_fixture.tscn")
	world = packed.instantiate()
	root.add_child(world)
	current_scene = world
	await process_frame
	await process_frame
	manager = world.get_node("WarehouseDoors")
	config = manager.get_node("Composite")
	check(manager.doors.size() == 1,"Anta composta non costruita")
	check(config.validation_errors().is_empty(),"Riferimenti parti persi dopo riparentazione")
	var door = manager.doors[0]
	check(door.panel_box.shape.size.is_equal_approx(Vector3(0.05,2,1)),"Collider non unisce tutte le parti")
	check(door.open_angle == -75.0,"Angolo serializzato ignorato")
	world.queue_free()
	await process_frame
	print("COMPOUND_DOOR_CONFIGURATION_TEST failures=",failures)
	quit(failures)
