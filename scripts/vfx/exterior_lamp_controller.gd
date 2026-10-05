extends Node3D

# ============================================================
# EXTERIOR LAMP CONTROLLER
#
# Questo script va assegnato al nodo:
#
# LuceLampione
# ├── LampSpot          -> SpotLight3D principale
# ├── OmniLight3D       -> luce del vetro
# ├── LampGlow          -> mesh emissiva del vetro
# └── SparksElectric    -> GPUParticles3D (opzionale finché non lo aggiungi)
#
# Prima del boss:
#   flicker normale.
#
# Dopo set_broken():
#   lampione permanentemente rotto,
#   normalmente spento,
#   hum continuo,
#   burst casuali di scintille + suono + flash.
# ============================================================


@export_group("Normal Flicker")
@export var flicker_enabled: bool = true

@export_range(0.0, 1.0, 0.01)
var min_energy_ratio: float = 0.15

@export_range(0.0, 1.5, 0.01)
var max_energy_ratio: float = 1.08

@export_range(0.01, 2.0, 0.01)
var flicker_step_min: float = 0.03

@export_range(0.01, 2.0, 0.01)
var flicker_step_max: float = 0.12

@export_range(0.05, 10.0, 0.05)
var stable_time_min: float = 0.35

@export_range(0.05, 10.0, 0.05)
var stable_time_max: float = 2.20

@export_range(1, 12, 1)
var burst_steps_min: int = 2

@export_range(1, 12, 1)
var burst_steps_max: int = 6

@export_range(0.0, 1.0, 0.01)
var blackout_chance: float = 0.12

@export_range(0.01, 2.0, 0.01)
var blackout_time_min: float = 0.05

@export_range(0.01, 2.0, 0.01)
var blackout_time_max: float = 0.22


@export_group("Glow Mesh")
@export_range(0.0, 10.0, 0.1)
var glow_energy_on: float = 2.0

@export_range(0.0, 10.0, 0.1)
var glow_energy_off: float = 0.0


@export_group("Broken Lamp")
@export var broken_hum_stream: AudioStream
@export var spark_stream: AudioStream

@export_range(0.2, 60.0, 0.1)
var broken_interval_min: float = 3.0

@export_range(0.2, 60.0, 0.1)
var broken_interval_max: float = 8.0

@export_range(0.01, 1.0, 0.01)
var broken_flash_time: float = 0.08

@export_range(0.1, 3.0, 0.05)
var broken_flash_energy_ratio: float = 1.0

@export_range(-40.0, 12.0, 0.5)
var broken_hum_volume_db: float = -8.0

@export_range(-40.0, 12.0, 0.5)
var spark_volume_db: float = 0.0

@export_range(1.0, 100.0, 0.5)
var audio_max_distance: float = 20.0


@export_group("Debug")
@export var start_broken_for_test: bool = false
@export var debug_logs: bool = true


var _rng := RandomNumberGenerator.new()

var _main_light: SpotLight3D = null
var _glow_light: OmniLight3D = null
var _glow_mesh: GeometryInstance3D = null
var _sparks: GPUParticles3D = null

var _main_base_energy: float = 0.0
var _glow_base_energy: float = 0.0

var _glow_material: StandardMaterial3D = null

var _normal_flicker_running: bool = false
var _broken_loop_running: bool = false
var _broken: bool = false

var _hum_player: AudioStreamPlayer3D = null
var _spark_player: AudioStreamPlayer3D = null


func _ready() -> void:
	_rng.randomize()

	if not _resolve_required_nodes():
		set_process(false)
		return

	_capture_base_values()
	_prepare_glow_material()
	_resolve_optional_sparks()
	_prepare_audio()

	if _sparks != null:
		_sparks.emitting = false

	if debug_logs:
		print(
			"[EXTERIOR LAMP] READY | ",
			get_path(),
			" | main_energy=",
			_main_base_energy,
			" | glow_energy=",
			_glow_base_energy,
			" | sparks=",
			_sparks != null
		)

	if start_broken_for_test:
		set_broken()
		return

	if flicker_enabled:
		_normal_flicker_running = true
		_normal_flicker_loop()
	else:
		_set_light_ratio(1.0)


