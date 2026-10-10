extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var map := load("res://scenes/maps/map_test.tscn") as PackedScene
	var scene := map.instantiate()
	var boss = scene.get_node("BrunoBuozzi")
	if "--without-mouth" in OS.get_cmdline_user_args():
		boss.get_node("MouthIntegration").free()
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await physics_frame
	await physics_frame
	var player = scene.get_node("Player")
	player.set_physics_process(false)
	player.set_process(false)
	var start: Vector3 = scene.get_node("BrunoCinematicPoint1").global_position
	start.y = boss.global_position.y
	boss.global_position = start
	boss.visible = true
	boss.start_boss_fight()
	print("MOVEMENT_CONFIG mouth=", not "--without-mouth" in OS.get_cmdline_user_args(), " start=", start, " player=", player.global_position, " radius=", boss.body_collision_shape.shape.radius)
	for second in range(15):
		await create_timer(1.0).timeout
		var hits: Array[String] = []
		for index in boss.get_slide_collision_count():
			var collider = boss.get_slide_collision(index).get_collider()
			if collider is Node:
				hits.append(String(collider.get_path()) + " normal=" + str(boss.get_slide_collision(index).get_normal()) + " point=" + str(boss.get_slide_collision(index).get_position()))
		print("MOVEMENT_TRACE t=", second, " pos=", boss.global_position, " state=", boss.state, " direction=", boss.boss_debug_last_nav_reason, " index=", boss.navigation_agent.get_current_navigation_path_index(), " path=", boss.navigation_agent.get_current_navigation_path(), " hits=", hits)
	for radius in [0.15, 0.10]:
		boss.global_position = start
		boss.body_collision_shape.shape.radius = radius
		boss._invalidate_navigation_target()
		await create_timer(10.0).timeout
		print("MOVEMENT_RADIUS_PROBE radius=", radius, " pos=", boss.global_position)
	# Probe waypoint tolerance separately, keeping the original body radius.
	boss.global_position = start
	boss.body_collision_shape.shape.radius = 0.18
	boss.navigation_agent.path_desired_distance = 0.20
	boss._invalidate_navigation_target()
	await create_timer(10.0).timeout
	print("MOVEMENT_WAYPOINT_PROBE distance=0.20 pos=", boss.global_position)
	var wall = scene.get_node("connesi_building_test2/Mura Interne Alte/Parete_013")
	var wall_shape = wall.get_node("StaticBody3D/CollisionShape3D")
	print("MOVEMENT_WALL visual_class=", wall.get_class(), " relative_transform=", wall.global_transform.affine_inverse() * wall_shape.global_transform)
	if wall is MeshInstance3D:
		var physical_bounds := AABB()
		var vertices: PackedVector3Array = wall_shape.shape.get_faces()
		if not vertices.is_empty():
			physical_bounds.position = vertices[0]
			for vertex in vertices:
				physical_bounds = physical_bounds.expand(vertex)
		print("MOVEMENT_WALL visual_bounds=", wall.mesh.get_aabb(), " collision_bounds=", physical_bounds)
		wall_shape.shape = wall.mesh.create_trimesh_shape()
		boss.global_position = start
		boss.body_collision_shape.shape.radius = 0.18
		boss.navigation_agent.path_desired_distance = 0.35
		boss._invalidate_navigation_target()
		await create_timer(10.0).timeout
		print("MOVEMENT_WALL_REGENERATED_PROBE pos=", boss.global_position)
	scene.queue_free()
	await process_frame
	quit()
