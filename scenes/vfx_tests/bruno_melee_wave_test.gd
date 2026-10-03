extends Node3D

const WAVE_SCENE: PackedScene = preload(
	"res://assets/vfx/bruno_melee_wave/bruno_melee_wave.tscn"
)

@export var auto_repeat: bool = true
@export var repeat_seconds: float = 1.5

var timer: float = 0.0


func _ready() -> void:
	_spawn_wave()


func _process(delta: float) -> void:
	if not auto_repeat:
		return

	timer += delta

	if timer >= repeat_seconds:
		timer = 0.0
		_spawn_wave()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_SPACE:
				timer = 0.0
				_spawn_wave()


func _spawn_wave() -> void:
	var instance := WAVE_SCENE.instantiate()

	if not instance is Node3D:
		instance.queue_free()
		return

	var wave := instance as Node3D

	add_child(
		wave
	)

	wave.position = Vector3(
		0.0,
		1.35,
		0.0
	)

	wave.rotation_degrees = Vector3(
		0.0,
		0.0,
		-10.0
	)
