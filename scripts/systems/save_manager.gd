extends Node

signal checkpoint_saved
signal restore_completed
## Stato del mondo applicato, con schermata di caricamento ancora coprente e albero in pausa.
signal world_restored

const VERSION := 1
const MAIN_SLOT := "user://savegame.cfg"
const TEST_SLOT := "user://inventory_save_test.cfg"
const TEST_SCENE := "res://scenes/levels/inventory_save_test.tscn"
var save_path: String = MAIN_SLOT
var checkpoint: Dictionary = {}
var world_states: Dictionary = {}
var participants: Dictionary = {}
var restoring := false
var busy := false
var last_error := ""
var new_game_scene := ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func register_object(id: StringName, object: Node) -> void:
	if String(id).is_empty():
		return
	if participants.has(id) and is_instance_valid(participants[id]) and participants[id] != object:
		push_error("Duplicate persistent ID: " + String(id))
		return
	participants[id] = object
	if not restoring and world_states.has(String(id)):
		object.call_deferred("apply_persistent_state", object_state(id))

func unregister_object(id: StringName, object: Node) -> void:
	if participants.get(id) == object:
		participants.erase(id)

func object_state(id: StringName) -> Dictionary:
	var value: Dictionary = world_states.get(String(id), {})
	return value.duplicate(true)

func set_object_state(id: StringName, state: Dictionary) -> void:
	if not String(id).is_empty():
		world_states[String(id)] = state.duplicate(true)

func can_save() -> bool:
	last_error = ""
	if busy or restoring:
		last_error = "Caricamento in corso."
		return false
	var player := get_tree().get_first_node_in_group("player")
	if player == null or bool(player.get("is_dead")):
		last_error = "Giocatore non disponibile."
		return false
	if not player.is_physics_processing():
		last_error = "Attendi la fine della sequenza."
		return false
	var weapon := player.get_node_or_null("Head/Camera3D/WeaponHolder")
	if weapon != null and (bool(weapon.get("is_reloading")) or bool(weapon.get("is_performing_action"))):
		last_error = "Attendi la fine dell'azione."
		return false
	for object: Node in participants.values():
		if is_instance_valid(object) and object.has_method("blocks_saving") and bool(object.call("blocks_saving")):
			last_error = "Salvataggio non disponibile durante combattimenti o movimenti."
			return false
	return true

func capture_world() -> void:
	for id: StringName in participants.keys():
		var object: Node = participants[id]
		if is_instance_valid(object) and object.has_method("get_persistent_state"):
			set_object_state(id, object.call("get_persistent_state"))

func save_checkpoint() -> bool:
	if not can_save():
		return false
	var scene := get_tree().current_scene
	var player := get_tree().get_first_node_in_group("player")
	if scene == null or scene.scene_file_path.is_empty() or not player.has_method("get_save_state"):
		last_error = "Questa scena non supporta il salvataggio."
		return false
	capture_world()
	var candidate := {
		"version": VERSION,
		"scene": scene.scene_file_path,
		"timestamp": Time.get_datetime_string_from_system(),
		"player": player.call("get_save_state"),
		"inventory": InventoryManager.get_snapshot(),
		"world": world_states.duplicate(true)
	}
	var config := ConfigFile.new()
	config.set_value("checkpoint", "data", candidate)
	var temporary := save_path + ".tmp"
	var error := config.save(temporary)
	if error == OK:
		error = DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(save_path))
	if error != OK:
		last_error = "Impossibile scrivere il salvataggio (" + str(error) + ")."
		return false
	checkpoint = candidate.duplicate(true)
	checkpoint_saved.emit()
	return true

