extends Node3D

const OUTLINE := preload("res://assets/shaders/interactable_outline_screen.gdshader")
var puzzle: Node
var action := ""
var title := ""
var visual: Node3D
var outline: ShaderMaterial

func _ready() -> void:
	outline = ShaderMaterial.new()
	outline.shader = OUTLINE
	outline.set_shader_parameter("outline_color", Color("b86cff"))
	outline.set_shader_parameter("outline_width", 0.0015)

func get_interaction_name() -> String:
	return title

func get_interaction_action() -> String:
	return puzzle.action_label(action)

func get_interaction_color() -> Color:
	return Color("b86cff")

func set_interaction_focus(enabled: bool) -> void:
	if not is_instance_valid(visual):
		return
	var meshes: Array[Node] = visual.find_children("*", "GeometryInstance3D", true, false)
	if visual is GeometryInstance3D:
		meshes.append(visual)
	for mesh: Node in meshes:
		mesh.material_overlay = outline if enabled else null

func interact(_player: Node) -> void:
	set_interaction_focus(false)
	puzzle.interact_action(action)
