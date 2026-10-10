extends Node
class_name PersistentObject

enum Kind { PROPERTIES, PICKUP, SWING_DOOR, METEORITE_EVENT, POWER, TV, BOSS_ENVIRONMENT }
@export var persistent_id: StringName
@export var target: Node
@export var kind: Kind = Kind.PROPERTIES
@export var properties: Array[StringName] = []

func _ready() -> void:
	if target == null:
		target = get_parent()
	SaveManager.register_object(persistent_id, self)

func _exit_tree() -> void:
	if kind == Kind.PICKUP and SaveManager.participants.get(persistent_id) == self and is_instance_valid(target) and bool(target.get("collected")):
		SaveManager.set_object_state(persistent_id, {"collected": true})
	SaveManager.unregister_object(persistent_id, self)

func get_persistent_state() -> Dictionary:
	match kind:
		Kind.PICKUP:
			return {"collected": bool(target.get("collected"))}
		Kind.SWING_DOOR:
			return {"is_open": bool(target.get("is_open")), "forced_open": bool(target.get("forced_open"))}
		Kind.METEORITE_EVENT:
			return {"completed": bool(target.get("_already_played"))}
		Kind.POWER:
			return {"power_on": bool(target.get("power_on"))}
		Kind.TV:
			return {"tv_on": bool(target.get("tv_on"))}
		Kind.BOSS_ENVIRONMENT:
			return {"finished": bool(target.get("_fight_environment_finished"))}
	var state := {}
	for property: StringName in properties:
		state[String(property)] = target.get(property)
	return state

func blocks_saving() -> bool:
	if kind == Kind.METEORITE_EVENT:
		return bool(target.get("_cinematic_running"))
	if kind == Kind.SWING_DOOR:
		return absf(angle_difference(float(target.get("rotation").y), float(target.get("target_rotation_y")))) > 0.01
	return false

func restore_priority() -> int:
	if kind == Kind.POWER:
		return -10
	if kind == Kind.TV:
		return 10
	if kind == Kind.BOSS_ENVIRONMENT:
		return 20
	return 0

func apply_persistent_state(state: Dictionary) -> void:
	match kind:
		Kind.PICKUP:
			if bool(state.get("collected", false)):
				target.set("collected", true)
				target.queue_free()
		Kind.SWING_DOOR:
			var opened := bool(state.get("is_open", false))
			target.set("is_open", opened)
			target.set("forced_open", bool(state.get("forced_open", false)))
			var angle := deg_to_rad(float(target.get("open_angle"))) if opened else 0.0
			target.set("target_rotation_y", angle)
			target.rotation.y = angle
		Kind.METEORITE_EVENT:
			target.set("_already_played", bool(state.get("completed", false)))
		Kind.POWER:
			target.call("turn_on" if bool(state.get("power_on", false)) else "turn_off")
		Kind.TV:
			target.call("turn_on_tv" if bool(state.get("tv_on", false)) else "turn_off_tv")
		Kind.BOSS_ENVIRONMENT:
			if bool(state.get("finished", false)):
				target.set("_fight_environment_started", true)
				target.set("_fight_environment_finished", true)
				target.call("_release_lab_door")
				for property: StringName in [&"lamp_controller_1", &"lamp_controller_2"]:
					var lamp: Node = target.get(property)
					if lamp != null:
						lamp.call("set_broken")
		_:
			for property: StringName in properties:
				if state.has(String(property)):
					target.set(property, state[String(property)])
