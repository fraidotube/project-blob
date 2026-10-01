extends Control

const GAME_SCENE := "res://scenes/maps/map_test.tscn"

@onready var main_panel: Control = $MainPanel
@onready var options_panel: Control = $OptionsPanel

@onready var resolution_option: OptionButton = (
	$OptionsPanel/Panel/Margin/Tabs/VIDEO/VideoVBox/Resolution
)
@onready var mode_option: OptionButton = (
	$OptionsPanel/Panel/Margin/Tabs/VIDEO/VideoVBox/WindowMode
)
@onready var vsync_check: CheckButton = (
	$OptionsPanel/Panel/Margin/Tabs/VIDEO/VideoVBox/VSync
)
@onready var fps_option: OptionButton = (
	$OptionsPanel/Panel/Margin/Tabs/VIDEO/VideoVBox/FPSLimit
)
@onready var render_scale_slider: HSlider = (
	$OptionsPanel/Panel/Margin/Tabs/VIDEO/VideoVBox/RenderScale
)
@onready var render_scale_value: Label = (
	$OptionsPanel/Panel/Margin/Tabs/VIDEO/VideoVBox/RenderScaleValue
)
@onready var msaa_option: OptionButton = (
	$OptionsPanel/Panel/Margin/Tabs/VIDEO/VideoVBox/MSAA
)
@onready var fxaa_check: CheckButton = (
	$OptionsPanel/Panel/Margin/Tabs/VIDEO/VideoVBox/FXAA
)
@onready var taa_check: CheckButton = (
	$OptionsPanel/Panel/Margin/Tabs/VIDEO/VideoVBox/TAA
)

@onready var master_slider: HSlider = (
	$OptionsPanel/Panel/Margin/Tabs/AUDIO/AudioVBox/Master
)
@onready var music_slider: HSlider = (
	$OptionsPanel/Panel/Margin/Tabs/AUDIO/AudioVBox/Music
)
@onready var sfx_slider: HSlider = (
	$OptionsPanel/Panel/Margin/Tabs/AUDIO/AudioVBox/SFX
)
@onready var ui_slider: HSlider = (
	$OptionsPanel/Panel/Margin/Tabs/AUDIO/AudioVBox/UI
)

@onready var master_value: Label = (
	$OptionsPanel/Panel/Margin/Tabs/AUDIO/AudioVBox/MasterValue
)
@onready var music_value: Label = (
	$OptionsPanel/Panel/Margin/Tabs/AUDIO/AudioVBox/MusicValue
)
@onready var sfx_value: Label = (
	$OptionsPanel/Panel/Margin/Tabs/AUDIO/AudioVBox/SFXValue
)
@onready var ui_value: Label = (
	$OptionsPanel/Panel/Margin/Tabs/AUDIO/AudioVBox/UIValue
)

@onready var sensitivity_slider: HSlider = (
	$OptionsPanel/Panel/Margin/Tabs/CONTROLLI/ControlsVBox/MouseSensitivity
)
@onready var sensitivity_value: Label = (
	$OptionsPanel/Panel/Margin/Tabs/CONTROLLI/ControlsVBox/MouseSensitivityValue
)
@onready var controls_vbox: VBoxContainer = (
	$OptionsPanel/Panel/Margin/Tabs/CONTROLLI/ControlsVBox
)

var fov_slider: HSlider
var fov_value: Label

var resolutions := [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160)
]

var fps_values := [
	0,
	30,
	60,
	120,
	144,
	165,
	240
]


func _settings() -> Node:
	return get_node("/root/SettingsManager")


func _audio_manager() -> Node:
	return get_node_or_null("/root/AudioManager")


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	_create_fov_control()
	_build_options()
	_show_main()

	var audio_manager := _audio_manager()

	if (
		audio_manager != null
		and audio_manager.has_method(
			"ensure_menu_music"
		)
	):
		audio_manager.call(
			"ensure_menu_music"
		)


func _create_fov_control() -> void:
	fov_value = Label.new()
	fov_value.name = "FOVValue"
	controls_vbox.add_child(fov_value)

	fov_slider = HSlider.new()
	fov_slider.name = "FOV"
	fov_slider.min_value = 60.0
	fov_slider.max_value = 100.0
	fov_slider.step = 1.0
	controls_vbox.add_child(fov_slider)

	fov_slider.value_changed.connect(
		_on_fov_changed
	)


