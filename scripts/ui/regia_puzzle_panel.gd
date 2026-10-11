extends PanelContainer

const SKIN := preload("res://scripts/ui/inventory_skin.gd")
var column: VBoxContainer
var heading: Label
var body: Label

func _init() -> void:
	custom_minimum_size = Vector2(820, 570)
	add_theme_stylebox_override("panel", SKIN.detail_panel())
	column = VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	add_child(column)
	heading = Label.new()
	heading.add_theme_font_size_override("font_size", 30)
	heading.add_theme_color_override("font_color", Color("e8d5ff"))
	column.add_child(heading)
	body = Label.new()
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(740, 260)
	body.add_theme_font_size_override("font_size", 23)
	body.add_theme_color_override("font_color", Color("d2c2df"))
	column.add_child(body)

func add_action(text: String, callback: Callable, enabled: bool = true) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 46
	SKIN.button(button)
	button.disabled = not enabled
	button.pressed.connect(callback)
	column.add_child(button)
	return button
