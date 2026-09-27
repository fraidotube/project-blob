extends Node3D

@export var power_system: Node
@export var lights_root: Node

const OUTLINE_SHADER := preload(
	"res://assets/shaders/interactable_outline_screen.gdshader"
)

@export var interaction_name := "INTERRUTTORE"
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
	_collect_interaction_geometry(self)
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
	return "SPEGNI" if lights_on else "ACCENDI"


func get_interaction_color() -> Color:
	return interaction_color


var lights_on := false


func _ready() -> void:
	if power_system:
		power_system.power_changed.connect(_on_power_changed)

	_set_lights(false)
	_setup_interaction_outline()


func interact(_player: Node) -> void:
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
