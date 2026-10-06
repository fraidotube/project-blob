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

@export_group("Broken Lamp")
@export var sparks: GPUParticles3D
@export var broken_hum_stream: AudioStream
@export var spark_stream: AudioStream

@export_range(0.2, 60.0, 0.1) var broken_interval_min: float = 3.0
@export_range(0.2, 60.0, 0.1) var broken_interval_max: float = 8.0

@export_range(0.01, 1.0, 0.01) var broken_flash_time: float = 0.08
@export_range(0.1, 3.0, 0.05) var broken_flash_energy_ratio: float = 1.0

@export_range(-40.0, 12.0, 0.5) var broken_hum_volume_db: float = -8.0
@export_range(-40.0, 12.0, 0.5) var spark_volume_db: float = 0.0

@export_range(1.0, 100.0, 0.5) var audio_max_distance: float = 20.0

@export_group("Broken Debug")
@export var start_broken_for_test: bool = false
@export var debug_broken_logs: bool = true

var _rng := RandomNumberGenerator.new()
var _running := false
var _glow_material: StandardMaterial3D

var _broken: bool = false
var _broken_loop_running: bool = false

var _hum_player: AudioStreamPlayer3D
var _spark_player: AudioStreamPlayer3D


func _ready() -> void:
	_rng.randomize()

	if base_energy <= 0.0:
		base_energy = light_energy

	light_energy = base_energy

	_prepare_glow_material()
	_prepare_broken_audio()

	if sparks != null:
		sparks.emitting = false

	if start_broken_for_test:
		set_broken()
		return

	if flicker_enabled:
		_running = true
		_flicker_loop()


func set_flicker_enabled(value: bool) -> void:
	if _broken:
		return

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


func set_broken() -> void:
	if _broken:
		return

	_broken = true

	# Ferma definitivamente il normale flicker.
	flicker_enabled = false
	_running = false

	# Il lampione rotto normalmente resta spento.
	_set_energy_ratio(0.0)

	_start_hum()

	if not _broken_loop_running:
		_broken_loop_running = true
		_broken_loop()

	if debug_broken_logs:
		print(
			"[LAMP BROKEN] ",
			get_path(),
			" -> broken mode attivo"
		)


func is_broken() -> bool:
	return _broken


func _flicker_loop() -> void:
	while _running and flicker_enabled and not _broken:
		_set_energy_ratio(1.0)

		await get_tree().create_timer(
			_rng.randf_range(
				minf(stable_time_min, stable_time_max),
				maxf(stable_time_min, stable_time_max)
			)
		).timeout

		if not _running or not flicker_enabled or _broken:
			break

		if _rng.randf() < blackout_chance:
			_set_energy_ratio(0.0)

			await get_tree().create_timer(
				_rng.randf_range(
					minf(blackout_time_min, blackout_time_max),
					maxf(blackout_time_min, blackout_time_max)
				)
			).timeout

			if not _running or not flicker_enabled or _broken:
				break

		var steps := _rng.randi_range(
			mini(burst_steps_min, burst_steps_max),
			maxi(burst_steps_min, burst_steps_max)
		)

		for _i: int in range(steps):
			if not _running or not flicker_enabled or _broken:
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

	# Se è diventato rotto, NON riaccendere la luce.
	if _broken:
		_set_energy_ratio(0.0)
	else:
		_set_energy_ratio(1.0)


func _broken_loop() -> void:
	while _broken and is_inside_tree():
		var wait_time := _rng.randf_range(
			minf(broken_interval_min, broken_interval_max),
			maxf(broken_interval_min, broken_interval_max)
		)

		await get_tree().create_timer(wait_time).timeout

		if not _broken or not is_inside_tree():
			break

		await _play_broken_burst()

	_broken_loop_running = false


func _play_broken_burst() -> void:
	if debug_broken_logs:
		print(
			"[LAMP BROKEN] spark burst -> ",
			get_path()
		)

	# Scintille.
	if sparks != null:
		sparks.restart()
		sparks.emitting = true

	# Suono scintilla sovrapposto all'hum.
	if _spark_player != null and spark_stream != null:
		_spark_player.stop()
		_spark_player.play()

	# Flash della lampada nello stesso istante del burst.
	_set_energy_ratio(
		maxf(broken_flash_energy_ratio, 0.0)
	)

	await get_tree().create_timer(
		maxf(broken_flash_time, 0.01)
	).timeout

	# Il lampione rotto torna subito spento.
	if _broken:
		_set_energy_ratio(0.0)


func _prepare_broken_audio() -> void:
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

	# Loop dell'hum gestito dallo script, così non dipendiamo
	# dal formato WAV/MP3 o dai flag interni della risorsa.
	_hum_player.finished.connect(
		_on_hum_finished
	)


func _start_hum() -> void:
	if _hum_player == null:
		return

	if broken_hum_stream == null:
		return

	_hum_player.stream = broken_hum_stream
	_hum_player.volume_db = broken_hum_volume_db

	if not _hum_player.playing:
		_hum_player.play()


func _on_hum_finished() -> void:
	if not _broken:
		return

	if _hum_player == null:
		return

	_hum_player.play()


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
