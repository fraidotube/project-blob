extends Node3D

@export_category("Banana shape")
@export var width: float = 5.6
@export var curve_depth: float = 1.45
@export var height_curve: float = 0.18
@export var radius_depth: float = 0.48
@export var radius_vertical: float = 0.42
@export var path_segments: int = 30
@export var ring_segments: int = 16
@export var tip_power: float = 0.55

@export_category("Motion")
@export var lifetime: float = 3.00
@export var travel_distance: float = 15.0
@export var grow_only_fraction: float = 0.08
@export var start_scale: Vector3 = Vector3(0.14, 0.14, 0.14)
@export var end_scale: Vector3 = Vector3(3.40, 1.90, 1.65)
@export var fade_start_fraction: float = 0.90

@export_category("Damage")
@export var damage_enabled: bool = true
@export var damage_amount: int = 28
@export var damage_half_width: float = 2.8
@export var damage_half_height: float = 1.15
@export var damage_half_depth: float = 1.05

@onready var core: MeshInstance3D = $Core
@onready var shell: MeshInstance3D = $Shell

var core_material: ShaderMaterial
var shell_material: ShaderMaterial

var travel_direction_world: Vector3 = Vector3.ZERO
var start_position_world: Vector3 = Vector3.ZERO
var elapsed: float = 0.0
var started: bool = false

var damaged_targets: Dictionary = {}


func _ready() -> void:
	_build_banana_meshes()
	_duplicate_materials()

	scale = start_scale
	set_process(false)


func start_wave(
	spawn_global_position: Vector3,
	direction_world: Vector3
) -> void:
	global_position = spawn_global_position

	travel_direction_world = direction_world
	travel_direction_world.y = 0.0

	if travel_direction_world.length_squared() <= 0.0001:
		travel_direction_world = Vector3(
			0.0,
			0.0,
			-1.0
		)

	travel_direction_world = (
		travel_direction_world.normalized()
	)

	look_at(
		global_position
		+ travel_direction_world,
		Vector3.UP,
		false
	)

	start_position_world = global_position
	elapsed = 0.0
	scale = start_scale
	damaged_targets.clear()
	started = true

	set_process(true)


func _process(delta: float) -> void:
	if not started:
		return

	elapsed += delta

	var t := clampf(
		elapsed / maxf(lifetime, 0.01),
		0.0,
		1.0
	)

	var motion_t := 0.0

	if t > grow_only_fraction:
		motion_t = inverse_lerp(
			grow_only_fraction,
			1.0,
			t
		)

	motion_t = clampf(
		motion_t,
		0.0,
		1.0
	)

	# Continuous straight-line motion.
	global_position = (
		start_position_world
		+ travel_direction_world
		* travel_distance
		* motion_t
	)

	global_position.y = (
		start_position_world.y
	)

	# Continuous visible expansion.
	var grow_t := smoothstep(
		0.0,
		1.0,
		t
	)

	scale = start_scale.lerp(
		end_scale,
		grow_t
	)

	if damage_enabled:
		_check_player_damage()

	var dissolve_value := 0.0

	if t > fade_start_fraction:
		dissolve_value = inverse_lerp(
			fade_start_fraction,
			1.0,
			t
		)

	if core_material != null:
		core_material.set_shader_parameter(
			"dissolve",
			dissolve_value
		)

	if shell_material != null:
		shell_material.set_shader_parameter(
			"dissolve",
			dissolve_value
		)

	if t >= 1.0:
		queue_free()


func _check_player_damage() -> void:
	if damage_amount <= 0:
		return

	for node: Node in (
		get_tree()
		.get_nodes_in_group("player")
	):
		if not is_instance_valid(node):
			continue

		if not node is Node3D:
			continue

		var target := node as Node3D

		var target_id := (
			target.get_instance_id()
		)

		if damaged_targets.has(
			target_id
		):
			continue

		var local_position := (
			to_local(
				target.global_position
			)
		)

		if absf(local_position.x) > damage_half_width:
			continue

		if absf(local_position.y) > damage_half_height:
			continue

		if absf(local_position.z) > damage_half_depth:
			continue

		if node.has_method(
			"take_damage"
		):
			node.take_damage(
				damage_amount
			)

			damaged_targets[
				target_id
			] = true


func _build_banana_meshes() -> void:
	core.mesh = (
		_create_front_arc_mesh(
			1.0
		)
	)

	shell.mesh = (
		_create_front_arc_mesh(
			1.10
		)
	)


