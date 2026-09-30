extends Light3D

@export_group("Flicker")
@export var flicker_enabled: bool = true
@export_range(0.1, 20.0, 0.1) var base_energy: float = 1.8
@export_range(0.0, 1.0, 0.01) var min_energy_ratio: float = 0.15
@export_range(0.0, 1.5, 0.01) var max_energy_ratio: float = 1.08

@export_group("Timing")
@export_range(0.01, 2.0, 0.01) var flicker_step_min: float = 0.03
@export_range(0.01, 2.0, 0.01) var flicker_step_max: float = 0.12
@export_range(0.05, 10.0, 0.05) var stable_time_min: float = 0.35
@export_range(0.05, 10.0, 0.05) var stable_time_max: float = 2.2
@export_range(1, 12, 1) var burst_steps_min: int = 2
@export_range(1, 12, 1) var burst_steps_max: int = 6

@export_group("Blackout")
@export_range(0.0, 1.0, 0.01) var blackout_chance: float = 0.12
@export_range(0.01, 2.0, 0.01) var blackout_time_min: float = 0.05
@export_range(0.01, 2.0, 0.01) var blackout_time_max: float = 0.22

@export_group("Optional Glow Mesh")
@export var glow_mesh: GeometryInstance3D
@export_range(0.0, 10.0, 0.1) var glow_energy_on: float = 2.0
@export_range(0.0, 10.0, 0.1) var glow_energy_off: float = 0.0

var _rng := RandomNumberGenerator.new()
var _running := false
var _glow_material: StandardMaterial3D


func _ready() -> void:
	_rng.randomize()

	if base_energy <= 0.0:
		base_energy = light_energy

	light_energy = base_energy
	_prepare_glow_material()

	if flicker_enabled:
		_running = true
		_flicker_loop()


func set_flicker_enabled(value: bool) -> void:
	flicker_enabled = value

	if not is_inside_tree():
		return

	if flicker_enabled:
		if not _running:
			_running = true
			_flicker_loop()
	else:
		_running = false
		_set_energy_ratio(1.0)


func _flicker_loop() -> void:
	while _running and flicker_enabled:
		_set_energy_ratio(1.0)

		await get_tree().create_timer(
			_rng.randf_range(
				minf(stable_time_min, stable_time_max),
				maxf(stable_time_min, stable_time_max)
			)
		).timeout

		if not _running or not flicker_enabled:
			break

		if _rng.randf() < blackout_chance:
			_set_energy_ratio(0.0)

			await get_tree().create_timer(
				_rng.randf_range(
					minf(blackout_time_min, blackout_time_max),
					maxf(blackout_time_min, blackout_time_max)
				)
			).timeout

			if not _running or not flicker_enabled:
				break

		var steps := _rng.randi_range(
			mini(burst_steps_min, burst_steps_max),
			maxi(burst_steps_min, burst_steps_max)
		)

		for i: int in range(steps):
			if not _running or not flicker_enabled:
				break

			var ratio := _rng.randf_range(
				minf(min_energy_ratio, max_energy_ratio),
				maxf(min_energy_ratio, max_energy_ratio)
			)

			_set_energy_ratio(ratio)

			await get_tree().create_timer(
				_rng.randf_range(
					minf(flicker_step_min, flicker_step_max),
					maxf(flicker_step_min, flicker_step_max)
				)
			).timeout

	_set_energy_ratio(1.0)


func _set_energy_ratio(ratio: float) -> void:
	var clamped_ratio := maxf(ratio, 0.0)

	light_energy = base_energy * clamped_ratio

	if _glow_material != null:
		_glow_material.emission_energy_multiplier = lerpf(
			glow_energy_off,
			glow_energy_on,
			clampf(clamped_ratio, 0.0, 1.0)
		)


func _prepare_glow_material() -> void:
	if glow_mesh == null:
		return

	var material := glow_mesh.material_override

	if material == null and glow_mesh.mesh != null:
		material = glow_mesh.get_active_material(0)

	var standard := material as StandardMaterial3D

	if standard == null:
		return

	# Duplichiamo il materiale così il flicker di questo lampione
	# non modifica tutte le altre istanze che condividono la risorsa.
	_glow_material = standard.duplicate() as StandardMaterial3D
	_glow_material.resource_local_to_scene = true
	glow_mesh.material_override = _glow_material
