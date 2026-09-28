extends Node
class_name GameSettings

const SETTINGS_PATH := "user://settings.cfg"

var resolution := Vector2i(1920, 1080)
var window_mode := "BORDERLESS"
var vsync_enabled := true
var fps_limit := 0
var render_scale := 1.0

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		resolution = config.get_value("video", "resolution", resolution)
		window_mode = config.get_value("video", "window_mode", window_mode)
		vsync_enabled = config.get_value("video", "vsync", vsync_enabled)
		fps_limit = int(config.get_value("video", "fps_limit", fps_limit))
		render_scale = float(config.get_value("video", "render_scale", render_scale))
	apply_settings()

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("video", "resolution", resolution)
	config.set_value("video", "window_mode", window_mode)
	config.set_value("video", "vsync", vsync_enabled)
	config.set_value("video", "fps_limit", fps_limit)
	config.set_value("video", "render_scale", render_scale)
	config.save(SETTINGS_PATH)

func apply_settings() -> void:
	match window_mode:
		"FULLSCREEN":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		"BORDERLESS":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_size(resolution)

	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSYNC_DISABLED
	)
	Engine.max_fps = fps_limit
	get_tree().root.scaling_3d_scale = clampf(render_scale, 0.5, 1.5)
