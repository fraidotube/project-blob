extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("Bruno passage: " + message)

func run() -> void:
	change_scene_to_file("res://scenes/maps/map_test.tscn")
	await process_frame
	await physics_frame
	await physics_frame
	var scene = current_scene
	var boss = scene.get_node("BrunoBuozzi")
	var wall = scene.get_node("connesi_building_test2/Mura Interne Alte/Parete_013")
	var collider = wall.get_node("StaticBody3D/CollisionShape3D")
	var expected: PackedVector3Array = wall.mesh.create_trimesh_shape().get_faces()
	var actual: PackedVector3Array = collider.shape.get_faces()
	check(expected.size() == actual.size(), "Wall collider does not match current mesh")
	if actual.size() == expected.size():
		for index in actual.size():
			check(actual[index].is_equal_approx(expected[index]), "Collision vertex mismatch")
	var player = scene.get_node("Player")
	player.set_physics_process(false)
	player.set_process(false)
	var start: Vector3 = scene.get_node("BrunoCinematicPoint1").global_position
	start.y = boss.global_position.y
	boss.global_position = start
	boss.visible = true
	boss.start_boss_fight()
	await create_timer(10.0).timeout
	check(boss.global_position.z > 14.0, "Boss remained blocked at end-of-intro passage")
	check(is_equal_approx(boss.body_collision_shape.shape.radius, 0.18), "Boss collider changed")
	check(boss.get_node("MouthIntegration").motion != null, "Mouth integration missing")
	print("BRUNO_PASSAGE_TEST end=", boss.global_position, " failures=", failures)
	scene.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
