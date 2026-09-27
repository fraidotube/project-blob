extends Area3D

const OUTLINE_SHADER := preload("res://assets/shaders/interactable_outline.gdshader")

@export var interaction_name := "TORCIA"
@export var interaction_action := "RACCOGLI"
@export var interaction_color := Color("f2ad47")

var collected := false
var outline_material: ShaderMaterial
var outlined_meshes: Array[GeometryInstance3D] = []


func _ready() -> void:
	outline_material = ShaderMaterial.new()
	outline_material.shader = OUTLINE_SHADER
	outline_material.set_shader_parameter("outline_color", interaction_color)
	outline_material.set_shader_parameter("outline_width", 0.012)
	_collect_geometry($FlashlightVisual)
	set_interaction_focus(false)


func _collect_geometry(node: Node) -> void:
	if node is GeometryInstance3D:
		outlined_meshes.append(node as GeometryInstance3D)
	for child: Node in node.get_children():
		_collect_geometry(child)


func set_interaction_focus(enabled: bool) -> void:
	for mesh: GeometryInstance3D in outlined_meshes:
		mesh.material_overlay = outline_material if enabled else null


func get_interaction_name() -> String:
	return interaction_name


func get_interaction_action() -> String:
	return interaction_action


func get_interaction_color() -> Color:
	return interaction_color


func interact(player: Node) -> void:
	if collected or not player.has_method("equip_flashlight"):
		return
	collected = true
	set_interaction_focus(false)
	player.equip_flashlight()
	queue_free()
