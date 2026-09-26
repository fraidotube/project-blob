@tool
extends Node3D


@export var smoke_color: Color = Color(
	"6C6964C7"
):
	set(value):
		smoke_color = value
		_apply_smoke_settings()


@export_range(
	0.0,
	2.0,
	0.01
) var density := 1.0:
	set(value):
		density = value
		_apply_smoke_settings()


@export_range(
	0.0,
	2.0,
	0.01
) var smoke_volume := 0.85:
	set(value):
		smoke_volume = value
		_apply_smoke_settings()


@export_range(
	0.0,
	1.0,
	0.01
) var smoke_aperture := 0.28:
	set(value):
		smoke_aperture = value
		_apply_smoke_settings()


@export var tex_speed := Vector3(
	0.0,
	-0.4,
	0.65
):
	set(value):
		tex_speed = value
		_apply_smoke_settings()


@export_range(
	0.1,
	5.0,
	0.01
) var smoke_scale := 1.0:
	set(value):
		smoke_scale = value
		_apply_smoke_settings()


func _ready() -> void:
	_make_materials_unique()
	_apply_smoke_settings()


func _make_materials_unique() -> void:
	for child in get_children():
		if not child is MeshInstance3D:
			continue

		var mesh_instance := (
			child as MeshInstance3D
		)

		var material: ShaderMaterial = (
			mesh_instance.material_override
			as ShaderMaterial
		)

		if material == null:
			continue

		var unique_material := (
			material.duplicate()
			as ShaderMaterial
		)

		if unique_material == null:
			continue

		mesh_instance.material_override = (
			unique_material
		)


func _apply_smoke_settings() -> void:
	scale = (
		Vector3.ONE
		* smoke_scale
	)

	for child in get_children():
		if not child is MeshInstance3D:
			continue

		var mesh_instance := (
			child as MeshInstance3D
		)

		var material: ShaderMaterial = (
			mesh_instance.material_override
			as ShaderMaterial
		)

		if material == null:
			continue

		material.set_shader_parameter(
			"smoke_color",
			smoke_color
		)

		material.set_shader_parameter(
			"density",
			density
		)

		material.set_shader_parameter(
			"smoke_volume",
			smoke_volume
		)

		material.set_shader_parameter(
			"smoke_aperture",
			smoke_aperture
		)

		material.set_shader_parameter(
			"tex_speed",
			tex_speed
		)
