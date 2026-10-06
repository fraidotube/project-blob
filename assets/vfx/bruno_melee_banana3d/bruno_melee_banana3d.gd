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


@export_category("Obstacle Interaction")
@export var obstacle_interaction_enabled: bool = true
@export_flags_3d_physics var obstacle_collision_mask: int = 1
@export_enum("Stop", "Attenuate") var obstacle_mode: int = 0
@export_range(0.0, 3.0, 0.05) var obstacle_check_start_distance: float = 0.80
@export_range(0.0, 1.0, 0.05) var obstacle_power_loss: float = 0.55
@export_range(0.0, 1.0, 0.05) var obstacle_min_power: float = 0.20
@export_range(0.02, 1.0, 0.01) var obstacle_stop_fade_time: float = 0.12
@export_range(3, 21, 2) var obstacle_horizontal_rays: int = 13
@export_range(0.1, 1.0, 0.05) var obstacle_width_factor: float = 0.85
@export var obstacle_debug_print: bool = false

@export_category("Wave Audio")
@export var flight_sound: AudioStream = preload(
	"res://assets/models/enemies/bruno_buozzi/onda_energetica.mp3"
)
@export var player_hit_sound: AudioStream = preload(
	"res://assets/models/enemies/bruno_buozzi/onda_colpito.mp3"
)
@export_range(-24.0, 12.0, 0.5) var flight_sound_volume_db: float = 0.0
@export_range(-24.0, 12.0, 0.5) var player_hit_sound_volume_db: float = 0.0
@export_range(1.0, 100.0, 1.0) var wave_audio_max_distance: float = 35.0

@onready var core: MeshInstance3D = $Core
@onready var shell: MeshInstance3D = $Shell

var core_material: ShaderMaterial
var shell_material: ShaderMaterial

var travel_direction_world: Vector3 = Vector3.ZERO
var start_position_world: Vector3 = Vector3.ZERO
var elapsed: float = 0.0
var started: bool = false

var damaged_targets: Dictionary = {}

var previous_position_world: Vector3 = Vector3.ZERO
var source_body_rid: RID
var ignored_obstacle_rids: Array[RID] = []
var power_multiplier: float = 1.0
var stopping_on_obstacle: bool = false
var obstacle_stop_elapsed: float = 0.0
var obstacle_stop_position_world: Vector3 = Vector3.ZERO
var base_core_emission_boost: float = 1.0
var base_shell_emission_boost: float = 1.0
var flight_audio_player: AudioStreamPlayer3D = null


func _ready() -> void:
	_build_banana_meshes()
	_duplicate_materials()

	scale = start_scale
	set_process(false)


