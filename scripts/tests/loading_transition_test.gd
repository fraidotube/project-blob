extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if DisplayServer.get_name() != "headless":
		root.mode = Window.MODE_WINDOWED
		root.size = Vector2i(1280, 720)
		root.content_scale_size = Vector2i(1920, 1080)
	var transition := root.get_node("SceneTransition")
	paused = true
	var packed: PackedScene = await transition.load_scene("res://scenes/levels/inventory_save_test.tscn", "CARICA SALVATAGGIO")
	assert(packed != null)
	assert(transition.visible and transition.panel.visible and transition._busy)
	assert(transition.title_label.text == "CARICA SALVATAGGIO")
	await create_timer(0.3, true).timeout
	assert(transition.progress_bar.value > 0)
	if not DisplayServer.get_name() == "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/loading_screen.png")
	await transition.reveal()
	assert(not transition.visible and not transition._busy)
	# A resource that exists but is not a scene must release the input overlay.
	var invalid: PackedScene = await transition.load_scene("res://scenes/ui/project_blob_menu_theme.tres", "CARICA SALVATAGGIO")
	assert(invalid == null and not transition.visible and not transition._busy)
	paused = false
	await transition.transition_to("res://scenes/levels/inventory_save_test.tscn")
	assert(current_scene.scene_file_path == "res://scenes/levels/inventory_save_test.tscn")
	assert(not transition.visible and not transition._busy)
	print("LOADING_TRANSITION_TEST_OK")
	quit()