# ============================================================
# PUBLIC API
# ============================================================

func set_broken() -> void:
	if _broken:
		return

	_broken = true
	flicker_enabled = false
	_normal_flicker_running = false

	_set_light_ratio(0.0)
	_start_hum()

	if not _broken_loop_running:
		_broken_loop_running = true
		_broken_loop()

	if debug_logs:
		print(
			"[EXTERIOR LAMP] BROKEN -> ",
			get_path()
		)


func is_broken() -> bool:
	return _broken


func set_normal_flicker_enabled(value: bool) -> void:
	if _broken:
		return

	flicker_enabled = value

	if value:
		if not _normal_flicker_running:
			_normal_flicker_running = true
			_normal_flicker_loop()
	else:
		_normal_flicker_running = false
		_set_light_ratio(1.0)


# ============================================================
# NORMAL MODE
# ============================================================

func _normal_flicker_loop() -> void:
	while (
		is_inside_tree()
		and _normal_flicker_running
		and flicker_enabled
		and not _broken
	):
		_set_light_ratio(1.0)

		await get_tree().create_timer(
			_rng.randf_range(
				minf(stable_time_min, stable_time_max),
				maxf(stable_time_min, stable_time_max)
			)
		).timeout

		if (
			not is_inside_tree()
			or not _normal_flicker_running
			or not flicker_enabled
			or _broken
		):
			break

		if _rng.randf() < blackout_chance:
			_set_light_ratio(0.0)

			await get_tree().create_timer(
				_rng.randf_range(
					minf(blackout_time_min, blackout_time_max),
					maxf(blackout_time_min, blackout_time_max)
				)
			).timeout

			if (
				not is_inside_tree()
				or not _normal_flicker_running
				or not flicker_enabled
				or _broken
			):
				break

		var steps := _rng.randi_range(
			mini(burst_steps_min, burst_steps_max),
			maxi(burst_steps_min, burst_steps_max)
		)

		for _i: int in range(steps):
			if (
				not is_inside_tree()
				or not _normal_flicker_running
				or not flicker_enabled
				or _broken
			):
				break

			var ratio := _rng.randf_range(
				minf(min_energy_ratio, max_energy_ratio),
				maxf(min_energy_ratio, max_energy_ratio)
			)

			_set_light_ratio(ratio)

			await get_tree().create_timer(
				_rng.randf_range(
					minf(flicker_step_min, flicker_step_max),
					maxf(flicker_step_min, flicker_step_max)
				)
			).timeout

	if _broken:
		_set_light_ratio(0.0)
	else:
		_set_light_ratio(1.0)

	_normal_flicker_running = false


# ============================================================
# BROKEN MODE
# ============================================================

func _broken_loop() -> void:
	while is_inside_tree() and _broken:
		var wait_time := _rng.randf_range(
			minf(broken_interval_min, broken_interval_max),
			maxf(broken_interval_min, broken_interval_max)
		)

		if debug_logs:
			print(
				"[EXTERIOR LAMP] prossimo burst tra ",
				"%.2f" % wait_time,
				" s | ",
				get_path()
			)

		await get_tree().create_timer(wait_time).timeout

		if not is_inside_tree() or not _broken:
			break

		await _play_broken_burst()

	_broken_loop_running = false


func _play_broken_burst() -> void:
	if debug_logs:
		print(
			"[EXTERIOR LAMP] SPARK BURST -> ",
			get_path()
		)

	if _sparks != null:
		_sparks.restart()
		_sparks.emitting = true

	if (
		_spark_player != null
		and spark_stream != null
	):
		_spark_player.stop()
		_spark_player.play()

	_set_light_ratio(
		maxf(broken_flash_energy_ratio, 0.0)
	)

	await get_tree().create_timer(
		maxf(broken_flash_time, 0.01)
	).timeout

	if _broken:
		_set_light_ratio(0.0)


