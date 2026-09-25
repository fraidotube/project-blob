extends Node3D

@export var power_system: Node
@export var lights_root: Node

@onready var area: Area3D = $Area3D

var player_inside := false
var lights_on := false


func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

	if power_system:
		power_system.power_changed.connect(_on_power_changed)

	_set_lights(false)


func _physics_process(_delta: float) -> void:
	if (
		player_inside
		and Input.is_action_just_pressed("interact")
	):
		try_toggle_lights()


func try_toggle_lights() -> void:
	if power_system == null:
		return

	if not power_system.is_power_on():
		return

	lights_on = not lights_on
	_set_lights(lights_on)


func _set_lights(enabled: bool) -> void:
	if lights_root == null:
		return

	for child in lights_root.get_children():
		if child is Light3D:
			child.visible = enabled


func _on_power_changed(is_on: bool) -> void:
	if not is_on:
		lights_on = false
		_set_lights(false)


func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_inside = true


func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_inside = false
