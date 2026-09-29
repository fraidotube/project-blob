extends Node

const SETTINGS_PATH := "user://settings.cfg"

var resolution := Vector2i(1920, 1080)
var window_mode := "BORDERLESS"
var vsync_enabled := true
var fps_limit := 0
var render_scale := 1.0

var msaa_mode := 0
var fxaa_enabled := true
var taa_enabled := false

var master_volume := 0.75
var music_volume := 0.75
var sfx_volume := 0.75
var ui_volume := 0.75

var mouse_sensitivity := 1.0
var camera_fov := 75.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_settings()
	apply_settings()


func load_settings() -> void:
	var config := ConfigFile.new()

	if config.load(SETTINGS_PATH) != OK:
		return

	resolution = config.get_value(
		"video", "resolution", resolution
	)
	window_mode = config.get_value(
		"video", "window_mode", window_mode
	)
	vsync_enabled = bool(
		config.get_value(
			"video", "vsync", vsync_enabled
		)
	)
	fps_limit = int(
		config.get_value(
			"video", "fps_limit", fps_limit
		)
	)
	render_scale = float(
		config.get_value(
			"video", "render_scale", render_scale
		)
	)
	msaa_mode = int(
		config.get_value(
			"video", "msaa", msaa_mode
		)
	)
	fxaa_enabled = bool(
		config.get_value(
			"video", "fxaa", fxaa_enabled
		)
	)
	taa_enabled = bool(
		config.get_value(
			"video", "taa", taa_enabled
		)
	)

	master_volume = float(
		config.get_value(
			"audio", "master", master_volume
		)
	)
	music_volume = float(
		config.get_value(
			"audio", "music", music_volume
		)
	)
	sfx_volume = float(
		config.get_value(
			"audio", "sfx", sfx_volume
		)
	)
	ui_volume = float(
		config.get_value(
			"audio", "ui", ui_volume
		)
	)

	mouse_sensitivity = float(
		config.get_value(
			"controls",
			"mouse_sensitivity",
			mouse_sensitivity
		)
	)
	camera_fov = float(
		config.get_value(
			"controls",
			"camera_fov",
			camera_fov
		)
	)


func save_settings() -> void:
	var config := ConfigFile.new()

	config.set_value(
		"video", "resolution", resolution
	)
	config.set_value(
		"video", "window_mode", window_mode
	)
	config.set_value(
		"video", "vsync", vsync_enabled
	)
	config.set_value(
		"video", "fps_limit", fps_limit
	)
	config.set_value(
		"video", "render_scale", render_scale
	)
	config.set_value(
		"video", "msaa", msaa_mode
	)
	config.set_value(
		"video", "fxaa", fxaa_enabled
	)
	config.set_value(
		"video", "taa", taa_enabled
	)

	config.set_value(
		"audio", "master", master_volume
	)
	config.set_value(
		"audio", "music", music_volume
	)
	config.set_value(
		"audio", "sfx", sfx_volume
	)
	config.set_value(
		"audio", "ui", ui_volume
	)

	config.set_value(
		"controls",
		"mouse_sensitivity",
		mouse_sensitivity
	)
	config.set_value(
		"controls",
		"camera_fov",
		camera_fov
	)

	var err := config.save(
		SETTINGS_PATH
	)

	if err != OK:
		push_error(
			"SettingsManager: impossibile salvare settings.cfg: "
			+ str(err)
		)


func save_audio_now() -> void:
	# Salvataggio immediato dell'audio:
	# evita che un cambio scena possa ripristinare i default.
	save_settings()
	apply_audio()


func apply_settings() -> void:
	_apply_display()
	_apply_rendering()
	apply_audio()


func apply_audio() -> void:
	_set_bus_volume(
		"Master", master_volume
	)
	_set_bus_volume(
		"Music", music_volume
	)
	_set_bus_volume(
		"SFX", sfx_volume
	)
	_set_bus_volume(
		"UI", ui_volume
	)


func _apply_display() -> void:
	match window_mode:
		"FULLSCREEN":
			DisplayServer.window_set_flag(
				DisplayServer.WINDOW_FLAG_BORDERLESS,
				false
			)
			DisplayServer.window_set_mode(
				DisplayServer.WINDOW_MODE_FULLSCREEN
			)

		"BORDERLESS":
			DisplayServer.window_set_mode(
				DisplayServer.WINDOW_MODE_WINDOWED
			)
			DisplayServer.window_set_flag(
				DisplayServer.WINDOW_FLAG_BORDERLESS,
				true
			)

		_:
			DisplayServer.window_set_mode(
				DisplayServer.WINDOW_MODE_WINDOWED
			)
			DisplayServer.window_set_flag(
				DisplayServer.WINDOW_FLAG_BORDERLESS,
				false
			)
			DisplayServer.window_set_size(
				resolution
			)

	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED
		if vsync_enabled
		else DisplayServer.VSYNC_DISABLED
	)

	Engine.max_fps = fps_limit


func _apply_rendering() -> void:
	var viewport := get_tree().root

	viewport.scaling_3d_scale = clampf(
		render_scale,
		0.5,
		1.5
	)

	match msaa_mode:
		1:
			viewport.msaa_3d = Viewport.MSAA_2X
		2:
			viewport.msaa_3d = Viewport.MSAA_4X
		3:
			viewport.msaa_3d = Viewport.MSAA_8X
		_:
			viewport.msaa_3d = Viewport.MSAA_DISABLED

	viewport.screen_space_aa = (
		Viewport.SCREEN_SPACE_AA_FXAA
		if fxaa_enabled
		else Viewport.SCREEN_SPACE_AA_DISABLED
	)

	viewport.use_taa = taa_enabled


func _set_bus_volume(
	bus_name: String,
	value: float
) -> void:
	var bus_index := AudioServer.get_bus_index(
		bus_name
	)

	if bus_index < 0:
		return

	var slider_value := clampf(
		value,
		0.0,
		1.0
	)

	if slider_value <= 0.001:
		AudioServer.set_bus_mute(
			bus_index,
			true
		)
		return

	AudioServer.set_bus_mute(
		bus_index,
		false
	)

	# Project Blob audio scale:
	#
	#   75% = livello nominale del mix (0 dB)
	#   100% = boost disponibile all'utente
	#     0% = mute
	#
	# Sotto il 75% usiamo una curva lineare in ampiezza:
	# 37.5% equivale circa a -6 dB.
	#
	# Sopra il 75% aggiungiamo headroom:
	# categorie = fino a +6 dB
	# Master    = fino a +3 dB per limitare il rischio di clipping.
	var volume_db := 0.0

	if slider_value <= 0.75:
		var normalized := slider_value / 0.75

		volume_db = linear_to_db(
			maxf(
				normalized,
				0.0001
			)
		)
	else:
		var boost_ratio := (
			(slider_value - 0.75)
			/ 0.25
		)

		var max_boost_db := 6.0

		if bus_name == "Master":
			max_boost_db = 3.0

		volume_db = lerpf(
			0.0,
			max_boost_db,
			boost_ratio
		)

	AudioServer.set_bus_volume_db(
		bus_index,
		volume_db
	)
