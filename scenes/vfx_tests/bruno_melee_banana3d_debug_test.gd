extends Node3D

const WAVE_SCENE: PackedScene = preload(
	"res://assets/vfx/bruno_melee_banana3d/bruno_melee_banana3d.tscn"
)

@export_category("Debug wave")
@export var auto_repeat: bool = false
@export var repeat_seconds: float = 4.0

@onready var camera_side: Camera3D = $CameraSide
@onready var camera_top: Camera3D = $CameraTop
@onready var camera_front: Camera3D = $CameraFront

@onready var spawn_marker: Marker3D = $SpawnMarker
@onready var target_marker: Marker3D = $TargetMarker

var timer: float = 0.0


func _ready() -> void:
	camera_side.current = true
	_spawn_wave()


func _process(delta: float) -> void:
	if not auto_repeat:
		return

	timer += delta

	if timer >= repeat_seconds:
		timer = 0.0
		_spawn_wave()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	if not event.pressed:
		return

	if event.echo:
		return

	match event.keycode:
		KEY_SPACE:
			timer = 0.0
			_spawn_wave()

		KEY_1:
			camera_side.current = true

		KEY_2:
			camera_top.current = true

		KEY_3:
			camera_front.current = true


func _spawn_wave() -> void:
	var instance := WAVE_SCENE.instantiate()

	if not instance is Node3D:
		instance.queue_free()
		return

	var wave := instance as Node3D

	add_child(
		wave
	)

	var spawn_position := (
		spawn_marker.global_position
	)

	var target_position := (
		target_marker.global_position
	)

	var direction := (
		target_position
		- spawn_position
	)

	if wave.has_method(
		"start_wave"
	):
		wave.start_wave(
			spawn_position,
			direction
		)
