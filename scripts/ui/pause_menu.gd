extends CanvasLayer

const MAIN_MENU_SCENE := "res://scenes/ui/main_menu.tscn"

@onready var pause_root: Control = $PauseRoot
@onready var options_panel: Control = $PauseRoot/OptionsPanel
@onready var resolution_option: OptionButton = $PauseRoot/OptionsPanel/Panel/VBox/Resolution
@onready var mode_option: OptionButton = $PauseRoot/OptionsPanel/Panel/VBox/WindowMode
@onready var vsync_check: CheckButton = $PauseRoot/OptionsPanel/Panel/VBox/VSync
@onready var fps_option: OptionButton = $PauseRoot/OptionsPanel/Panel/VBox/FPSLimit
@onready var render_scale_slider: HSlider = $PauseRoot/OptionsPanel/Panel/VBox/RenderScale
@onready var render_scale_value: Label = $PauseRoot/OptionsPanel/Panel/VBox/RenderScaleValue

var settings := GameSettings.new()
var is_open := false
var resolutions := [Vector2i(1280,720), Vector2i(1600,900), Vector2i(1920,1080), Vector2i(2560,1440), Vector2i(3840,2160)]
var fps_values := [0,30,60,120,144,165,240]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(settings)
	settings.load_settings()
	_build_options()
	pause_root.visible = false
	options_panel.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if options_panel.visible:
			options_panel.visible = false
			get_viewport().set_input_as_handled()
			return
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	is_open = not is_open
	get_tree().paused = is_open
	pause_root.visible = is_open
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if is_open else Input.MOUSE_MODE_CAPTURED

func _on_resume_pressed() -> void:
	if is_open:
		toggle_pause()

func _on_options_pressed() -> void:
	options_panel.visible = true

func _on_options_back_pressed() -> void:
	options_panel.visible = false

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _build_options() -> void:
	resolution_option.clear()
	for r: Vector2i in resolutions:
		resolution_option.add_item("%d x %d" % [r.x, r.y])
		if r == settings.resolution:
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
		fps_option.add_item("ILLIMITATI" if value == 0 else str(value))
		if value == settings.fps_limit:
			fps_option.select(fps_option.item_count - 1)
	render_scale_slider.value = settings.render_scale
	_update_render_scale_label(settings.render_scale)

func _on_apply_pressed() -> void:
	settings.resolution = resolutions[resolution_option.selected]
	settings.window_mode = ["WINDOWED", "BORDERLESS", "FULLSCREEN"][mode_option.selected]
	settings.vsync_enabled = vsync_check.button_pressed
	settings.fps_limit = fps_values[fps_option.selected]
	settings.render_scale = float(render_scale_slider.value)
	settings.apply_settings()
	settings.save_settings()

func _on_render_scale_changed(value: float) -> void:
	_update_render_scale_label(value)

func _update_render_scale_label(value: float) -> void:
	render_scale_value.text = "SCALA RENDER 3D: %d%%" % roundi(value * 100.0)
