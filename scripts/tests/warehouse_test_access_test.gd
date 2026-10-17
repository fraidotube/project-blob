extends SceneTree

var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func run() -> void:
	change_scene_to_file("res://scenes/maps/map_test.tscn")
	await process_frame
	await process_frame
	await physics_frame
	var shortcut = current_scene.get_node("WarehouseTestAccess")
	var encounter = current_scene.get_node("AngelastriEncounter")
	var puzzle = current_scene.get_node("RegiaIntegration/NetworkPuzzle")
	var inventory_manager = root.get_node("InventoryManager")
	var save_manager = root.get_node("SaveManager")
	var inventory: Dictionary = inventory_manager.get_snapshot()
	var stage: String = encounter.event.stage
	check(not shortcut.active, "Bypass attivo senza F4")
	check(save_manager.participants.get(shortcut.SAVE_ID) == shortcut, "Protezione salvataggio non registrata")
	var key := InputEventKey.new()
	key.physical_keycode = KEY_F4
	key.pressed = true
	shortcut._unhandled_input(key)
	await process_frame
	check(shortcut.active and puzzle.state.unlocked, "F4 non sblocca la porta")
	check(not encounter.is_processing() and not encounter.is_processing_unhandled_input(), "Evento Angelastri ancora attivo")
	check(encounter.event.stage == stage, "Progressione boss modificata")
	check(inventory_manager.get_snapshot() == inventory, "Inventario modificato")
	check(shortcut.blocks_saving() and not save_manager.can_save(), "Checkpoint non protetto")
	shortcut._unhandled_input(key)
	var deadline := Time.get_ticks_msec() + 5000
	while Time.get_ticks_msec() < deadline and not puzzle.exit_door.is_open:
		await process_frame
	check(puzzle.exit_door.is_open, "Porta non aperta")
	print("WAREHOUSE_TEST_ACCESS failures=", failures)
	quit(failures)
