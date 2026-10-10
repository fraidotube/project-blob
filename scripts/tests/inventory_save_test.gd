extends SceneTree

const SCENE := "res://scenes/levels/inventory_save_test.tscn"
const SLOT := "res://.godot/inventory_save_test_slot.cfg"
var _failures: Array[String] = []
var _defeats := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error("TEST FAILED: " + message)

func _wait(seconds: float = 0.1) -> void:
	await create_timer(seconds, true).timeout

func _press(key: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = true
	root.push_input(event, true)

func _run() -> void:
	var saves := root.get_node("SaveManager")
	var inventory := root.get_node("InventoryManager")
	var ui := root.get_node("GameplayUI")
	saves.save_path = saves.MAIN_SLOT
	saves.select_scene_slot(SCENE)
	_check(saves.save_path == saves.TEST_SLOT, "manual demo uses its own user slot")
	saves.select_scene_slot("res://scenes/maps/map_test.tscn")
	_check(saves.save_path == saves.MAIN_SLOT, "map uses main slot")
	saves.save_path = SLOT
	if OS.get_cmdline_user_args().has("--menu-test"):
		change_scene_to_file("res://scenes/ui/main_menu.tscn")
		await _wait(0.2)
		var menu := current_scene
		_check(not menu.get_node("MainPanel/VBox/Continue").disabled, "Continue enabled for valid save")
		menu.call("_continue_pressed")
		await saves.restore_completed
		_check(current_scene.scene_file_path == SCENE and inventory.has_item(&"bruno_key"), "menu Continue loads saved scene and inventory")
		await _wait(0.4)
		_finish()
		return
	if OS.get_cmdline_user_args().has("--continue-test"):
		_check(saves.has_disk_save(), "checkpoint is readable in a new process")
		await saves.continue_game()
		_check(inventory.has_item(&"bruno_key"), "inventory restored after application restart")
		var corpse: Node = current_scene.get("bruno")
		_check(int(corpse.get("health")) == 0, "defeated boss stays defeated after application restart")
		_check(bool(current_scene.get("door").get("unlocked")), "door unlocked after application restart")
		_finish()
		return
	saves.start_new_game(SCENE)
	_check(change_scene_to_file(SCENE) == OK, "test scene loads")
	await _wait(0.4)
	var scene := current_scene
	var player: CharacterBody3D = scene.get("player")
	var weapon: Node = player.get("weapon")
	var bruno: CharacterBody3D = scene.get("bruno")
	var door: Node3D = scene.get("door")
	var pc: Node3D = scene.get("pc")
	if OS.get_cmdline_user_args().has("--uncollected-test"):
		saves.save_path = "res://.godot/inventory_uncollected_slot.cfg"
		bruno.global_position = Vector3(-3, 0, -3)
		bruno.call("_die")
		await _wait()
		var corpse_at := bruno.global_transform
		var dropped: Node3D = saves.participants.get(&"demo.bruno_key")
		var dropped_at := dropped.global_position
		_check(saves.save_checkpoint(), "uncollected loot saved")
		await saves.continue_after_death()
		var restored: Node3D = saves.participants.get(&"demo.bruno_key")
		_check(restored != null and restored.global_position.is_equal_approx(dropped_at), "uncollected key respawns at saved position")
		_check(current_scene.get("bruno").global_transform.is_equal_approx(corpse_at), "corpse restores at final death position")
		_check(not inventory.has_item(&"bruno_key"), "uncollected key stays outside inventory")
		_finish()
		return
	# No-save death screen, blocked C, and a real N key restart.
	saves.save_path = "res://.godot/inventory_no_save_slot.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(saves.save_path))
	var pause := root.get_node("PauseMenu")
	pause.toggle_pause()
	_check(pause.load_button.disabled, "pause load disabled without a save")
	pause.toggle_pause()
	player.call("take_damage", 10000)
	var prompt: Label = player.get_node("DeathScreen/Root/ContinuePrompt")
	_check(prompt.text.contains("PREMI N") and not prompt.text.contains("PREMI C"), "no-save death offers only N")
	_press(KEY_C)
	await _wait()
	_check(current_scene == scene and bool(player.get("is_dead")) and not saves.busy, "C without save does nothing")
	_press(KEY_N)
	await saves.restore_completed
	scene = current_scene
	player = scene.get("player")
	weapon = player.get("weapon")
	bruno = scene.get("bruno")
	door = scene.get("door")
	pc = scene.get("pc")
	_check(not bool(player.get("is_dead")) and int(player.get("health")) == 100, "N without save starts fresh")
	saves.save_path = SLOT
	_check(not inventory.has_item(&"bruno_key"), "new inventory empty")
	door.call("interact", player)
	_check(not bool(door.get("unlocked")), "door locked without key")
	player.set("health", 73)
	weapon.call("apply_save_state", {
		"owns_pistol": true, "owns_smg": true, "owns_flashlight": true,
		"equipped": 3, "pistol_magazine": 3, "pistol_reserve": 14,
		"smg_magazine": 7, "smg_reserve": 22, "batteries": 1, "charge": 42.0
	})
	_check(saves.save_checkpoint(), "first manual checkpoint saved")
	_check(saves.save_checkpoint(), "existing checkpoint overwritten atomically")
	bruno.connect("defeated", func() -> void: _defeats += 1)
	# A phase fall is not a final death and must not produce a key.
	bruno.set("ai_active", true)
	bruno.call("_start_phase_transition", 2)
	await _wait()
	_check(_defeats == 0 and not saves.participants.has(&"demo.bruno_key"), "phase fall has no loot")
	_check(not saves.save_checkpoint(), "saving blocked during fight")
	bruno.set("ai_active", false)
	bruno.call("_die")
	bruno.call("_die")
	await _wait()
	_check(_defeats == 1, "final defeat signal emitted once")
	_check(saves.participants.has(&"demo.bruno_key"), "key drops from actual Bruno death")
	var key: Node = saves.participants.get(&"demo.bruno_key")
	if key == null:
		_finish()
		return
	key.call("interact", player)
	key.call("interact", player)
	_check(inventory.has_item(&"bruno_key") and int(inventory.items.get("bruno_key", 0)) == 1, "key collected once")
	door.call("interact", player)
	_check(bool(door.get("unlocked")) and inventory.has_item(&"bruno_key"), "unlock retains key")
	_check(not saves.save_checkpoint(), "saving blocked while door moves")
	await _wait(1.4)
	_check(not bool(door.get("moving")) and bool(door.get("is_open")), "door reaches open position")
	var ammo_adapter: Node = saves.participants.get(&"demo.ammo")
	ammo_adapter.get("target").call("interact", player)
	scene.get("event").call("_on_body_entered", player)
	await _wait()
	player.set("health", 66)
	player.global_position = Vector3(-2, 0.81, 4.2)
	var expected_weapon: Dictionary = weapon.call("get_save_state")
	_check(ui.open_inventory(), "I inventory opens")
	_check(paused, "inventory pauses gameplay")
	Input.action_press("fire")
	weapon.call("fire")
	weapon.call("_update_smg_automatic_fire")
	_check(int(weapon.get("smg_magazine_ammo")) == int(expected_weapon.smg_magazine), "inventory cannot fire weapon")
	ui.close_immediately()
	Input.action_release("fire")
	_check(not paused, "inventory restores gameplay")
	var expected_transform := player.global_transform
	var opened: bool = await ui.open_terminal(pc)
	_check(opened and paused, "terminal camera zoom opens and pauses")
	pc.get("save_button").emit_signal("pressed")
	_check(String(pc.get("status_label").text) == "SALVATAGGIO COMPLETATO", "ConnesiOS save button completes")
	var snapshot: Dictionary = saves.read_checkpoint()
	_check(snapshot.get("player", {}).get("transform") == expected_transform, "checkpoint stores player transform, not monitor camera")
	_check(snapshot.get("world", {}).get("demo.building_event", {}).get("completed", false), "completed event captured")
	_check(snapshot.get("world", {}).get("demo.ammo", {}).get("collected", false), "collected pickup captured")
	ui.close_immediately()
	# Reject closing onto a player in the passage.
	player.global_position = Vector3(3, 0.8, -2)
	await _wait(0.15)
	door.call("interact", player)
	_check(bool(door.get("is_open")), "occupied passage prevents closing")
	player.global_position = Vector3(0, 0.8, 5)
	await _wait(0.15)
	door.call("interact", player)
	await _wait(1.4)
	_check(not bool(door.get("is_open")), "unlocked door closes")
	inventory.remove_item(&"bruno_key")
	weapon.set("smg_magazine_ammo", 0)
	weapon.set("reserve_ammo", 0)
	var battery: Node = saves.participants.get(&"demo.battery")
	battery.get("target").call("interact", player)
	await _wait()
	player.call("take_damage", 10000)
	_check(bool(player.get("is_dead")), "player death triggered")
	prompt = player.get_node("DeathScreen/Root/ContinuePrompt")
	_check(prompt.text.contains("PREMI C") and prompt.text.contains("PREMI N"), "saved death offers C and N")
	_press(KEY_C)
	await saves.restore_completed
	scene = current_scene
	player = scene.get("player")
	weapon = player.get("weapon")
	door = scene.get("door")
	bruno = scene.get("bruno")
	_check(int(player.get("health")) == 66, "saved health restored")
	_check(player.global_position.distance_to(expected_transform.origin) < 0.05 and player.global_basis.is_equal_approx(expected_transform.basis), "saved player position restored")
	_check(weapon.call("get_save_state") == expected_weapon, "equipment, ammo and batteries restored exactly")
	_check(inventory.has_item(&"bruno_key"), "post-save inventory changes rolled back")
	_check(bool(door.get("is_open")) and bool(door.get("unlocked")), "door state rolled back")
	_check(int(bruno.get("health")) == 0, "saved defeated boss does not respawn")
	_check(not saves.participants.has(&"demo.bruno_key"), "collected key not duplicated on load")
	_check(not saves.participants.has(&"demo.ammo"), "saved collected pickup does not respawn")
	_check(saves.participants.has(&"demo.battery"), "pickup collected after saving respawns")
	_check(bool(scene.get("event").get("_already_played")), "completed camera event not repeated")
	_check(saves.save_checkpoint(), "checkpoint remains reusable after restore")
	# Load from the actual pause button and make sure the autoload UI is reset.
	weapon.set("smg_magazine_ammo", 0)
	pause.toggle_pause()
	_check(not pause.load_button.disabled, "pause load enabled for current scene save")
	pause.load_button.emit_signal("pressed")
	await saves.restore_completed
	scene = current_scene
	player = scene.get("player")
	_check(not paused and not pause.is_open and not pause.pause_root.visible, "pause load restores usable gameplay")
	_check(player.get("weapon").call("get_save_state") == expected_weapon, "pause load restores ammo snapshot")
	# Failed writes cannot change the good in-memory checkpoint.
	var good: Dictionary = saves.checkpoint.duplicate(true)
	saves.save_path = "res://.godot/nonexistent_inventory_test_directory/save.cfg"
	_check(not saves.save_checkpoint(), "invalid destination fails cleanly")
	_check(saves.checkpoint == good, "failed write preserves last checkpoint")
	saves.save_path = SLOT
	# Starting fresh must not delete the user's last disk slot.
	player.call("take_damage", 10000)
	_press(KEY_N)
	await saves.restore_completed
	scene = current_scene
	_check(inventory.items.is_empty(), "N restarts with empty inventory even when a checkpoint exists")
	_check(int(scene.get("bruno").get("health")) == 30, "unsaved boss defeat rolled back")
	_check(not bool(scene.get("door").get("unlocked")), "unsaved unlock rolled back")
	_check(saves.has_disk_save(), "new game leaves previous disk save intact")
	_check(saves.checkpoint.is_empty(), "N clears active checkpoint")
	var malformed := ConfigFile.new()
	malformed.set_value("checkpoint", "data", {"version": 999, "scene": SCENE})
	malformed.save("res://.godot/inventory_save_invalid.cfg")
	saves.save_path = "res://.godot/inventory_save_invalid.cfg"
	_check(not saves.has_disk_save(), "invalid version rejected")
	saves.save_path = SLOT
	_finish()

func _finish() -> void:
	if _failures.is_empty():
		print("INVENTORY_SAVE_TESTS_OK")
	else:
		print("INVENTORY_SAVE_TESTS_FAILED ", _failures)
	quit.call_deferred(0 if _failures.is_empty() else 1)
