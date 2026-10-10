extends Node3D
class_name PersistentInteractable

@export var persistent_id: StringName
@export var interaction_name := "OGGETTO"
@export var interaction_color := Color(0.8, 0.9, 1.0)
const OUTLINE := preload("res://assets/shaders/interactable_outline_screen.gdshader")
var _outline: ShaderMaterial

func _ready() -> void:
	_outline = ShaderMaterial.new()
	_outline.shader = OUTLINE
	_outline.set_shader_parameter("outline_color", interaction_color)
	_outline.set_shader_parameter("outline_width", 0.0015)
	SaveManager.register_object(persistent_id, self)

func _exit_tree() -> void:
	SaveManager.unregister_object(persistent_id, self)

func get_interaction_name() -> String:
	return interaction_name

func get_interaction_action() -> String:
	return "USA"

func get_interaction_color() -> Color:
	return interaction_color

func set_interaction_focus(enabled: bool) -> void:
	for node: Node in find_children("*", "GeometryInstance3D", true, false):
		(node as GeometryInstance3D).material_overlay = _outline if enabled else null

func get_persistent_state() -> Dictionary:
	return {}

func apply_persistent_state(_state: Dictionary) -> void:
	pass

func _box(parent: Node3D, dimensions: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = dimensions
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.65
	mesh.mesh = box
	mesh.material_override = material
	mesh.position = at
	parent.add_child(mesh)
	return mesh

func _interaction_box(dimensions: Vector3, at: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.collision_layer = 2
	body.collision_mask = 0
	body.position = at
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = dimensions
	collision.shape = shape
	body.add_child(collision)
	add_child(body)
	return body
