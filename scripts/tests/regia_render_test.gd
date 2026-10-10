extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, label: String) -> void:
	if not value:
		failures += 1
		push_error(label)

func capture(file: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/" + file + ".png")

func click(point: Vector2) -> void:
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = point
		event.global_position = point
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		root.push_input(event, true)
		await process_frame

func run() -> void:
	var saves := root.get_node("SaveManager")
	var ui := root.get_node("GameplayUI")
	saves.save_path = "res://.godot/regia_render_slot.cfg"
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1920, 1080)
	change_scene_to_file("res://scenes/maps/map_test.tscn")
	await process_frame
	await process_frame
	await physics_frame
	var integration = current_scene.get_node("RegiaIntegration")
	var pc = integration.pc
	check(await ui.open_terminal(pc), "Real PC terminal did not open")
	await capture("regia_pc")
	var button: Button = pc.save_button
	var uv := button.get_global_rect().get_center() / Vector2(pc.viewport.size)
	var size: Vector2 = pc.screen_size
	var world: Vector3 = pc.screen.global_transform * Vector3((uv.x - 0.5) * size.x, (0.5 - uv.y) * size.y, 0)
	await click(root.get_camera_3d().unproject_position(world))
	check(pc.status_label.text == "SALVATAGGIO COMPLETATO", "Real monitor save click failed")
	await capture("regia_pc_saved")
	ui.close_immediately()
	var camera := Camera3D.new()
	current_scene.add_child(camera)
	camera.current = true
	var door = integration.regia_door
	var center: Vector3 = door.global_position + Vector3(0, 0, 0.4)
	var light := OmniLight3D.new()
	light.light_energy = 2.0
	light.omni_range = 6.0
	current_scene.add_child(light)
	light.global_position = center + Vector3(-1, 1, 0)
	camera.global_position = center + Vector3(-2, 0.25, -0.4)
	camera.look_at(center)
	await capture("regia_door_closed")
	door.open_door()
	await create_timer(1.8).timeout
	await capture("regia_door_open")
	print("REGIA_RENDER_TEST failures=", failures)
	current_scene.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
