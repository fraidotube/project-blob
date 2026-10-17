extends SceneTree

# Trace only: this does not certify the full intro or all combat routes.

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	change_scene_to_file("res://scenes/maps/map_test.tscn")
	await process_frame
	await physics_frame
	await physics_frame
	var scene := current_scene
	var boss = scene.get_node("BrunoBuozzi")
	var player = scene.get_node("Player")
	player.set_physics_process(false)
	player.set_process(false)
	if "--far-player" in OS.get_cmdline_user_args():
		player.global_position = Vector3(6.8, 0.9, 26.0)
	var door = scene.get_node("connesi_building_test2/Porta Lab Esterna ")
	print("EXIT_DOOR pose=", door.global_transform, " player=", player.global_position)
	var start: Vector3 = scene.get_node("BrunoCinematicPoint1").global_position
	start.y = boss.global_position.y
	boss.global_position = start
	boss.visible = true
	boss.start_boss_fight()
	for second in range(20):
		await create_timer(1.0).timeout
		var hits: Array[String] = []
		for index in boss.get_slide_collision_count():
			var hit = boss.get_slide_collision(index)
			var collider = hit.get_collider()
			if collider is Node:
				hits.append(String(collider.get_path()) + " point=" + str(hit.get_position()) + " normal=" + str(hit.get_normal()))
		print("EXIT_TRACE t=", second, " pos=", boss.global_position, " open=", door.is_open, " forced=", door.forced_open, " reason=", boss.boss_debug_last_nav_reason, " hits=", hits)
	scene.queue_free()
	await process_frame
	quit()