# ============================================================
# LIGHT + GLOW CONTROL
# ============================================================

func _set_light_ratio(ratio: float) -> void:
	var safe_ratio := maxf(ratio, 0.0)

	_main_light.light_energy = (
		_main_base_energy
		* safe_ratio
	)

	_glow_light.light_energy = (
		_glow_base_energy
		* safe_ratio
	)

	if _glow_material != null:
		_glow_material.emission_energy_multiplier = lerpf(
			glow_energy_off,
			glow_energy_on,
			clampf(safe_ratio, 0.0, 1.0)
		)


func _capture_base_values() -> void:
	_main_base_energy = _main_light.light_energy
	_glow_base_energy = _glow_light.light_energy


func _prepare_glow_material() -> void:
	var material: Material = _glow_mesh.material_override

	if (
		material == null
		and _glow_mesh is MeshInstance3D
	):
		var mesh_instance := _glow_mesh as MeshInstance3D

		if mesh_instance.mesh != null:
			material = mesh_instance.get_active_material(0)

	var standard := material as StandardMaterial3D

	if standard == null:
		push_warning(
			"[EXTERIOR LAMP] LampGlow non usa StandardMaterial3D: "
			+ "le luci funzioneranno, ma l'emissione della mesh non verrà variata."
		)
		return

	_glow_material = standard.duplicate() as StandardMaterial3D
	_glow_material.resource_local_to_scene = true
	_glow_mesh.material_override = _glow_material


# ============================================================
# AUDIO
# ============================================================

func _prepare_audio() -> void:
	_hum_player = AudioStreamPlayer3D.new()
	_hum_player.name = "BrokenHumAudio"
	_hum_player.volume_db = broken_hum_volume_db
	_hum_player.max_distance = audio_max_distance
	add_child(_hum_player)

	_spark_player = AudioStreamPlayer3D.new()
	_spark_player.name = "BrokenSparkAudio"
	_spark_player.volume_db = spark_volume_db
	_spark_player.max_distance = audio_max_distance
	add_child(_spark_player)

	if broken_hum_stream != null:
		_hum_player.stream = broken_hum_stream

	if spark_stream != null:
		_spark_player.stream = spark_stream

	_hum_player.finished.connect(
		_on_hum_finished
	)


func _start_hum() -> void:
	if broken_hum_stream == null:
		if debug_logs:
			push_warning(
				"[EXTERIOR LAMP] Broken Hum Stream non assegnato."
			)
		return

	_hum_player.stream = broken_hum_stream
	_hum_player.volume_db = broken_hum_volume_db

	if not _hum_player.playing:
		_hum_player.play()


func _on_hum_finished() -> void:
	if not _broken:
		return

	_hum_player.play()


# ============================================================
# NODE RESOLUTION
# ============================================================

func _resolve_required_nodes() -> bool:
	_main_light = get_node_or_null(
		"LampSpot"
	) as SpotLight3D

	_glow_light = get_node_or_null(
		"OmniLight3D"
	) as OmniLight3D

	_glow_mesh = get_node_or_null(
		"LampGlow"
	) as GeometryInstance3D

	var valid := true

	if _main_light == null:
		push_error(
			"[EXTERIOR LAMP] Figlio LampSpot non trovato sotto "
			+ str(get_path())
		)
		valid = false

	if _glow_light == null:
		push_error(
			"[EXTERIOR LAMP] Figlio OmniLight3D non trovato sotto "
			+ str(get_path())
		)
		valid = false

	if _glow_mesh == null:
		push_error(
			"[EXTERIOR LAMP] Figlio LampGlow non trovato sotto "
			+ str(get_path())
		)
		valid = false

	return valid


func _resolve_optional_sparks() -> void:
	_sparks = get_node_or_null(
		"SparksElectric"
	) as GPUParticles3D

	if _sparks == null and debug_logs:
		push_warning(
			"[EXTERIOR LAMP] SparksElectric non trovato sotto "
			+ str(get_path())
			+ " - flicker/luci/audio continuano comunque."
		)
