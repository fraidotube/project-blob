extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	change_scene_to_file("res://scenes/levels/angelastri_vfx_test.tscn")
	await process_frame
	while current_scene == null: await process_frame
	current_scene.automatic = false
	if DisplayServer.get_name() != "headless": root.size = Vector2i(1280, 720)
	current_scene.show_effect(0)
	await create_timer(0.12).timeout
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/angelastri_blood_preview.png")
	await current_scene.show_effect(2)
	await create_timer(0.04).timeout
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/angelastri_arc3d_preview.png")
	print("ANGELASTRI_VFX_PREVIEW_TEST passed")
	quit()
