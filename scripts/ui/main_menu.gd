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

var settings := GameSettings.new()

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


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	add_child(settings)
	settings.load_settings()

	_build_options()
	_show_main()

	if has_node("/root/AudioManager"):
		AudioManager.ensure_menu_music()


func _build_options() -> void:
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

	render_scale_slider.value = (
		settings.render_scale
	)

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

	fxaa_check.button_pressed = (
		settings.fxaa_enabled
	)

	taa_check.button_pressed = (
		settings.taa_enabled
	)

	master_slider.value = (
		settings.master_volume
	)

	music_slider.value = (
		settings.music_volume
	)

	sfx_slider.value = (
		settings.sfx_volume
	)

	ui_slider.value = (
		settings.ui_volume
	)

	_update_audio_labels()


func _show_main() -> void:
	main_panel.visible = true
	options_panel.visible = false


func _show_options() -> void:
	main_panel.visible = false
	options_panel.visible = true


func _on_new_game_pressed() -> void:
	if has_node("/root/AudioManager"):
		await AudioManager.fade_out_menu_music()

	get_tree().change_scene_to_file(
		GAME_SCENE
	)


func _on_options_pressed() -> void:
	_show_options()


func _on_quit_pressed() -> void:
	if has_node("/root/AudioManager"):
		await AudioManager.fade_out_menu_music()

	get_tree().quit()


func _on_back_pressed() -> void:
	_show_main()


func _on_apply_pressed() -> void:
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

	settings.msaa_mode = (
		msaa_option.selected
	)

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

	settings.apply_settings()
	settings.save_settings()


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
