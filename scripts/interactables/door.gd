extends Node3D

@export var open_angle := 90.0
@export var open_speed := 4.0
@export var auto_close := false
@export var auto_close_delay := 3.0
@export var interaction_name := "PORTA"

const OUTLINE_SHADER := preload(
	"res://assets/shaders/interactable_outline_screen.gdshader"
)

@export var interaction_color := Color("ffffff")
@export_range(0.0001, 0.02, 0.0001) var outline_width := 0.0015
@export var interaction_visual_roots: Array[NodePath] = []

@export_group("Door Audio")
@export var open_sound: AudioStream
@export var close_sound: AudioStream
@export_range(-40.0, 12.0, 0.5) var door_audio_volume_db := 0.0
@export_range(1.0, 50.0, 0.5) var door_audio_max_distance := 12.0

var outline_material: ShaderMaterial
var outlined_meshes: Array[GeometryInstance3D] = []


func _setup_interaction_outline() -> void:
	outline_material = ShaderMaterial.new()
	outline_material.shader = OUTLINE_SHADER
	outline_material.set_shader_parameter(
		"outline_color",
		interaction_color
	)
	outline_material.set_shader_parameter(
		"outline_width",
		outline_width
	)

	outlined_meshes.clear()

	if interaction_visual_roots.is_empty():
		_collect_interaction_geometry(self)
	else:
		for path: NodePath in interaction_visual_roots:
			var visual_root := get_node_or_null(path)
			if visual_root != null:
				_collect_interaction_geometry(visual_root)

	set_interaction_focus(false)


func _collect_interaction_geometry(node: Node) -> void:
	if node.name == "InteractionOutline":
		return
	if node.name == "OutlineBuilder":
		return
	if node.name == "InteractionOutlineProxy":
		return

	if node is GeometryInstance3D:
		outlined_meshes.append(node as GeometryInstance3D)

	for child: Node in node.get_children():
		_collect_interaction_geometry(child)


func set_interaction_focus(enabled: bool) -> void:
	for mesh: GeometryInstance3D in outlined_meshes:
		if not is_instance_valid(mesh):
			continue

		mesh.material_overlay = outline_material if enabled else null


func get_interaction_color() -> Color:
	return interaction_color


@onready var door_body: Node3D = $DoorBody
@onready var area: Area3D = $Area3D

var is_open := false
var player_inside := false
var target_rotation_y := 0.0
var auto_close_timer: Timer
var auto_close_pending := false
var door_body_rest_transform: Transform3D

var door_audio: AudioStreamPlayer3D
var close_sound_pending := false


func _ready() -> void:
	door_body_rest_transform = door_body.transform

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

	auto_close_timer = Timer.new()
	auto_close_timer.one_shot = true
	auto_close_timer.timeout.connect(_on_auto_close_timeout)
	add_child(auto_close_timer)

	_setup_door_audio()
	_setup_interaction_outline()


func _setup_door_audio() -> void:
	door_audio = AudioStreamPlayer3D.new()
	door_audio.name = "DoorAudio"
	door_audio.bus = &"SFX"
	door_audio.volume_db = door_audio_volume_db
	door_audio.max_distance = door_audio_max_distance
	add_child(door_audio)


func _physics_process(delta: float) -> void:
	rotation.y = lerp_angle(
		rotation.y,
		target_rotation_y,
		open_speed * delta
	)

	# Il suono di chiusura deve partire quando la porta è realmente
	# arrivata a battuta, non quando inizia a muoversi.
	if (
		close_sound_pending
		and not is_open
		and absf(
			angle_difference(
				rotation.y,
				target_rotation_y
			)
		) <= deg_to_rad(0.6)
	):
		rotation.y = target_rotation_y
		close_sound_pending = false
		_play_door_sound(close_sound)

	var desired_body_transform := (
		global_transform * door_body_rest_transform
	)

	door_body.global_transform = desired_body_transform


func get_interaction_name() -> String:
	return interaction_name


func get_interaction_action() -> String:
	return "CHIUDI" if is_open else "APRI"


func interact(_player: Node) -> void:
	toggle_door()


func toggle_door() -> void:
	if is_open:
		close_door()
	else:
		open_door()


func open_door() -> void:
	if is_open:
		return

	is_open = true
	auto_close_pending = false
	close_sound_pending = false
	target_rotation_y = deg_to_rad(open_angle)

	_play_door_sound(open_sound)

	if auto_close:
		auto_close_timer.start(auto_close_delay)


func close_door() -> void:
	if not is_open:
		return

	is_open = false
	target_rotation_y = 0.0
	auto_close_pending = false
	auto_close_timer.stop()

	close_sound_pending = (
		close_sound != null
	)


func _play_door_sound(stream: AudioStream) -> void:
	if door_audio == null:
		return

	if stream == null:
		return

	door_audio.stop()
	door_audio.stream = stream
	door_audio.volume_db = door_audio_volume_db
	door_audio.max_distance = door_audio_max_distance
	door_audio.play()


func _on_auto_close_timeout() -> void:
	if not is_open:
		return

	if player_inside:
		auto_close_pending = true
	else:
		close_door()


func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_inside = true


func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_inside = false

		if auto_close_pending and is_open:
			close_door()
