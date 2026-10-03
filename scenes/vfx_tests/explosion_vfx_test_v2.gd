extends Node3D

@onready var explosion: Node3D = $Explosion
@onready var blast_light: OmniLight3D = $Explosion/BlastLight

var replay_timer: float = 0.0
var light_tween: Tween = null

func _ready() -> void:
	_restart_explosion()


func _process(delta: float) -> void:
	replay_timer += delta

	if replay_timer >= 3.5:
		replay_timer = 0.0
		_restart_explosion()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			replay_timer = 0.0
			_restart_explosion()


func _restart_explosion() -> void:
	for child in explosion.get_children():
		if child is GPUParticles3D:
			child.restart()

	if blast_light != null:
		if light_tween != null:
			light_tween.kill()

		blast_light.light_energy = 7.0
		light_tween = create_tween()
		light_tween.tween_property(
			blast_light,
			"light_energy",
			0.0,
			0.55
		)
