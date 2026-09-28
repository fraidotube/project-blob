extends Control

const GAME_SCENE := "res://scenes/maps/map_test.tscn"

@onready var main_panel: Control = $MainPanel
@onready var options_panel: Control = $OptionsPanel
@onready var menu_music: AudioStreamPlayer = $MenuMusic
@onready var resolution_option: OptionButton = $OptionsPanel/Panel/Margin/VBox/Resolution
@onready var mode_option: OptionButton = $OptionsPanel/Panel/Margin/VBox/WindowMode
@onready var vsync_check: CheckButton = $OptionsPanel/Panel/Margin/VBox/VSync
@onready var fps_option: OptionButton = $OptionsPanel/Panel/Margin/VBox/FPSLimit
@onready var render_scale_slider: HSlider = $OptionsPanel/Panel/Margin/VBox/RenderScale
@onready var render_scale_value: Label = $OptionsPanel/Panel/Margin/VBox/RenderScaleValue

var settings := GameSettings.new()

var resolutions := [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]

var fps_values := [0, 30, 60, 120, 144, 165, 240]

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	add_child(settings)
	settings.load_settings()
	_build_options()
	_show_main()
	_start_music()

func _start_music() -> void:
	if menu_music.stream == null:
		return
	if menu_music.stream is AudioStreamMP3:
		(menu_music.stream as AudioStreamMP3).loop = true
	menu_music.volume_db = -80.0
	menu_music.play()
	var tween := create_tween()
	tween.tween_property(menu_music, "volume_db", -12.0, 2.5)

func _fade_music_out() -> void:
	if not menu_music.playing:
		return
	var tween := create_tween()
	tween.tween_property(menu_music, "volume_db", -60.0, 0.65)
	await tween.finished

func _build_options() -> void:
	resolution_option.clear()
	for resolution: Vector2i in resolutions:
		resolution_option.add_item("%d x %d" % [resolution.x, resolution.y])
		if resolution == settings.resolution:
			resolution_option.select(resolution_option.item_count - 1)
	mode_option.clear()
	mode_option.add_item("FINESTRA")
	mode_option.add_item("BORDERLESS")
	mode_option.add_item("SCHERMO INTERO")
	match settings.window_mode:
		"WINDOWED": mode_option.select(0)
		"BORDERLESS": mode_option.select(1)
		"FULLSCREEN": mode_option.select(2)
	vsync_check.button_pressed = settings.vsync_enabled
	fps_option.clear()
	for value: int in fps_values:
		var label := "ILLIMITATI" if value == 0 else str(value)
		fps_option.add_item(label)
		if value == settings.fps_limit:
			fps_option.select(fps_option.item_count - 1)
	render_scale_slider.value = settings.render_scale
	_update_render_scale_label(settings.render_scale)

func _show_main() -> void:
	main_panel.visible = true
	options_panel.visible = false

func _show_options() -> void:
	main_panel.visible = false
	options_panel.visible = true

func _on_new_game_pressed() -> void:
	await _fade_music_out()
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_options_pressed() -> void:
	_show_options()

func _on_quit_pressed() -> void:
	await _fade_music_out()
	get_tree().quit()

func _on_back_pressed() -> void:
	_show_main()

func _on_apply_pressed() -> void:
	settings.resolution = resolutions[resolution_option.selected]
	match mode_option.selected:
		0: settings.window_mode = "WINDOWED"
		1: settings.window_mode = "BORDERLESS"
		2: settings.window_mode = "FULLSCREEN"
	settings.vsync_enabled = vsync_check.button_pressed
	settings.fps_limit = fps_values[fps_option.selected]
	settings.render_scale = float(render_scale_slider.value)
	settings.apply_settings()
	settings.save_settings()

func _on_render_scale_changed(value: float) -> void:
	_update_render_scale_label(value)

func _update_render_scale_label(value: float) -> void:
	render_scale_value.text = "SCALA RENDER 3D: %d%%" % roundi(value * 100.0)
