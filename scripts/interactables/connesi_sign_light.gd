extends Node3D

@export var power_system: Node
@export var lights_root: Node


func _ready() -> void:
	if power_system:
		power_system.power_changed.connect(_on_power_changed)
		_set_lights(power_system.is_power_on())
	else:
		_set_lights(false)


func _on_power_changed(is_on: bool) -> void:
	_set_lights(is_on)


func _set_lights(enabled: bool) -> void:
	if lights_root == null:
		return

	for child in lights_root.get_children():
		if child is Light3D:
			child.visible = enabled
