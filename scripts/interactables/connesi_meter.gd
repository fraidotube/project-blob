extends Node3D

@export var power_system: Node
@export var led_red: Light3D
@export var led_green: Light3D


func _ready() -> void:
	if power_system:
		power_system.power_changed.connect(_on_power_changed)
		_update_leds(power_system.is_power_on())
	else:
		_update_leds(false)


func interact() -> void:
	toggle_meter()


func toggle_meter() -> void:
	if power_system == null:
		return

	power_system.toggle_power()


func _on_power_changed(is_on: bool) -> void:
	_update_leds(is_on)


func _update_leds(is_on: bool) -> void:
	if led_red:
		led_red.visible = not is_on

	if led_green:
		led_green.visible = is_on
