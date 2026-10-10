extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func wait_frame() -> void:
	await process_frame
	await RenderingServer.frame_post_draw

func click(point: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = point
	motion.global_position = point
	root.push_input(motion, true)
	for pressed: bool in [true, false]:
		var button := InputEventMouseButton.new()
		button.position = point
		button.global_position = point
		button.button_index = MOUSE_BUTTON_LEFT
		button.pressed = pressed
		root.push_input(button, true)
		await process_frame

func press(key: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = true
	root.push_input(event, true)

func _run() -> void:
	var saves := root.get_node("SaveManager")
	var ui := root.get_node("GameplayUI")
	saves.save_path = "res://.godot/connesios_render_slot.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(saves.save_path))
	# A temporary test window, independent of the user's persisted video settings.
	root.mode = Window.MODE_WINDOWED
	root.position = Vector2i(20000, 20000)
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1920, 1080)
	change_scene_to_file("res://scenes/levels/inventory_save_test.tscn")
	await create_timer(0.5).timeout
	var player: Node3D = current_scene.get("player")
	var pc: Node3D = current_scene.get("pc")
	var initial_camera := root.get_camera_3d()
	check(await ui.open_terminal(pc), "terminal opens")
	# The demo's debug legend is not part of the in-game UI.
	for label: Node in current_scene.find_children("*", "Label", true, false):
		if label.get("text").begins_with("PROVA INVENTARIO"):
			label.hide()
	await wait_frame()
	root.get_texture().get_image().save_png("res://.godot/connesios_monitor.png")
	var camera := root.get_camera_3d()
	var button: Button = pc.get("save_button")
	var uv := button.get_global_rect().get_center() / Vector2(pc.get("viewport").size)
	var screen: Node3D = pc.get("screen")
	var size: Vector2 = pc.get("screen_size")
	var world := screen.global_transform * Vector3((uv.x - 0.5) * size.x, (0.5 - uv.y) * size.y, 0)
	await click(camera.unproject_position(world))
	check(saves.has_disk_save(), "real mouse click reaches save button through 3D screen")
	check(pc.get("status_label").text == "SALVATAGGIO COMPLETATO", "save reports success")
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	root.push_input(escape, true)
	await create_timer(0.6, true).timeout
	check(ui.modal.is_empty() and not paused and root.get_camera_3d() == initial_camera, "Escape restores camera and gameplay")
	check(player.get_node("Head/Camera3D/WeaponHolder").visible, "viewmodel restored")
	current_scene.get("bruno").call("_die")
	await create_timer(0.2).timeout
	var key: Node = saves.participants.get(&"demo.bruno_key")
	key.call("interact", player)
	await create_timer(0.25).timeout
	await wait_frame()
	var notice: Control = ui.get("_notice")
	var interface: Control = get_first_node_in_group("hud").get_node("Interface")
	var hud_bar: Control = interface.get_node("HudBar/HudBackground")
	check(notice.visible and notice.get_global_rect().end.y < hud_bar.get_global_rect().position.y, "pickup notice occupies dedicated space above HUD")
	root.get_texture().get_image().save_png("res://.godot/inventory_pickup_notice.png")
	interface.visible = false
	await process_frame
	await process_frame
	check(not notice.visible, "pickup notice follows cinematic/death HUD visibility")
	interface.visible = true
	check(ui.open_inventory(), "inventory opens")
	await wait_frame()
	root.get_texture().get_image().save_png("res://.godot/inventory_panel.png")
	var list: ItemList = ui.get("_list")
	check(list.item_count == 1, "inventory displays key")
	var close: Button = ui.get("_inventory").find_children("*", "Button", true, false)[0]
	await click(close.get_global_rect().get_center())
	check(ui.modal.is_empty() and not paused, "inventory mouse close button works")
	# Check a second real window size without changing settings.cfg.
	root.size = Vector2i(1600, 900)
	await create_timer(0.15).timeout
	check(ui.open_inventory(), "inventory opens after resize")
	await wait_frame()
	var dossier: Control = ui.get("_inventory")
	check(dossier.size.y < dossier.size.x, "inventory keeps dossier proportions")
	check(Rect2(Vector2.ZERO, root.get_visible_rect().size).encloses(dossier.get_global_rect()), "inventory stays inside resized viewport")
	root.get_texture().get_image().save_png("res://.godot/inventory_panel_1600.png")
	ui.close_immediately()
	root.get_node("InventoryManager").remove_item(&"bruno_key")
	current_scene.get("door").call("interact", player)
	await create_timer(0.25).timeout
	await wait_frame()
	check(not ui.get("_notice_hint").visible, "locked-door warning has no isolated inventory shortcut")
	root.get_texture().get_image().save_png("res://.godot/door_missing_key.png")
	press(KEY_ESCAPE)
	await wait_frame()
	var pause := root.get_node("PauseMenu")
	check(pause.is_open and not pause.load_button.disabled, "pause offers Load Save")
	root.get_texture().get_image().save_png("res://.godot/pause_load_save.png")
	await click(pause.load_button.get_global_rect().get_center())
	await saves.restore_completed
	check(not paused and not pause.is_open, "pause click loads and closes menu")
	player = current_scene.get("player")
	player.call("take_damage", 10000)
	await create_timer(2.0).timeout
	await wait_frame()
	check(player.get_node("DeathScreen/Root/ContinuePrompt").text.contains("PREMI C"), "death shows C when saved")
	root.get_texture().get_image().save_png("res://.godot/death_continue.png")
	press(KEY_C)
	await saves.restore_completed
	check(not bool(current_scene.get("player").get("is_dead")), "real C key continues")
	current_scene.get("player").call("take_damage", 10000)
	press(KEY_N)
	await saves.restore_completed
	check(saves.checkpoint.is_empty() and int(current_scene.get("bruno").get("health")) == 30, "real N starts fresh instead of restoring")
	saves.save_path = "res://.godot/render_no_save_slot.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(saves.save_path))
	player = current_scene.get("player")
	player.call("take_damage", 10000)
	await create_timer(2.0).timeout
	await wait_frame()
	check(not player.get_node("DeathScreen/Root/ContinuePrompt").text.contains("PREMI C"), "death without save offers N only")
	root.get_texture().get_image().save_png("res://.godot/death_no_save.png")
	print("CONNESIOS_RENDER_TESTS_OK" if failures.is_empty() else str(failures))
	quit(0 if failures.is_empty() else 1)
