extends SceneTree

var failures := 0
var puzzle: Node
var saves: Node
var ui: Node
var inventory: Node
var fixture_camera: Camera3D
var sound_counts: Dictionary = {}
func count_sound(cue: StringName) -> void:
	sound_counts[cue] = int(sound_counts.get(cue, 0)) + 1
func sound_count(cue: StringName) -> int:
	return int(sound_counts.get(cue, 0))
func _initialize() -> void:
	call_deferred("run")
func check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error("NETWORK_MAP: " + message)
func photo(name: String, pose: Transform3D) -> void:
	if DisplayServer.get_name() == "headless": return
	fixture_camera.global_transform = pose
	fixture_camera.current = true
	await create_timer(0.25).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/network_" + name + ".png")
func click_terminal(terminal: Node3D, point: Vector2) -> void:
	fixture_camera.global_transform = terminal.camera_target()
	fixture_camera.current = true
	var local := Vector3((point.x / terminal.viewport.size.x - 0.5) * terminal.screen_size.x, (0.5 - point.y / terminal.viewport.size.y) * terminal.screen_size.y, 0)
	var position := fixture_camera.unproject_position(terminal.screen.global_transform * local)
	var motion := InputEventMouseMotion.new()
	motion.position = position
	terminal.handle_pointer(motion, fixture_camera)
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = position
	event.pressed = true
	terminal.handle_pointer(event, fixture_camera)
	event.pressed = false
	terminal.handle_pointer(event, fixture_camera)
	await process_frame

func click_control(terminal: Node3D, control: Control) -> void:
	await process_frame
	await click_terminal(terminal, control.get_global_rect().get_center())
func exit_sweep(blocked_expected: bool) -> void:
	var player = current_scene.get_node("Player")
	for side in [1.0, -1.0]:
		var parameters := PhysicsTestMotionParameters3D.new()
		parameters.from = player.global_transform
		parameters.from.origin = Vector3(7.04, 0.9, 2.82 + side * 0.7)
		parameters.motion = Vector3(0, 0, -side * 1.4)
		parameters.recovery_as_collision = true
		var result := PhysicsTestMotionResult3D.new()
		var blocked := PhysicsServer3D.body_test_motion(player.get_rid(), parameters, result)
		check(blocked == blocked_expected, "Alien exit passage side=%s blocked=%s expected=%s" % [side, blocked, blocked_expected])
		if blocked and not blocked_expected:
			for i in result.get_collision_count():
				print("NETWORK_EXIT_BLOCK ", result.get_collider(i).get_path(), " point=", result.get_collision_point(i))
