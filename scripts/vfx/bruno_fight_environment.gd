extends Node

@export_category("References")
@export var bruno: Node
@export var lamp_controller_1: Node
@export var lamp_controller_2: Node
@export var lab_exit_door: Node

@export_category("Debug")
@export var debug_logs: bool = true

var _fight_environment_started: bool = false
var _fight_environment_finished: bool = false


func _process(_delta: float) -> void:
	if bruno == null:
		return

	if not _fight_environment_started:
		_try_start_fight_environment()
		return

	if not _fight_environment_finished:
		_try_finish_fight_environment()


func _try_start_fight_environment() -> void:
	if not _has_property(bruno, &"ai_active"):
		return

	if not _has_property(bruno, &"cinematic_locked"):
		return

	var ai_active := bool(bruno.get("ai_active"))
	var cinematic_locked := bool(bruno.get("cinematic_locked"))

	if not ai_active:
		return

	if cinematic_locked:
		return

	_start_fight_environment()


func _start_fight_environment() -> void:
	if _fight_environment_started:
		return

	_fight_environment_started = true

	_break_lamp(lamp_controller_1, "Lampione 1")
	_break_lamp(lamp_controller_2, "Lampione 2")
	_force_lab_door_open()

	if debug_logs:
		print(
			"[BRUNO ENV] Fight rilevata -> "
			+ "lampioni rotti + porta Lab bloccata aperta."
		)


func _try_finish_fight_environment() -> void:
	if not _has_property(bruno, &"health"):
		return

	var bruno_health := int(bruno.get("health"))

	if bruno_health > 0:
		return

	_finish_fight_environment()


func _finish_fight_environment() -> void:
	if _fight_environment_finished:
		return

	_fight_environment_finished = true

	_release_lab_door()

	if debug_logs:
		print(
			"[BRUNO ENV] Bruno morto -> "
			+ "porta Lab di nuovo normale. "
			+ "I lampioni restano rotti."
		)


func _break_lamp(
	lamp: Node,
	label: String
) -> void:
	if lamp == null:
		push_warning(
			"[BRUNO ENV] ",
			label,
			" non assegnato."
		)
		return

	if not lamp.has_method("set_broken"):
		push_warning(
			"[BRUNO ENV] ",
			label,
			" non espone set_broken(). Nodo: ",
			lamp.get_path()
		)
		return

	lamp.call("set_broken")

	if debug_logs:
		print(
			"[BRUNO ENV] ",
			label,
			" -> BROKEN | ",
			lamp.get_path()
		)


func _force_lab_door_open() -> void:
	if lab_exit_door == null:
		push_warning(
			"[BRUNO ENV] Lab Exit Door non assegnata."
		)
		return

	if not lab_exit_door.has_method("set_forced_open"):
		push_warning(
			"[BRUNO ENV] Lab Exit Door non espone set_forced_open(). Nodo: ",
			lab_exit_door.get_path()
		)
		return

	lab_exit_door.call(
		"set_forced_open",
		true
	)

	if debug_logs:
		print(
			"[BRUNO ENV] Porta Lab -> FORCED OPEN | ",
			lab_exit_door.get_path()
		)


func _release_lab_door() -> void:
	if lab_exit_door == null:
		return

	if not lab_exit_door.has_method("set_forced_open"):
		return

	lab_exit_door.call(
		"set_forced_open",
		false
	)

	if debug_logs:
		print(
			"[BRUNO ENV] Porta Lab -> NORMAL | ",
			lab_exit_door.get_path()
		)


func _has_property(
	object: Object,
	property_name: StringName
) -> bool:
	for property_info: Dictionary in object.get_property_list():
		if StringName(
			String(property_info.get("name", ""))
		) == property_name:
			return true

	return false
