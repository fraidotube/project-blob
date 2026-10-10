extends SceneTree

var failures := 0
var integration: Node
var saves: Node
var inventory: Node

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error("Regia map: " + message)

func run() -> void:
	saves = root.get_node("SaveManager")
	inventory = root.get_node("InventoryManager")
	saves.save_path = "res://.godot/regia_map_test_slot.cfg"
	if "--continue-test" in OS.get_cmdline_user_args():
		check(await saves.continue_game(), "Checkpoint did not load in fresh process")
		await physics_frame
		integration = current_scene.get_node("RegiaIntegration")
		check(integration.lab_door.is_open and integration.bathroom_door.is_open and integration.regia_door.is_open, "Doors not restored across process restart")
		check(integration.loot.defeated and inventory.has_item(&"bruno_key"), "Boss/key not restored across process restart")
		check(current_scene.get_node_or_null("BrunoKeyDrop") == null and current_scene.get_node_or_null("PistolPickup") == null, "Collected pickups duplicated across process restart")
		print("REGIA_CONTINUE_TEST failures=", failures)
		current_scene.queue_free()
		await process_frame
		quit(0 if failures == 0 else 1)
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(saves.save_path))
	change_scene_to_file("res://scenes/maps/map_test.tscn")
	await process_frame
	await process_frame
	await physics_frame
	integration = current_scene.get_node("RegiaIntegration")
	var player = current_scene.get_node("Player")
	var lab = integration.lab_door
	var bath = integration.bathroom_door
	var swing = integration.regia_door
	check(lab != null and bath != null and integration.pc != null, "Components missing")
	lab.interact(player)
	check(not lab.is_open and not lab.unlocked, "Lab opened without key")
	check(bath.required_key.is_empty() and bath.unlocked, "Bathroom is locked")
	bath.interact(player)
	await create_timer(0.8).timeout
	check(bath.is_open and not bath.moving and bath.panel.position.x < -0.7, "Bathroom did not slide left")
	var handles: Array = []
	var poses: Array[Transform3D] = []
	for mesh in integration._meshes(swing):
		handles.append(mesh)
		poses.append(mesh.transform)
	swing.interact(player)
	await create_timer(1.8).timeout
	check(swing.is_open and absf(swing.rotation.y) > 1.5, "Swing did not rotate")
	check(handles.size() == 7, "Regia panel/handles missing")
	for index in handles.size():
		check(handles[index].transform.is_equal_approx(poses[index]), "Handle failed to follow shared pivot")
	current_scene.get_node("PistolPickup").interact(player)
	await process_frame
	await process_frame
	check(saves.object_state(&"main.pickup.PistolPickup").get("collected", false), "Existing pickup collection not persisted")
	var boss = current_scene.get_node("BrunoBuozzi")
	boss.start_boss_fight()
	current_scene.get_node("BrunoFightEnvironment")._try_start_fight_environment()
	boss._die()
	await process_frame
	await process_frame
	var key = current_scene.get_node_or_null("BrunoKeyDrop")
	check(key != null, "Final defeat did not drop key")
	if key != null:
		key.interact(player)
	await process_frame
	check(inventory.has_item(&"bruno_key"), "Key was not collected")
	lab.interact(player)
	await create_timer(0.8).timeout
	check(lab.unlocked and lab.is_open and not lab.moving, "Lab did not unlock/open")
	check(lab.panel.position.x < -0.8 and inventory.has_item(&"bruno_key"), "Wrong slide/key consumption")
	var wait_start := Time.get_ticks_msec()
	while not saves.can_save() and Time.get_ticks_msec() - wait_start < 8000:
		await create_timer(0.1).timeout
	var written: bool = saves.save_checkpoint()
	check(written, "Map checkpoint write failed: " + saves.last_error)
	if not written:
		quit(1)
		return
	check(saves.read_checkpoint().world.has("main.pc.regia"), "PC not persistent")
	check(await saves.continue_game(), "Map checkpoint restore failed")
	await physics_frame
	integration = current_scene.get_node("RegiaIntegration")
	check(integration.lab_door.is_open and integration.lab_door.unlocked, "Lab restore failed")
	check(integration.bathroom_door.is_open and integration.bathroom_door.unlocked, "Bathroom restore failed")
	check(integration.regia_door.is_open, "Swing restore failed")
	check(integration.loot.defeated and inventory.has_item(&"bruno_key"), "Boss/key restore failed")
	check(current_scene.get_node_or_null("BrunoKeyDrop") == null, "Collected key duplicated after restore")
	check(current_scene.get_node_or_null("PistolPickup") == null, "Existing pickup respawned after restore")
	check(current_scene.get_node("BrunoFightEnvironment")._fight_environment_finished, "Boss environment not restored")
	check(current_scene.get_node("BrunoBuozzi/MouthIntegration").motion != null, "Mouth integration lost")
	print("REGIA_MAP_TEST failures=", failures, " participants=", saves.participants.size())
	current_scene.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