func start_wave(
	spawn_global_position: Vector3,
	direction_world: Vector3,
	source_node: Node = null
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
	previous_position_world = global_position
	elapsed = 0.0
	scale = start_scale
	damaged_targets.clear()
	ignored_obstacle_rids.clear()
	power_multiplier = 1.0
	stopping_on_obstacle = false
	obstacle_stop_elapsed = 0.0
	obstacle_stop_position_world = global_position

	source_body_rid = RID()

	if source_node is CollisionObject3D:
		source_body_rid = (
			source_node as CollisionObject3D
		).get_rid()

	started = true

	_start_flight_audio()

	set_process(true)


func _process(delta: float) -> void:
	if not started:
		return

	if stopping_on_obstacle:
		_process_obstacle_stop(delta)
		return

	elapsed += delta

	var t: float = clampf(
		elapsed / maxf(lifetime, 0.01),
		0.0,
		1.0
	)

	var motion_t: float = 0.0

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

	var grow_t: float = smoothstep(
		0.0,
		1.0,
		t
	)

	var next_scale: Vector3 = start_scale.lerp(
		end_scale,
		grow_t
	)

	var next_position_world: Vector3 = (
		start_position_world
		+ travel_direction_world
		* travel_distance
		* motion_t
	)

	next_position_world.y = start_position_world.y

	if (
		obstacle_interaction_enabled
		and start_position_world.distance_to(
			next_position_world
		) >= obstacle_check_start_distance
	):
		var visual_half_width: float = (
			width
			* next_scale.x
			* 0.5
			* obstacle_width_factor
		)

		var obstacle_hit: Dictionary = (
			_find_obstacle_between(
				previous_position_world,
				next_position_world,
				visual_half_width
			)
		)

		if not obstacle_hit.is_empty():
			if _handle_obstacle_hit(
				obstacle_hit
			):
				return

	global_position = next_position_world
	previous_position_world = global_position
	scale = next_scale

	if damage_enabled:
		_check_player_damage()

	var dissolve_value: float = 0.0

	if t > fade_start_fraction:
		dissolve_value = inverse_lerp(
			fade_start_fraction,
			1.0,
			t
		)

	_set_dissolve(
		dissolve_value
	)

	if t >= 1.0:
		queue_free()


func _find_obstacle_between(
	from_world: Vector3,
	to_world: Vector3,
	half_width_world: float
) -> Dictionary:
	if from_world.distance_squared_to(
		to_world
	) <= 0.000001:
		return {}

	var ray_count: int = maxi(
		obstacle_horizontal_rays,
		3
	)

	if ray_count % 2 == 0:
		ray_count += 1

	var right_world: Vector3 = global_transform.basis.x
	right_world.y = 0.0

	if right_world.length_squared() <= 0.0001:
		right_world = Vector3.RIGHT

	right_world = right_world.normalized()

	var exclude_rids: Array[RID] = []

	if source_body_rid.is_valid():
		exclude_rids.append(
			source_body_rid
		)

	for obstacle_rid: RID in ignored_obstacle_rids:
		if obstacle_rid.is_valid():
			exclude_rids.append(
				obstacle_rid
			)

	var best_hit: Dictionary = {}
	var best_travel_distance: float = INF

	for ray_index: int in range(ray_count):
		var ray_t: float = 0.5

		if ray_count > 1:
			ray_t = (
				float(ray_index)
				/ float(ray_count - 1)
			)

		var lateral_offset: float = lerpf(
			-half_width_world,
			half_width_world,
			ray_t
		)

		var lateral_world: Vector3 = (
			right_world
			* lateral_offset
		)

		var ray_from: Vector3 = (
			from_world
			+ lateral_world
		)

		var ray_to: Vector3 = (
			to_world
			+ lateral_world
		)

		var query := PhysicsRayQueryParameters3D.create(
			ray_from,
			ray_to
		)

		query.collision_mask = obstacle_collision_mask
		query.collide_with_bodies = true
		query.collide_with_areas = false
		query.hit_from_inside = false
		query.exclude = exclude_rids

		var result: Dictionary = (
			get_world_3d()
			.direct_space_state
			.intersect_ray(
				query
			)
		)

		if result.is_empty():
			continue

		var collider_value: Variant = result.get(
			"collider"
		)

		if collider_value is Node:
			var collider_node := collider_value as Node

			if collider_node.is_in_group(
				"player"
			):
				continue

		var hit_position_value: Variant = result.get(
			"position"
		)

		if not hit_position_value is Vector3:
			continue

		var hit_position := (
			hit_position_value as Vector3
		)

		var ray_travel_distance: float = (
			ray_from.distance_to(
				hit_position
			)
		)

		if ray_travel_distance >= best_travel_distance:
			continue

		best_travel_distance = ray_travel_distance
		best_hit = result.duplicate()

		var root_stop_position: Vector3 = (
			from_world
			+ travel_direction_world
			* ray_travel_distance
		)

		root_stop_position.y = start_position_world.y

		best_hit[
			"wave_root_position"
		] = root_stop_position

	if (
		obstacle_debug_print
		and not best_hit.is_empty()
	):
		var debug_collider: Variant = best_hit.get(
			"collider"
		)

		print(
			"[BrunoWave] obstacle hit: ",
			debug_collider
		)

	return best_hit


func _handle_obstacle_hit(
	hit: Dictionary
) -> bool:
	var hit_position_value: Variant = hit.get(
		"position"
	)

	if not hit_position_value is Vector3:
		return false

	var hit_position := (
		hit_position_value as Vector3
	)

	var root_position_value: Variant = hit.get(
		"wave_root_position"
	)

	var wave_stop_position: Vector3 = hit_position

	if root_position_value is Vector3:
		wave_stop_position = (
			root_position_value as Vector3
		)

	var rid_value: Variant = hit.get(
		"rid"
	)

	var obstacle_rid := RID()

	if rid_value is RID:
		obstacle_rid = rid_value as RID

	if obstacle_mode == 0:
		global_position = wave_stop_position
		previous_position_world = wave_stop_position
		obstacle_stop_position_world = wave_stop_position
		obstacle_stop_elapsed = 0.0
		stopping_on_obstacle = true

		return true

	# Attenuate mode:
	# each physical collider removes power only once.
	power_multiplier *= (
		1.0
		- clampf(
			obstacle_power_loss,
			0.0,
			1.0
		)
	)

	if obstacle_rid.is_valid():
		ignored_obstacle_rids.append(
			obstacle_rid
		)

	if power_multiplier <= obstacle_min_power:
		global_position = wave_stop_position
		previous_position_world = wave_stop_position
		obstacle_stop_position_world = wave_stop_position
		obstacle_stop_elapsed = 0.0
		stopping_on_obstacle = true

		return true

	_apply_power_to_materials()

	return false


func _process_obstacle_stop(
	delta: float
) -> void:
	obstacle_stop_elapsed += delta
	global_position = obstacle_stop_position_world

	var stop_t: float = clampf(
		obstacle_stop_elapsed
		/ maxf(
			obstacle_stop_fade_time,
			0.02
		),
		0.0,
		1.0
	)

	_set_dissolve(
		stop_t
	)

	if stop_t >= 1.0:
		queue_free()


func _set_dissolve(
	value: float
) -> void:
	if core_material != null:
		core_material.set_shader_parameter(
			"dissolve",
			value
		)

	if shell_material != null:
		shell_material.set_shader_parameter(
			"dissolve",
			value
		)


func _apply_power_to_materials() -> void:
	if core_material != null:
		core_material.set_shader_parameter(
			"emission_boost",
			base_core_emission_boost
			* power_multiplier
		)

	if shell_material != null:
		shell_material.set_shader_parameter(
			"emission_boost",
			base_shell_emission_boost
			* power_multiplier
		)


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
			var effective_damage: int = maxi(
				1,
				roundi(
					float(damage_amount)
					* power_multiplier
				)
			)

			node.take_damage(
				effective_damage
			)

			_play_player_hit_audio(
				target.global_position
			)

			damaged_targets[
				target_id
			] = true


func _start_flight_audio() -> void:
	if flight_sound == null:
		return

	if flight_audio_player == null:
		flight_audio_player = AudioStreamPlayer3D.new()
		flight_audio_player.name = "BrunoWaveFlightAudio"
		flight_audio_player.bus = &"SFX"
		add_child(
			flight_audio_player
		)

	flight_audio_player.stream = flight_sound
	flight_audio_player.volume_db = flight_sound_volume_db
	flight_audio_player.max_distance = wave_audio_max_distance
	flight_audio_player.play()


func _play_player_hit_audio(
	world_position: Vector3
) -> void:
	if player_hit_sound == null:
		return

	var world := get_tree().current_scene

	if world == null:
		return

	var audio_player := AudioStreamPlayer3D.new()
	audio_player.name = "BrunoWavePlayerHitAudio"
	audio_player.stream = player_hit_sound
	audio_player.bus = &"SFX"
	audio_player.volume_db = player_hit_sound_volume_db
	audio_player.max_distance = wave_audio_max_distance

	world.add_child(
		audio_player
	)

	audio_player.global_position = world_position

	audio_player.finished.connect(
		audio_player.queue_free
	)

	audio_player.play()


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

		var core_emission_value: Variant = (
			core_material.get_shader_parameter(
				"emission_boost"
			)
		)

		if core_emission_value is float:
			base_core_emission_boost = float(
				core_emission_value
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

		var shell_emission_value: Variant = (
			shell_material.get_shader_parameter(
				"emission_boost"
			)
		)

		if shell_emission_value is float:
			base_shell_emission_boost = float(
				shell_emission_value
			)
