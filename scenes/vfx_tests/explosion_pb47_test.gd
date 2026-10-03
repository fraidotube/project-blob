extends Node3D

const EXPLOSION_SCENE: PackedScene = preload(
	"res://assets/vfx/EffettoEsplosione/BigExplosionScene_PB47.tscn"
)

@export var auto_repeat: bool = true
@export var repeat_seconds: float = 3.0

var timer: float = 0.0


func _ready() -> void:
	_spawn_explosion()


func _process(delta: float) -> void:
	if not auto_repeat:
		return

	timer += delta

	if timer >= repeat_seconds:
		timer = 0.0
		_spawn_explosion()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_SPACE:
				timer = 0.0
				_spawn_explosion()


func _spawn_explosion() -> void:
	var fx := EXPLOSION_SCENE.instantiate()

	if not fx is Node3D:
		fx.queue_free()
		return

	add_child(fx)

	var fx_3d := fx as Node3D
	fx_3d.position = Vector3(0.0, 0.9, 0.0)

	get_tree().create_timer(2.8).timeout.connect(
		fx_3d.queue_free
	)
