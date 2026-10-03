extends Node3D

@onready var explosion: Node3D = $Explosion

func _ready() -> void:
	_restart_explosion()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			_restart_explosion()


func _restart_explosion() -> void:
	for child in explosion.get_children():
		if child is GPUParticles3D:
			child.restart()
