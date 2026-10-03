extends Node3D

@export_category("Slash shape")
@export var radius: float = 2.25
@export var ribbon_width: float = 0.72
@export var arc_degrees: float = 125.0
@export var segments: int = 48

@export_category("Animation")
@export var lifetime: float = 0.30
@export var start_scale: float = 0.72
@export var end_scale: float = 1.18
@export var start_angle_degrees: float = -28.0
@export var end_angle_degrees: float = 24.0

@onready var slash_mesh: MeshInstance3D = $SlashMesh
@onready var sparks: GPUParticles3D = $Sparks

var slash_material: ShaderMaterial


func _ready() -> void:
	_build_ribbon()

	var active_material := slash_mesh.get_active_material(0)

	if active_material is ShaderMaterial:
		slash_material = (
			active_material as ShaderMaterial
		).duplicate() as ShaderMaterial

		slash_mesh.material_override = slash_material

	scale = Vector3.ONE * start_scale
	rotation_degrees.z = start_angle_degrees

	if sparks != null:
		sparks.restart()

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self,
		"scale",
		Vector3.ONE * end_scale,
		lifetime
	)

	tween.tween_property(
		self,
		"rotation_degrees:z",
		end_angle_degrees,
		lifetime
	)

	if slash_material != null:
		tween.tween_method(
			func(value: float) -> void:
				slash_material.set_shader_parameter(
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


func _build_ribbon() -> void:
	var safe_segments := maxi(
		segments,
		4
	)

	var safe_radius := maxf(
		radius,
		0.1
	)

	var safe_width := clampf(
		ribbon_width,
		0.05,
		safe_radius * 0.95
	)

	var half_angle := deg_to_rad(
		arc_degrees * 0.5
	)

	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()

	for i: int in range(
		safe_segments + 1
	):
		var t := (
			float(i)
			/ float(safe_segments)
		)

		var angle := lerpf(
			-half_angle,
			half_angle,
			t
		)

		# Taper at both ends: this is a slash ribbon, not a fan.
		var taper := sin(
			PI * t
		)

		taper = pow(
			maxf(taper, 0.0),
			0.42
		)

		var half_width := (
			safe_width
			* 0.5
			* taper
		)

		var inner_radius := (
			safe_radius
			- half_width
		)

		var outer_radius := (
			safe_radius
			+ half_width
		)

		var direction := Vector3(
			sin(angle),
			cos(angle),
			0.0
		)

		vertices.append(
			direction * inner_radius
		)

		vertices.append(
			direction * outer_radius
		)

		normals.append(
			Vector3(0.0, 0.0, 1.0)
		)

		normals.append(
			Vector3(0.0, 0.0, 1.0)
		)

		uvs.append(
			Vector2(t, 0.0)
		)

		uvs.append(
			Vector2(t, 1.0)
		)

	for i: int in range(
		safe_segments
	):
		var base := i * 2

		indices.append(base)
		indices.append(base + 1)
		indices.append(base + 2)

		indices.append(base + 1)
		indices.append(base + 3)
		indices.append(base + 2)

	var arrays := []
	arrays.resize(
		Mesh.ARRAY_MAX
	)

	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices

	var mesh := ArrayMesh.new()

	mesh.add_surface_from_arrays(
		Mesh.PRIMITIVE_TRIANGLES,
		arrays
	)

	slash_mesh.mesh = mesh