func read_checkpoint() -> Dictionary:
	var config := ConfigFile.new()
	if config.load(save_path) != OK:
		return {}
	var data: Variant = config.get_value("checkpoint", "data", {})
	if not data is Dictionary:
		return {}
	if int(data.get("version", -1)) != VERSION or not data.get("scene") is String:
		return {}
	if (save_path == MAIN_SLOT and data.scene == TEST_SCENE) or (save_path == TEST_SLOT and data.scene != TEST_SCENE):
		return {}
	if not ResourceLoader.exists(String(data.scene)):
		return {}
	if not data.get("player") is Dictionary or not data.get("inventory") is Dictionary or not data.get("world") is Dictionary:
		return {}
	var state: Dictionary = data.player
	if not state.get("transform") is Transform3D or not state.get("weapon") is Dictionary or int(state.get("health", 0)) <= 0:
		return {}
	for value: Variant in data.world.values():
		if not value is Dictionary:
			return {}
	for value: Variant in data.inventory.values():
		if not value is int or value <= 0:
			return {}
	return data.duplicate(true)

func has_disk_save() -> bool:
	return not read_checkpoint().is_empty()

func select_scene_slot(scene_path: String) -> void:
	# Preserve explicit fixture paths used by automated tests.
	if save_path in [MAIN_SLOT, TEST_SLOT]:
		save_path = TEST_SLOT if scene_path == TEST_SCENE else MAIN_SLOT

func has_scene_save() -> bool:
	var scene := get_tree().current_scene
	if scene == null:
		return false
	var data := read_checkpoint()
	return not data.is_empty() and String(data.scene) == scene.scene_file_path

func start_new_game(scene_path: String) -> void:
	select_scene_slot(scene_path)
	checkpoint.clear()
	world_states.clear()
	participants.clear()
	InventoryManager.clear()
	new_game_scene = scene_path

func continue_game() -> bool:
	var data := read_checkpoint()
	if data.is_empty() or busy:
		last_error = "Salvataggio assente o non valido."
		return false
	return await _load_scene(String(data.scene), data)

func restart_after_death() -> void:
	if busy:
		return
	var path := get_tree().current_scene.scene_file_path
	start_new_game(path)
	await _load_scene(path, {})

func continue_after_death() -> bool:
	if busy or not has_scene_save():
		return false
	return await continue_game()

func _load_scene(scene_path: String, data: Dictionary) -> bool:
	var transition := get_node("/root/SceneTransition")
	if busy or transition._busy:
		last_error = "Caricamento in corso."
		return false
	busy = true
	restoring = true
	GameplayUI.close_immediately()
	GameplayUI.clear_notice()
	get_node("/root/PauseMenu").close_for_scene_change()
	get_tree().paused = true
	var caption := "NUOVA PARTITA" if data.is_empty() else "CARICA SALVATAGGIO"
	var packed: PackedScene = await transition.load_scene(scene_path, caption)
	if packed == null:
		last_error = "Impossibile caricare la scena del salvataggio."
		get_tree().paused = false
		busy = false
		restoring = false
		return false
	world_states = data.get("world", {}).duplicate(true)
	InventoryManager.restore_snapshot(data.get("inventory", {}))
	participants.clear()
	var error := get_tree().change_scene_to_packed(packed)
	if error != OK:
		last_error = "Impossibile caricare la scena."
		get_tree().paused = false
		busy = false
		restoring = false
		transition.cancel_loading()
		return false
	await get_tree().process_frame
	await get_tree().process_frame
	await transition.wait_scene_initialization()
	var player := get_tree().get_first_node_in_group("player")
	transition.set_stage(95.0, "Ripristino della partita" if not data.is_empty() else "Preparazione della partita")
	if not data.is_empty() and player != null:
		player.call("apply_save_state", data.player)
	var restore_ids: Array = participants.keys()
	restore_ids.sort_custom(func(a: StringName, b: StringName) -> bool:
		return _restore_priority(participants[a]) < _restore_priority(participants[b]))
	for id: StringName in restore_ids:
		var object: Node = participants.get(id)
		if is_instance_valid(object) and world_states.has(String(id)):
			await object.call("apply_persistent_state", object_state(id))
	await get_tree().process_frame
	world_restored.emit()
	await transition.prepare_scene_for_reveal()
	if transition != null:
		await transition.reveal()
	if not data.is_empty():
		checkpoint = data.duplicate(true)
	restoring = false
	busy = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	restore_completed.emit()
	return true

func _restore_priority(object: Node) -> int:
	return int(object.call("restore_priority")) if is_instance_valid(object) and object.has_method("restore_priority") else 0
