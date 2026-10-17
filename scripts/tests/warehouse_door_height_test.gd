extends SceneTree

class ProbePlayer extends CharacterBody3D:
	var is_dead := false

var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func run() -> void:
	var world := Node3D.new()
	root.add_child(world)
	current_scene = world
	var player := ProbePlayer.new()
	player.name = "Player"
	player.add_to_group("player")
	var capsule := CollisionShape3D.new()
	capsule.name = "CollisionShape3D"
	capsule.shape = CapsuleShape3D.new()
	capsule.shape.radius = 0.32
	capsule.shape.height = 1.8
	player.add_child(capsule)
	world.add_child(player)
	player.position = Vector3(-0.4,0.9,-0.4)
	var door = load("res://scripts/interactables/warehouse_swing_door.gd").new()
	door.persistent_id = &"test.elevated.door"
	door.position.y = 2.440907
	door.closed_center = Vector3(0,3.500907,-0.4)
	door.opening_normal = Vector3.LEFT
	door.open_angle = 90.0
	var body := AnimatableBody3D.new()
	body.name = "DoorBody"
	body.collision_layer = 3
	body.collision_mask = 0
	body.sync_to_physics = false
	var panel := CollisionShape3D.new()
	panel.shape = BoxShape3D.new()
	panel.shape.size = Vector3(0.035,2.12,0.8)
	panel.position = Vector3(0,1.06,-0.4)
	body.add_child(panel)
	door.panel_box = panel
	door.add_child(body)
	var area := Area3D.new()
	area.name = "Area3D"
	door.add_child(area)
	world.add_child(door)
	await physics_frame
	var below_pose := player.global_transform
	door.interact(player)
	check(door.is_open and not door.retreating, "Porta superiore trascina il player al piano inferiore")
	await create_timer(0.2).timeout
	check(player.global_transform == below_pose, "Player spostato dall'altro piano")
	door.apply_persistent_state({})
	await physics_frame
	await process_frame
	player.position.y = 3.350907
	player.set_physics_process(true)
	await physics_frame
	await process_frame
	door.interact(player)
	check(door.retreating and not player.is_physics_processing(), "Protezione stesso piano non attiva")
	await create_timer(0.7).timeout
	check(door.is_open and not door.retreating and player.is_physics_processing(), "Arretramento non ripristina fisica")
	print("WAREHOUSE_DOOR_HEIGHT_TEST failures=",failures)
	quit(failures)
