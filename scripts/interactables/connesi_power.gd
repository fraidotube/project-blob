extends Node

signal power_changed(is_on: bool)

@export var power_on := false


func is_power_on() -> bool:
	return power_on


func turn_on() -> void:
	if power_on:
		return

	power_on = true
	power_changed.emit(power_on)


func turn_off() -> void:
	if not power_on:
		return

	power_on = false
	power_changed.emit(power_on)


func toggle_power() -> void:
	if power_on:
		turn_off()
	else:
		turn_on()
