extends Node3D

const SLASH_SCENE: PackedScene = preload(
	"res://assets/vfx/bruno_melee_slash/bruno_melee_slash.tscn"
)

@export var repeat_seconds: float = 1.25

var timer: float = 0.0


func _ready() -> void:
	_spawn_slash()


func _process(delta: float) -> void:
	timer += delta

	if timer >= repeat_seconds:
		timer = 0.0
		_spawn_slash()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_SPACE:
				timer = 0.0
				_spawn_slash()


func _spawn_slash() -> void:
	var instance := SLASH_SCENE.instantiate()

	if not instance is Node3D:
		instance.queue_free()
		return

	var slash := instance as Node3D

	add_child(
		slash
	)

	slash.position = Vector3(
		0.0,
		1.35,
		0.0
	)
