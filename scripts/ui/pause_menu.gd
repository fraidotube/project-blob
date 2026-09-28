extends CanvasLayer

const MAIN_MENU_SCENE := "res://scenes/ui/main_menu.tscn"

@onready var pause_root: Control = $PauseRoot
@onready var menu_panel: Control = $PauseRoot/MenuPanel
@onready var options_panel: Control = $PauseRoot/OptionsPanel

var is_open := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	pause_root.visible = false
	menu_panel.visible = true
	options_panel.visible = false


func _unhandled_input(
	event: InputEvent
) -> void:
	if not event.is_action_pressed(
		"ui_cancel"
	):
		return

	if is_open and options_panel.visible:
		options_panel.visible = false
		menu_panel.visible = true
		get_viewport().set_input_as_handled()
		return

	toggle_pause()
	get_viewport().set_input_as_handled()


func toggle_pause() -> void:
	is_open = not is_open

	get_tree().paused = is_open
	pause_root.visible = is_open

	if is_open:
		menu_panel.visible = true
		options_panel.visible = false
		Input.mouse_mode = (
			Input.MOUSE_MODE_VISIBLE
		)
	else:
		Input.mouse_mode = (
			Input.MOUSE_MODE_CAPTURED
		)


func _on_resume_pressed() -> void:
	if is_open:
		toggle_pause()


func _on_options_pressed() -> void:
	menu_panel.visible = false
	options_panel.visible = true


func _on_options_back_pressed() -> void:
	options_panel.visible = false
	menu_panel.visible = true


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	is_open = false
	pause_root.visible = false

	Input.mouse_mode = (
		Input.MOUSE_MODE_VISIBLE
	)

	if has_node("/root/AudioManager"):
		AudioManager.ensure_menu_music()

	get_tree().change_scene_to_file(
		MAIN_MENU_SCENE
	)


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