func _create_front_arc_mesh(
	radius_multiplier: float
) -> ArrayMesh:
	var safe_path_segments := maxi(
		path_segments,
		6
	)

	var safe_ring_segments := maxi(
		ring_segments,
		6
	)

	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()

	for i: int in range(
		safe_path_segments + 1
	):
		var t := (
			float(i)
			/ float(safe_path_segments)
		)

		var x := lerpf(
			-width * 0.5,
			width * 0.5,
			t
		)

		var center := Vector3(
			x,
			sin(PI * t)
				* height_curve,
			-sin(PI * t)
				* curve_depth
		)

		var taper := sin(
			PI * t
		)

		taper = pow(
			maxf(taper, 0.0),
			tip_power
		)

		var depth_radius := (
			radius_depth
			* maxf(taper, 0.06)
			* radius_multiplier
		)

		var vertical_radius := (
			radius_vertical
			* maxf(taper, 0.06)
			* radius_multiplier
		)

		var dt := (
			1.0
			/ float(
				safe_path_segments
			)
		)

		var t_prev := maxf(
			t - dt,
			0.0
		)

		var t_next := minf(
			t + dt,
			1.0
		)

		var x_prev := lerpf(
			-width * 0.5,
			width * 0.5,
			t_prev
		)

		var x_next := lerpf(
			-width * 0.5,
			width * 0.5,
			t_next
		)

		var prev_center := Vector3(
			x_prev,
			sin(PI * t_prev)
				* height_curve,
			-sin(PI * t_prev)
				* curve_depth
		)

		var next_center := Vector3(
			x_next,
			sin(PI * t_next)
				* height_curve,
			-sin(PI * t_next)
				* curve_depth
		)

		var tangent := (
			next_center
			- prev_center
		).normalized()

		var vertical_axis := (
			Vector3.UP
		)

		var depth_axis := (
			tangent.cross(
				vertical_axis
			)
		).normalized()

		if (
			depth_axis.length_squared()
			<= 0.0001
		):
			depth_axis = (
				Vector3.FORWARD
			)

		vertical_axis = (
			depth_axis.cross(
				tangent
			)
		).normalized()

		for ring_index: int in range(
			safe_ring_segments
		):
			var ring_t := (
				float(ring_index)
				/ float(
					safe_ring_segments
				)
			)

			var angle := (
				TAU * ring_t
			)

			var radial := (
				depth_axis
					* cos(angle)
					* depth_radius
				+ vertical_axis
					* sin(angle)
					* vertical_radius
			)

			vertices.append(
				center + radial
			)

			normals.append(
				radial.normalized()
			)

			uvs.append(
				Vector2(
					ring_t,
					t
				)
			)

	for i: int in range(
		safe_path_segments
	):
		for ring_index: int in range(
			safe_ring_segments
		):
			var next_ring := (
				(ring_index + 1)
				% safe_ring_segments
			)

			var current_a := (
				i
				* safe_ring_segments
				+ ring_index
			)

			var current_b := (
				i
				* safe_ring_segments
				+ next_ring
			)

			var next_a := (
				(i + 1)
				* safe_ring_segments
				+ ring_index
			)

			var next_b := (
				(i + 1)
				* safe_ring_segments
				+ next_ring
			)

			indices.append(
				current_a
			)

			indices.append(
				next_a
			)

			indices.append(
				current_b
			)

			indices.append(
				current_b
			)

			indices.append(
				next_a
			)

			indices.append(
				next_b
			)

	var arrays := []
	arrays.resize(
		Mesh.ARRAY_MAX
	)

	arrays[
		Mesh.ARRAY_VERTEX
	] = vertices

	arrays[
		Mesh.ARRAY_NORMAL
	] = normals

	arrays[
		Mesh.ARRAY_TEX_UV
	] = uvs

	arrays[
		Mesh.ARRAY_INDEX
	] = indices

	var mesh := ArrayMesh.new()

	mesh.add_surface_from_arrays(
		Mesh.PRIMITIVE_TRIANGLES,
		arrays
	)

	return mesh


func _duplicate_materials() -> void:
	var core_active := (
		core.get_active_material(0)
	)

	if core_active is ShaderMaterial:
		core_material = (
			core_active
				as ShaderMaterial
		).duplicate() as ShaderMaterial

		core.material_override = (
			core_material
		)

	var shell_active := (
		shell.get_active_material(0)
	)

	if shell_active is ShaderMaterial:
		shell_material = (
			shell_active
				as ShaderMaterial
		).duplicate() as ShaderMaterial

		shell.material_override = (
			shell_material
		)
