extends SceneTree

var failures := 0

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var world := Node3D.new()
	var panel := MeshInstance3D.new()
	panel.mesh = BoxMesh.new()
	panel.mesh.size = Vector3(1.0, 2.0, 0.04)
	panel.position = Vector3(0.5, 1.0, 0)
	world.add_child(panel)
	var manager = load("res://scripts/systems/warehouse_doors_integration.gd").new()
	manager.name = "WarehouseDoors"
	var config = load("res://scripts/interactables/warehouse_door_setup.gd").new()
	config.source_visual = panel
	config.runtime_name = &"ContactDoor"
	config.persistent_id = &"test.contact.door"
	config.width_axis = 0
	config.hinge_at_max = false
	config.contact_push_enabled = true
	manager.add_child(config)
	world.add_child(manager)
	panel.owner = world
	manager.owner = world
	config.owner = world
	var packed := PackedScene.new()
	check(packed.pack(world) == OK, "Configurazione non serializzabile")
	check(ResourceSaver.save(packed, "res://.godot/contact_push_fixture.tscn") == OK, "Salvataggio fixture fallito")
	world.free()
	packed = load("res://.godot/contact_push_fixture.tscn")
	world = packed.instantiate()
	root.add_child(world)
	current_scene = world
	manager = world.get_node("WarehouseDoors")
	await process_frame
	await physics_frame
	var door = manager.doors[0]
	check(door.contact_push_enabled and door.contact_push_speed == 2.0, "Tuning non applicato")
	var actor := CharacterBody3D.new()
	actor.name = "Player"
	actor.collision_layer = 1
	actor.collision_mask = 3
	actor.add_to_group("player")
	var capsule := CollisionShape3D.new()
	capsule.name = "CollisionShape3D"
	capsule.shape = CapsuleShape3D.new()
	capsule.shape.radius = 0.3
	capsule.shape.height = 1.8
	capsule.position.y = 0.9
	actor.add_child(capsule)
	world.add_child(actor)
	actor.position = Vector3(0.7, 0, -0.4)
	await physics_frame
	var start := actor.position
	door.open_door()
	check(door.is_open and not door.retreating, "Apertura bloccata dal settore preventivo")
	for frame in 240: await physics_frame
	check(actor.position.distance_to(start) > 0.05, "Il contatto non sposta il player")
	check(absf(angle_difference(door.rotation.y, deg_to_rad(90))) < 0.01, "Apertura non completata")
	actor.position = Vector3(0.7, 0, -0.2)
	await physics_frame
	start = actor.position
	door.close_door()
	check(not door.is_open, "Chiusura rifiutata dal settore preventivo")
	for frame in 240:
		await physics_frame
		check(not door.is_open, "Chiusura riapre al passaggio")
	check(actor.position.distance_to(start) > 0.05, "Chiusura non sposta il player")
	check(absf(door.rotation.y) < 0.01, "Chiusura non completata")
	check(actor.get_collision_exceptions().is_empty(), "Eccezioni fisiche lasciate attive")
	# A wall behind the player must stop the leaf instead of crushing/teleporting.
	var wall := StaticBody3D.new()
	wall.collision_layer = 2
	var wall_shape := CollisionShape3D.new()
	wall_shape.shape = BoxShape3D.new()
	wall_shape.shape.size = Vector3(4, 3, 0.1)
	wall.add_child(wall_shape)
	wall.position = Vector3(0.5, 1, -0.8)
	world.add_child(wall)
	actor.position = Vector3(0.7, 0, -0.4)
	await physics_frame
	door.open_door()
	for frame in 180: await physics_frame
	check(actor.position.z > -0.46, "Spinta attraversa il muro")
	check(door.rotation.y < deg_to_rad(85), "Porta attraversa player bloccato")
	actor.position = Vector3(4, 0, 4)
	for frame in 180: await physics_frame
	check(absf(angle_difference(door.rotation.y, deg_to_rad(90))) < 0.01, "Porta non riprende quando libera")
	world.queue_free()
	await process_frame
	print("WAREHOUSE_CONTACT_PUSH_TEST failures=", failures)
	quit(failures)
