extends Node3D

@export var open_angle := 90.0
@export var open_speed := 4.0

@export var auto_close := false
@export var auto_close_delay := 3.0

const OUTLINE_SHADER := preload(
	"res://assets/shaders/interactable_outline_screen.gdshader"
)

@export var interaction_name := "PORTA"
@export var interaction_color := Color("ffffff")
@export_range(0.0001, 0.02, 0.0001) var outline_width := 0.0015

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
	_collect_interaction_geometry($DoorBody)
	set_interaction_focus(false)


func _collect_interaction_geometry(node: Node) -> void:
	if node is GeometryInstance3D:
		outlined_meshes.append(node as GeometryInstance3D)

	for child: Node in node.get_children():
		_collect_interaction_geometry(child)


func set_interaction_focus(enabled: bool) -> void:
	for mesh: GeometryInstance3D in outlined_meshes:
		if not is_instance_valid(mesh):
			continue

		mesh.material_overlay = outline_material if enabled else null


func get_interaction_name() -> String:
	return interaction_name


func get_interaction_action() -> String:
	return "CHIUDI" if is_open else "APRI"


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


func _ready() -> void:
	door_body_rest_transform = door_body.transform

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

	auto_close_timer = Timer.new()
	auto_close_timer.one_shot = true
	auto_close_timer.timeout.connect(_on_auto_close_timeout)
	add_child(auto_close_timer)

	_setup_interaction_outline()


func _physics_process(delta: float) -> void:
	rotation.y = lerp_angle(
		rotation.y,
		target_rotation_y,
		open_speed * delta
	)

	var desired_body_transform := (
		global_transform * door_body_rest_transform
	)

	door_body.global_transform = desired_body_transform


func interact(_player: Node) -> void:
	toggle_door()


func toggle_door() -> void:
	is_open = not is_open
	auto_close_pending = false

	if is_open:
		target_rotation_y = deg_to_rad(open_angle)

		if auto_close:
			auto_close_timer.start(auto_close_delay)
	else:
		close_door()


func close_door() -> void:
	is_open = false
	target_rotation_y = 0.0
	auto_close_pending = false
	auto_close_timer.stop()


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