func _build_options() -> void:
	var settings := _settings()

	resolution_option.clear()

	for resolution: Vector2i in resolutions:
		resolution_option.add_item(
			"%d x %d"
			% [
				resolution.x,
				resolution.y
			]
		)

		if resolution == settings.resolution:
			resolution_option.select(
				resolution_option.item_count - 1
			)

	mode_option.clear()
	mode_option.add_item("FINESTRA")
	mode_option.add_item("BORDERLESS")
	mode_option.add_item("SCHERMO INTERO")

	match settings.window_mode:
		"WINDOWED":
			mode_option.select(0)
		"BORDERLESS":
			mode_option.select(1)
		"FULLSCREEN":
			mode_option.select(2)

	vsync_check.button_pressed = (
		settings.vsync_enabled
	)

	fps_option.clear()

	for value: int in fps_values:
		fps_option.add_item(
			"ILLIMITATI"
			if value == 0
			else str(value)
		)

		if value == settings.fps_limit:
			fps_option.select(
				fps_option.item_count - 1
			)

	render_scale_slider.set_value_no_signal(settings.render_scale)

	_update_render_scale_label(
		settings.render_scale
	)

	msaa_option.clear()
	msaa_option.add_item("DISATTIVATO")
	msaa_option.add_item("2x")
	msaa_option.add_item("4x")
	msaa_option.add_item("8x")
	msaa_option.select(
		clampi(
			settings.msaa_mode,
			0,
			3
		)
	)

	fxaa_check.button_pressed = settings.fxaa_enabled
	taa_check.button_pressed = settings.taa_enabled

	master_slider.set_value_no_signal(settings.master_volume)
	music_slider.set_value_no_signal(settings.music_volume)
	sfx_slider.set_value_no_signal(settings.sfx_volume)
	ui_slider.set_value_no_signal(settings.ui_volume)

	sensitivity_slider.set_value_no_signal(settings.mouse_sensitivity)

	fov_slider.set_value_no_signal(settings.camera_fov)

	_update_audio_labels()
	_update_sensitivity_label(
		settings.mouse_sensitivity
	)
	_update_fov_label(
		settings.camera_fov
	)


func _show_main() -> void:
	main_panel.visible = true
	options_panel.visible = false


func _show_options() -> void:
	_build_options()
	main_panel.visible = false
	options_panel.visible = true


func _on_new_game_pressed() -> void:
	var audio_manager := _audio_manager()

	if (
		audio_manager != null
		and audio_manager.has_method(
			"fade_out_menu_music"
		)
	):
		await audio_manager.call(
			"fade_out_menu_music"
		)

	var transition := get_node_or_null(
		"/root/SceneTransition"
	)

	if transition != null:
		await transition.call(
			"transition_to",
			GAME_SCENE,
			true
		)
		return

	get_tree().change_scene_to_file(
		GAME_SCENE
	)


func _on_options_pressed() -> void:
	_show_options()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	_build_options()
	_show_main()


func _on_apply_pressed() -> void:
	var settings := _settings()

	settings.resolution = resolutions[
		resolution_option.selected
	]

	settings.window_mode = [
		"WINDOWED",
		"BORDERLESS",
		"FULLSCREEN"
	][mode_option.selected]

	settings.vsync_enabled = (
		vsync_check.button_pressed
	)

	settings.fps_limit = fps_values[
		fps_option.selected
	]

	settings.render_scale = float(
		render_scale_slider.value
	)

	settings.msaa_mode = msaa_option.selected
	settings.fxaa_enabled = (
		fxaa_check.button_pressed
	)
	settings.taa_enabled = (
		taa_check.button_pressed
	)

	settings.master_volume = float(
		master_slider.value
	)
	settings.music_volume = float(
		music_slider.value
	)
	settings.sfx_volume = float(
		sfx_slider.value
	)
	settings.ui_volume = float(
		ui_slider.value
	)

	settings.mouse_sensitivity = float(
		sensitivity_slider.value
	)

	settings.camera_fov = float(
		fov_slider.value
	)

	settings.save_settings()
	settings.apply_settings()


func _on_render_scale_changed(
	value: float
) -> void:
	_update_render_scale_label(value)


func _update_render_scale_label(
	value: float
) -> void:
	render_scale_value.text = (
		"SCALA RENDER 3D: %d%%"
		% roundi(value * 100.0)
	)


func _on_audio_changed(
	_value: float
) -> void:
	var settings := _settings()

	settings.master_volume = float(
		master_slider.value
	)
	settings.music_volume = float(
		music_slider.value
	)
	settings.sfx_volume = float(
		sfx_slider.value
	)
	settings.ui_volume = float(
		ui_slider.value
	)

	# L'audio viene salvato SUBITO.
	# Non può più tornare al 75% durante un cambio scena.
	settings.save_audio_now()

	_update_audio_labels()


func _update_audio_labels() -> void:
	master_value.text = (
		"MASTER: %d%%"
		% roundi(
			master_slider.value * 100.0
		)
	)
	music_value.text = (
		"MUSICA: %d%%"
		% roundi(
			music_slider.value * 100.0
		)
	)
	sfx_value.text = (
		"EFFETTI: %d%%"
		% roundi(
			sfx_slider.value * 100.0
		)
	)
	ui_value.text = (
		"INTERFACCIA: %d%%"
		% roundi(
			ui_slider.value * 100.0
		)
	)


func _on_sensitivity_changed(
	value: float
) -> void:
	_update_sensitivity_label(value)


func _update_sensitivity_label(
	value: float
) -> void:
	sensitivity_value.text = (
		"SENSIBILITÀ MOUSE: %d%%"
		% roundi(value * 100.0)
	)


func _on_fov_changed(
	value: float
) -> void:
	_update_fov_label(value)


func _update_fov_label(
	value: float
) -> void:
	fov_value.text = (
		"FOV CAMERA: %d°"
		% roundi(value)
	)
