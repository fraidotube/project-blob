extends Control

const MENU_THEME := preload("res://scenes/ui/project_blob_menu_theme.tres")
const BLOB_SHADER := preload("res://assets/shaders/boss_health_blob.gdshader")
var _style: StyleBoxFlat
var _liquid: ColorRect
var show_decorations := true

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_style = MENU_THEME.get_stylebox("panel", "Panel").duplicate() as StyleBoxFlat
	_style.bg_color = Color("0b0812")
	_style.border_color = Color("7e3ba2")
	_style.corner_radius_top_right = 18
	_style.corner_radius_bottom_left = 18
	_style.shadow_color = Color(0.24, 0.02, 0.35, 0.42)
	_style.shadow_size = 24
	_liquid = ColorRect.new()
	_liquid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material := ShaderMaterial.new()
	material.shader = BLOB_SHADER
	material.set_shader_parameter("blob_color", Color(0.18, 0.015, 0.29, 0.7))
	material.set_shader_parameter("glow_color", Color(0.76, 0.18, 0.94, 1))
	material.set_shader_parameter("glow_strength", 0.7)
	material.set_shader_parameter("speed", 0.45)
	_liquid.material = material
	add_child(_liquid)
	_liquid.visible = show_decorations
	resized.connect(_layout)
	_layout()

func _layout() -> void:
	_liquid.position = Vector2(22, 22)
	_liquid.size = Vector2(maxf(0, size.x - 44), 8)
	queue_redraw()

func _draw() -> void:
	if _style == null:
		return
	draw_style_box(_style, Rect2(Vector2.ZERO, size))
	if not show_decorations:
		return
	draw_line(Vector2(22, 44), Vector2(22, size.y - 30), Color("a351c8"), 3)
	draw_line(Vector2(size.x - 24, size.y - 21), Vector2(size.x - 108, size.y - 21), Color("8747ac"), 2)
