extends Node3D

@export_category("Lifetime")
@export var lifetime: float = 0.24

@export_category("Travel")
@export var travel_distance: float = 2.4
@export var start_forward_offset: float = 0.35

@export_category("Scale")
@export var start_scale: Vector3 = Vector3(0.42, 0.55, 0.42)
@export var end_scale: Vector3 = Vector3(1.25, 1.05, 2.20)

@export_category("Shape")
@export var mesh_radius: float = 0.42
@export var mesh_height: float = 1.55
@export var radial_segments: int = 24
@export var rings: int = 8

@onready var core: MeshInstance3D = $Core
@onready var shell: MeshInstance3D = $Shell

var core_material: ShaderMaterial
var shell_material: ShaderMaterial


func _ready() -> void:
	_build_meshes()
	_duplicate_materials()

	position += -transform.basis.z * start_forward_offset
	scale = start_scale

	var target_position := (
		position
		+ -transform.basis.z * travel_distance
	)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self,
		"position",
		target_position,
		lifetime
	)

	tween.tween_property(
		self,
		"scale",
		end_scale,
		lifetime
	)

	if core_material != null:
		tween.tween_method(
			func(value: float) -> void:
				core_material.set_shader_parameter(
					"dissolve",
					value
				),
			0.0,
			1.0,
			lifetime
		)

	if shell_material != null:
		tween.tween_method(
			func(value: float) -> void:
				shell_material.set_shader_parameter(
					"dissolve",
					value
				),
			0.0,
			1.0,
			lifetime
		)

	tween.chain().tween_callback(
		queue_free
	)


func _build_meshes() -> void:
	var capsule := CapsuleMesh.new()

	capsule.radius = mesh_radius
	capsule.height = mesh_height
	capsule.radial_segments = radial_segments
	capsule.rings = rings

	core.mesh = capsule

	var shell_capsule := CapsuleMesh.new()

	shell_capsule.radius = mesh_radius * 1.08
	shell_capsule.height = mesh_height * 1.04
	shell_capsule.radial_segments = radial_segments
	shell_capsule.rings = rings

	shell.mesh = shell_capsule

	# CapsuleMesh is vertical by default.
	# Rotate the two meshes so their long axis points forward (-Z).
	core.rotation_degrees.x = 90.0
	shell.rotation_degrees.x = 90.0


func _duplicate_materials() -> void:
	var core_active := core.get_active_material(0)

	if core_active is ShaderMaterial:
		core_material = (
			core_active as ShaderMaterial
		).duplicate() as ShaderMaterial

		core.material_override = core_material

	var shell_active := shell.get_active_material(0)

	if shell_active is ShaderMaterial:
		shell_material = (
			shell_active as ShaderMaterial
		).duplicate() as ShaderMaterial

		shell.material_override = shell_material
