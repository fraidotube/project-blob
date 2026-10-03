extends Node3D

@export_category("Shape")
@export var inner_radius: float = 0.45
@export var outer_radius: float = 2.75
@export var arc_degrees: float = 115.0
@export var segments: int = 40

@export_category("Lifetime")
@export var lifetime: float = 0.34
@export var start_scale: float = 0.60
@export var end_scale: float = 1.15
@export var start_rotation_degrees: float = -18.0
@export var end_rotation_degrees: float = 18.0

@onready var slash_mesh: MeshInstance3D = $SlashMesh

var elapsed: float = 0.0


func _ready() -> void:
	_build_arc_mesh()

	scale = Vector3.ONE * start_scale
	rotation_degrees.z = start_rotation_degrees

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
		end_rotation_degrees,
		lifetime
	)

	var material := slash_mesh.get_active_material(0)

	if material is ShaderMaterial:
		var shader_material := material as ShaderMaterial
		tween.tween_method(
			func(value: float) -> void:
				shader_material.set_shader_parameter(
					"overall_alpha",
					value
				),
			1.0,
			0.0,
			lifetime
		)

	tween.chain().tween_callback(
		queue_free
	)


func _build_arc_mesh() -> void:
	var safe_segments := maxi(
		segments,
		3
	)

	var safe_inner := maxf(
		inner_radius,
		0.01
	)

	var safe_outer := maxf(
		outer_radius,
		safe_inner + 0.01
	)

	var half_angle := deg_to_rad(
		arc_degrees * 0.5
	)

	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()

	for index: int in range(
		safe_segments + 1
	):
		var t := (
			float(index)
			/ float(safe_segments)
		)

		var angle := lerpf(
			-half_angle,
			half_angle,
			t
		)

		var direction := Vector3(
			sin(angle),
			cos(angle),
			0.0
		)

		var inner_point := (
			direction * safe_inner
		)

		var outer_point := (
			direction * safe_outer
		)

		vertices.append(
			inner_point
		)
		vertices.append(
			outer_point
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

	for index: int in range(
		safe_segments
	):
		var base := index * 2

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
