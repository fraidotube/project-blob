extends Area3D

const OUTLINE_SHADER := preload(
	"res://assets/shaders/interactable_outline_screen.gdshader"
)

@export var interaction_name := "PISTOLA"
@export var interaction_color := Color("e06a3d")
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
	_collect_interaction_geometry($PistolVisual)
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
	return "RACCOGLI"


func get_interaction_color() -> Color:
	return interaction_color


var collected := false


func _ready() -> void:
	_setup_interaction_outline()


func interact(player: Node) -> void:
	if collected:
		return

	if not player.has_method("equip_pistol"):
		return

	collected = true
	set_interaction_focus(false)
	player.equip_pistol()
	queue_free()
