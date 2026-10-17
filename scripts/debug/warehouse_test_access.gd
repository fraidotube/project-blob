extends Node
## Accesso temporaneo alla nuova zona: non completa boss o enigmi nel salvataggio.

const SAVE_ID: StringName = &"debug.warehouse_access"
var active := false

func _ready() -> void:
	if not OS.is_debug_build():
		set_process_unhandled_input(false)
		return
	_register.call_deferred()

func _register() -> void:
	SaveManager.register_object(SAVE_ID, self)

func _exit_tree() -> void:
	SaveManager.unregister_object(SAVE_ID, self)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_F4:
		get_viewport().set_input_as_handled()
		open_test_access()

func open_test_access() -> void:
	if not OS.is_debug_build() or get_tree().paused or active:
		return
	var scene := get_parent()
	var encounter = scene.get_node_or_null("AngelastriEncounter")
	var puzzle = scene.get_node_or_null("RegiaIntegration/NetworkPuzzle")
	var player = get_tree().get_first_node_in_group("player")
	if encounter == null or puzzle == null or player == null or SaveManager.restoring:
		GameplayUI.notify("Attendi la fine del caricamento e ripremi F4.")
		return
	if player.is_dead or not player.is_physics_processing() or encounter.starting or encounter.cinematic or encounter.event.stage == "combat":
		GameplayUI.notify("Premi F4 prima dell'incontro con Angelastri.")
		return
	active = true
	encounter.set_process(false)
	encounter.set_process_unhandled_input(false)
	puzzle.state.unlocked = true
	puzzle.state.changed.emit()
	puzzle.exit_door.open_door()
	GameplayUI.notify("TEST F4: porta aliena aperta, Angelastri sospeso. Salvataggi disattivati in questa prova.")

func blocks_saving() -> bool:
	return active

func get_persistent_state() -> Dictionary:
	return {}

func apply_persistent_state(_state: Dictionary) -> void:
	pass