func run() -> void:
	if DisplayServer.get_name() != "headless":
		root.mode = Window.MODE_WINDOWED
		root.size = Vector2i(1280, 720)
	saves = root.get_node("SaveManager")
	ui = root.get_node("GameplayUI")
	inventory = root.get_node("InventoryManager")
	saves.save_path = "res://.godot/regia_network_test_slot.cfg"
	if "--packed-test" in OS.get_cmdline_user_args():
		saves.save_path = "res://.godot/regia_network_packed_slot.cfg"
		check(await saves.continue_game(), "Packed checkpoint load failed")
		puzzle = current_scene.get_node("RegiaIntegration/NetworkPuzzle")
		await create_timer(3.3).timeout
		check(puzzle.state.laptop_recovered and puzzle.state.laptop_shutdown and not puzzle.state.laptop_placed, "Packed lifecycle lost")
		check(inventory.has_item(&"regia_laptop") and inventory.has_item(&"regia_charger") and inventory.has_item(&"network_cable"), "Packed inventory lost")
		check(not puzzle.laptop_interaction.visible and not puzzle.charger_assembly.visible and not puzzle.state.pc_link and puzzle.state.switch_link, "Packed visuals or links restored incorrectly")
		check(puzzle.state.unlocked and puzzle.closure.visible, "Packed checkpoint relocked or lost closure")
		print("REGIA_NETWORK_PACKED_TEST failures=", failures)
		current_scene.queue_free()
		await process_frame
		quit(0 if failures == 0 else 1)
		return
	if "--partial-test" in OS.get_cmdline_user_args():
		var data: Dictionary = saves.read_checkpoint()
		check(not data.is_empty(), "Partial fixture missing")
		if data.is_empty():
			quit(1)
			return
		var partial: Dictionary = data.world["main.regia.network"]
		partial.unlocked = false
		partial.pc_link = false
		partial.switch_link = true
		partial.pppoe_valid = false
		partial.wifi_enabled = false
		partial.laptop_on = false
		partial.laptop_shutdown = false
		partial.laptop_recovered = false
		data.inventory["network_cable"] = 1
		data.world["main.door.regia_exit"].is_open = false
		check(await saves._load_scene(String(data.scene), data), "Partial checkpoint failed to restore")
		puzzle = current_scene.get_node("RegiaIntegration/NetworkPuzzle")
		check(puzzle.state.switch_link and not puzzle.state.pc_link and not puzzle.state.online, "Partial links or Offline state lost")
		check(inventory.has_item(&"network_cable", 1) and not inventory.has_item(&"network_cable", 2), "Partial cable stock duplicated")
		check(puzzle.state.laptop_placed and puzzle.state.charger_connected and not puzzle.state.laptop_on, "Partial laptop state lost")
		check(not puzzle.state.unlocked and not puzzle.exit_door.is_open and puzzle.closure.visible, "Partial door not locked")
		check(puzzle.state.toggle_cable("pc") and puzzle.state.use_laptop().contains("acceso") and puzzle.state.local_network(), "Partial puzzle cannot continue")
		print("REGIA_NETWORK_PARTIAL_TEST failures=", failures)
		current_scene.queue_free()
		await process_frame
		quit(0 if failures == 0 else 1)
		return
	if "--continue-test" in OS.get_cmdline_user_args():
		check(await saves.continue_game(), "New-process checkpoint load failed")
		puzzle = current_scene.get_node("RegiaIntegration/NetworkPuzzle")
		await create_timer(3.3).timeout
		check(puzzle.state.unlocked and puzzle.state.online and puzzle.state.alien_connected(), "New process network or unlock lost")
		check(puzzle.state.laptop_placed and puzzle.state.charger_connected and puzzle.state.racket_collected, "New process items lost")
		check(not puzzle.racket_drop.visible and inventory.has_item(&"bruno_racket"), "New process duplicate racket")
		print("REGIA_NETWORK_CONTINUE_TEST failures=", failures)
		current_scene.queue_free()
		await process_frame
		quit(0 if failures == 0 else 1)
		return
	change_scene_to_file("res://scenes/maps/map_test.tscn")
	await process_frame
	await process_frame
	await physics_frame
	puzzle = current_scene.get_node("RegiaIntegration/NetworkPuzzle")
	print("NETWORK_DESK_BOUNDS ", puzzle.integration._bounds(current_scene.get_node("connesi_building_test2/ScrivaniaRegia"), Transform3D.IDENTITY))
	puzzle.audio.cue_played.connect(count_sound)
	puzzle.alien_terminal.audio.cue_played.connect(count_sound)
	puzzle.laptop_terminal.audio.cue_played.connect(count_sound)
	check(puzzle.audio._players.is_empty(), "Puzzle startup replayed audio")
	check(puzzle.exit_door.open_sound == puzzle.AUDIO.stream(&"open") and puzzle.exit_door.close_sound == puzzle.AUDIO.stream(&"close"), "New door effects not assigned")
	fixture_camera = Camera3D.new()
	current_scene.add_child(fixture_camera)
	fixture_camera.fov = 40
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-45, -15, 0)
	fill.light_energy = 1.0
	current_scene.add_child(fill)
	var player = current_scene.get_node("Player")
	player.set_physics_process(false)
	player.set_process(false)
	player.global_position = Vector3(7.5, 0.1, 6.0)
	check(puzzle.key_positions.size() == 12, "Incorrect physical key count")
	check(puzzle.exit_door != null, "Exit missing")
	exit_sweep(true)
	var closure_scale: Vector3 = puzzle.closure.scale
	var original_camera: Transform3D = puzzle.alien_terminal.camera_target()
	var camera_distance: float = original_camera.origin.distance_to(puzzle.alien_terminal.screen.global_position - puzzle.alien_terminal.screen.global_basis.y * 0.16)
	puzzle.closure.scale = closure_scale * 0.75
	var scaled_camera: Transform3D = puzzle.alien_terminal.camera_target()
	var scaled_distance: float = scaled_camera.origin.distance_to(puzzle.alien_terminal.screen.global_position - puzzle.alien_terminal.screen.global_basis.y * 0.16)
	check(is_equal_approx(scaled_distance, camera_distance * 0.75), "Alien zoom did not follow uniform node scale")
	puzzle.alien_terminal.set_terminal_active(true, true)
	fixture_camera.global_transform = scaled_camera
	for index in puzzle.key_positions.size():
		puzzle.alien_terminal.wifi_flash = 0
		puzzle.click_alien_key(fixture_camera, fixture_camera.unproject_position(puzzle.closure.to_global(puzzle.key_positions[index])))
		check(puzzle.alien_terminal.wifi_flash > 0, "Scaled physical alien key hit missed: " + str(index))
	puzzle.closure.scale = closure_scale
	puzzle.alien_terminal.wifi_flash = 0
	puzzle.alien_terminal.set_terminal_active(false, false)
	check(sound_count(&"button") == 12, "Physical keys did not beep exactly once each")
	await photo("alien_initial", puzzle.alien_terminal.camera_target())
	player.set_physics_process(true)
	puzzle.interact_action("notes")
	check(ui.modal == "puzzle" and puzzle.state.notes_read, "Notes modal failed")
	await photo("notes", puzzle.alien_terminal.camera_target())
	ui.close_modal()
	puzzle.interact_action("book")
	var reader: Control = ui._puzzle_panel
	check(not reader.wifi_visible, "WiFi symbol revealed before turning pages")
	await photo("book_first", puzzle.alien_terminal.camera_target())
	await reader.turn_page(1)
	await reader.turn_page(1)
	check(reader.wifi_visible and reader.page_index == 2, "Alien page turning failed to reveal WiFi")
	await photo("book_wifi", puzzle.alien_terminal.camera_target())
	ui.close_modal()
	player.set_physics_process(false)
	check(not paused and ui.modal.is_empty(), "Document did not return controls")
	puzzle.interact_action("laptop")
	puzzle.interact_action("place")
	print("REVISION_LAPTOP pose=", puzzle.laptop_visual.global_transform, " bounds=", puzzle.integration._bounds(puzzle.laptop_visual, Transform3D.IDENTITY), " charger=", puzzle.charger_visual.global_position, " switch=", puzzle.switch_visual.global_position)
	check(puzzle.laptop_interaction.global_position.distance_to(puzzle.fritz.global_position) < 1.1, "Laptop placed away from Fritz desk")
	var display_width: float = puzzle.laptop_terminal.screen_size.x * puzzle.laptop_terminal.screen.global_basis.x.length()
	check(display_width > 0.58 and display_width < 0.62, "Laptop reduction did not preserve usable display size")
	check(puzzle.has_node("FritzPowerAdapter") and puzzle.get_node("FritzPowerAdapter").visible, "Permanent Fritz adapter missing")
	check(puzzle.laptop_port(false).z < puzzle.laptop_port(true).z, "Ethernet and power not on left/right sides")
	check(puzzle.state.laptop_placed and not inventory.has_item(&"regia_laptop"), "Laptop placement or inventory failed")
	puzzle.interact_action("laptop")
	check(puzzle.laptop_terminal.screen.global_basis.z.normalized().dot(Vector3.LEFT) > 0.95, "Laptop does not face red chair")
	check(puzzle.state.laptop_open and not puzzle.state.laptop_on and ui.modal.is_empty(), "Dead laptop zoomed or failed to open")
	await photo("laptop_flat", puzzle.laptop_terminal.camera_target())
	puzzle.interact_action("charger")
	check(inventory.has_item(&"regia_charger") and not puzzle.charger_interaction.visible, "Charger did not enter inventory")
	puzzle.interact_action("laptop")
	check(puzzle.state.charger_connected and not inventory.has_item(&"regia_charger") and puzzle.charger_assembly.visible, "E did not install collected charger")
	check(sound_count(&"cable") == 1, "Charger connection audio missing or duplicated")
	puzzle.power.turn_on()
	puzzle.interact_action("laptop")
	check(puzzle.state.laptop_on, "Powered laptop did not turn on")
	var terminal: Node3D = puzzle.laptop_terminal
	player.set_physics_process(true)
	player.get_node("Head/Camera3D").current = true
	puzzle.interact_action("laptop")
	await create_timer(0.9).timeout
	check(ui.modal == "terminal" and ui.terminal == terminal, "Real PC zoom failed")
	await click_control(terminal, terminal.start_button)
	await click_control(terminal, terminal.shutdown_button)
	check(ui.modal == "terminal" and puzzle.state.laptop_on and terminal.shutdown_feedback.text.contains("non posso spegnerlo"), "Premature shutdown did not refuse")
	terminal.start_menu.hide()
	await ui.close_modal()
	check(ui.modal.is_empty() and not paused and player.get_node("Head/Camera3D").current, "PC exit failed to restore FPS")
	player.set_physics_process(false)
	terminal.set_terminal_active(true, true)
	await click_control(terminal, terminal.chrome_button)
	check(terminal.browser.visible, "Physical Chrome icon click failed")
	terminal.navigate("192.168.178.1")
	check(not terminal.logged_in and terminal.page.get_child(0).text.contains("Impossibile"), "Offline browser reached router")
	puzzle.interact_action("cables")
	puzzle.interact_action("cables")
	puzzle.state.toggle_cable("switch")
	puzzle._animate_cable("switch")
	check(sound_count(&"cable") == 1, "Cable click played before connector arrived")
	await create_timer(0.7).timeout
	check(sound_count(&"cable") == 2 and puzzle.busy_visuals == 0, "Cable completion audio missing or animation busy")
	check(not puzzle.state.online, "Switch-first unconfigured router Online")
	puzzle.state.toggle_cable("pc")
	player.set_physics_process(true)
	puzzle.interact_action("router")
	await create_timer(0.9).timeout
	check(ui.modal == "terminal" and ui.terminal == puzzle.router_view and puzzle.router_view.panel.visible, "Connected Fritz did not zoom")
	await photo("fritz_zoom", puzzle.router_view.camera_target())
	var connection_button: Button = puzzle.router_view.panel.get_child(0).get_child(0)
	var connection_click := InputEventMouseButton.new()
	connection_click.button_index = MOUSE_BUTTON_LEFT
	connection_click.pressed = true
	connection_click.position = connection_button.get_global_rect().get_center()
	puzzle.router_view.handle_pointer(connection_click, fixture_camera)
	await create_timer(0.7).timeout
	check(ui.modal == "puzzle", "Fritz zoom connections button failed")
	ui.close_modal()
	player.set_physics_process(false)
	terminal.set_terminal_active(true, true)
	terminal.navigate("192")
	check(terminal.address.text == "192.168.178.1", "URL completion failed")
	var fields: Array[Node] = terminal.page.find_children("*", "LineEdit", true, false)
	fields[0].text = "admin"
	fields[1].text = "bad"
	await click_control(terminal, terminal.page.get_child(5))
	check(not terminal.logged_in, "Wrong admin login accepted")
	fields[1].text = "admin2026"
	await click_control(terminal, terminal.page.get_child(5))
	check(terminal.logged_in, "Admin login failed")
	fields = terminal.page.find_children("*", "LineEdit", true, false)
	fields[0].text = "narcisolo"
	fields[1].text = "ottavonano"
	await click_control(terminal, terminal.page.get_child(5))
	await create_timer(3.3).timeout
	check(puzzle.state.online, "PPPoE UI failed")
	await photo("router_internet", terminal.camera_target())
	await click_control(terminal, terminal.page.get_child(2).get_child(1))
	var checks: Array[Node] = terminal.page.find_children("*", "CheckBox", true, false)
	checks[0].button_pressed = true
	checks[1].button_pressed = false
	await click_control(terminal, terminal.page.get_child(7))
	check(puzzle.state.alien_connected(), "Open WiFi UI failed")
	await photo("router_wifi", terminal.camera_target())
	await photo("desk_cables", Transform3D(Basis.IDENTITY, Vector3(7.4, 2.2, 5.3)).looking_at(Vector3(8.75, 0.95, 4.45), Vector3.UP))
	await photo("fritz_power", Transform3D(Basis.IDENTITY, Vector3(8.3, 1.6, 4.6)).looking_at(Vector3(9.0, 1.0, 4.05), Vector3.UP))
	await photo("power_cable", Transform3D(Basis.IDENTITY, Vector3(7.8, 0.6, 5.3)).looking_at(Vector3(9.1, 0.5, 5.05), Vector3.UP))
	await photo("router_leds", Transform3D(Basis.IDENTITY, puzzle.fritz.global_position + Vector3(-0.1, 0.7, 0.6)).looking_at(puzzle.fritz.global_position, Vector3.UP))
	terminal.set_terminal_active(false, false)
	puzzle.regia_switch.interact(player)
	puzzle.corridor_switch.interact(player)
	check(puzzle.regia_switch.lights_on and puzzle.corridor_switch.lights_on, "New switches failed")
	var boss = current_scene.get_node("BrunoBuozzi")
	boss.start_boss_fight()
	boss._die()
	await create_timer(0.7).timeout
	var key_drop := current_scene.get_node_or_null("BrunoKeyDrop")
	check(key_drop != null and key_drop.has_node("KeyWithTag"), "Real key-with-tag model missing")
	if key_drop != null:
		await photo("key_with_tag", Transform3D(Basis.IDENTITY, key_drop.global_position + Vector3(0, 0.55, 0.3)).looking_at(key_drop.global_position, Vector3.UP))
		key_drop.interact(player)
	check(puzzle.state.racket_available and puzzle.racket_drop != null, "Final boss racket drop failed")
	puzzle.interact_action("racket")
	check(inventory.has_item(&"bruno_racket") and not puzzle.racket_drop.visible, "Racket collection failed")
	player.set_physics_process(true)
	check(ui.open_inventory(), "Inventory failed")
	puzzle.open_racket_inspection()
	check(ui.modal == "puzzle", "3D inspection failed")
	await photo("racket_inspect", terminal.camera_target())
	ui.close_modal()
	check(ui.modal == "inventory", "Inspection Escape did not return inventory")
	ui.close_modal()
	player.set_physics_process(false)
	player.global_position = Vector3(7.04, 0.95, puzzle.exit_door.closed_plane_z + 0.60)
	await physics_frame
	puzzle.alien_terminal.set_terminal_active(true, true)
	for index in puzzle.state.PASSWORD:
		fixture_camera.global_transform = puzzle.alien_terminal.camera_target()
		var point: Vector3 = puzzle.closure.global_transform * puzzle.key_positions[index]
		puzzle.click_alien_key(fixture_camera, fixture_camera.unproject_position(point))
	check(puzzle.state.unlocked, "Physical alien key clicks failed")
	check(sound_count(&"unlock") == 1, "Unlock audio missing or duplicated")
	await create_timer(2.0).timeout
	check(player.global_position.z >= puzzle.exit_door.closed_plane_z + puzzle.exit_door.leaf_width + 0.40, "Password unlock failed to retreat nearby player")
	await physics_frame
	exit_sweep(false)
	check(puzzle.closure.visible and puzzle.closure.is_ancestor_of(puzzle.alien_terminal), "Alien assembly disappeared after unlock")
	check(puzzle.exit_door.door_body.is_ancestor_of(puzzle.closure), "Alien assembly not attached to door")
	var attached_pose: Transform3D = puzzle.closure.transform
	puzzle.exit_door.interact(player)
	await create_timer(1.8).timeout
	check(not puzzle.exit_door.is_open and puzzle.state.unlocked and puzzle.closure.transform.is_equal_approx(attached_pose), "Unlocked door closing lost lock attachment")
	check(not puzzle.exit_door.close_sound_pending and puzzle.exit_door.door_audio.stream == puzzle.exit_door.close_sound, "Close impact not synced to closed position")
	player.set_physics_process(false)
	player.global_position = Vector3(7.04, 0.95, puzzle.exit_door.closed_plane_z + 0.60)
	await physics_frame
	var before_retreat: Vector3 = player.global_position
	puzzle.exit_door.interact(player)
	check(puzzle.exit_door.retreating and puzzle.blocks_saving() and not puzzle.exit_door.is_open, "Inside opening did not retreat before moving leaf")
	check(puzzle.exit_door.door_audio.stream != puzzle.exit_door.open_sound, "Opening effect played before retreat ended")
	await physics_frame
	paused = true
	var paused_position: Vector3 = player.global_position
	await create_timer(0.12).timeout
	check(player.global_position.is_equal_approx(paused_position), "Retreat moved player while paused")
	paused = false
	await create_timer(2.5).timeout
	check(player.global_position.z > before_retreat.z + 0.4 and not puzzle.exit_door.retreating and not player.is_physics_processing(), "Inside retreat or physics restoration failed")
	check(puzzle.exit_door.rotation.y > 1.5 and puzzle.exit_door.global_position.x > puzzle.exit_door.closed_center_x, "Door did not swing inward on right hinge")
	check(puzzle.exit_door.is_open and puzzle.closure.transform.is_equal_approx(attached_pose), "Unlocked door reopened password or detached closure")
	exit_sweep(false)
	puzzle.exit_door.interact(player)
	await create_timer(1.8).timeout
	player.global_position = Vector3(7.04, 0.95, puzzle.exit_door.closed_plane_z - 0.60)
	await physics_frame
	var outside_position: Vector3 = player.global_position
	puzzle.exit_door.interact(player)
	check(not puzzle.exit_door.retreating and puzzle.exit_door.is_open, "Outside opening incorrectly retreats")
	await create_timer(1.8).timeout
	check(player.global_position.is_equal_approx(outside_position), "Outside player moved automatically")
	puzzle.exit_door.interact(player)
	await create_timer(1.8).timeout
	player.global_position = Vector3(7.04, 0.95, puzzle.exit_door.closed_plane_z + 0.60)
	var obstacle := StaticBody3D.new()
	obstacle.collision_layer = 1
	current_scene.add_child(obstacle)
	obstacle.global_position = Vector3(7.04, 1.2, puzzle.exit_door.closed_plane_z + 1.0)
	puzzle.integration._box(obstacle, AABB(Vector3(-0.45, -1, -0.05), Vector3(0.9, 2, 0.1)))
	await physics_frame
	puzzle.exit_door.interact(player)
	check(not puzzle.exit_door.retreating and not puzzle.exit_door.is_open, "Door opens when retreat path is obstructed")
	obstacle.queue_free()
	await physics_frame
	player.set_physics_process(true)
	puzzle.exit_door.interact(player)
	await create_timer(2.5).timeout
	check(puzzle.exit_door.is_open and player.is_physics_processing(), "Retreat failed to restore active player controller")
	player.global_position = Vector3(7.5, 0.95, 6.0)
	await photo("exit_open", Transform3D(Basis.IDENTITY, Vector3(7.0, 1.7, 5.0)).looking_at(Vector3(7.0, 1.0, 2.8), Vector3.UP))
	# Saving uses the real eligibility checks; no user slots are written.
	await create_timer(3.0).timeout
	check(saves.save_checkpoint(), "Network checkpoint save failed: " + saves.last_error)
	check(await saves.continue_game(), "Network checkpoint restore failed")
	puzzle = current_scene.get_node("RegiaIntegration/NetworkPuzzle")
	await create_timer(3.3).timeout
	check(puzzle.state.unlocked and puzzle.state.online and puzzle.state.laptop_placed, "Restore lost puzzle")
	check(puzzle.audio._players.is_empty() and not puzzle.exit_door.door_audio.playing, "Restore replayed puzzle/door sounds")
	check(puzzle.exit_door.is_open and puzzle.exit_door.rotation.y > 1.5 and puzzle.exit_door.global_position.x > puzzle.exit_door.closed_center_x, "Restore lost inward opening or right hinge")
	exit_sweep(false)
	check(puzzle.regia_switch.lights_on and puzzle.corridor_switch.lights_on, "Restore lost lights")
	check(not puzzle.racket_drop.visible and inventory.has_item(&"bruno_racket"), "Restore duplicated racket")
	player = current_scene.get_node("Player")
	terminal = puzzle.laptop_terminal
	fixture_camera = Camera3D.new()
	current_scene.add_child(fixture_camera)
	fixture_camera.fov = 40
	player.get_node("Head/Camera3D").current = true
	puzzle.interact_action("laptop")
	await create_timer(0.9).timeout
	await click_control(terminal, terminal.start_button)
	await click_control(terminal, terminal.shutdown_button)
	await create_timer(0.7).timeout
	check(ui.modal.is_empty() and not paused and puzzle.state.laptop_shutdown and not puzzle.state.laptop_open, "Shutdown did not close laptop and restore FPS")
	check(puzzle.action_label("laptop") == "RACCOGLI", "Closed laptop does not offer pickup")
	puzzle.interact_action("laptop")
	check(inventory.has_item(&"regia_laptop") and inventory.has_item(&"regia_charger") and not puzzle.laptop_interaction.visible and not puzzle.charger_assembly.visible, "Portable kit not collected")
	check(inventory.has_item(&"network_cable") and not puzzle.state.pc_link and puzzle.state.switch_link, "Packing lost cable or switch uplink")
	puzzle.interact_action("place")
	check(not puzzle.state.laptop_placed and puzzle.state.status == "Non c'è più bisogno ora.", "Solved desk accepted laptop again")
	check(ui.open_inventory(), "Packed inventory did not open")
	for id: String in ["bruno_key", "network_cable", "regia_laptop", "regia_charger", "bruno_racket"]:
		check(inventory.definitions[id].icon != null, "Missing item icon: " + id)
		ui._selected_item = id
		ui._examine_selected()
		check(ui.modal == "puzzle" and ui._puzzle_panel.item_id == id, "Item inspection failed: " + id)
		await photo("inspect_" + id, terminal.camera_target())
		ui.close_modal()
		check(ui.modal == "inventory", "Inspection did not return inventory")
	ui.close_modal()
	saves.save_path = "res://.godot/regia_network_packed_slot.cfg"
	check(saves.save_checkpoint(), "Packed checkpoint save failed: " + saves.last_error)
	print("REGIA_NETWORK_MAP_TEST failures=", failures)
	current_scene.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
