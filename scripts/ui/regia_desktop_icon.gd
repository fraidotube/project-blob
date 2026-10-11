extends Control

var kind := "computer"

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	if kind == "folder":
		draw_style_box(_plate(Color("d99d29")), Rect2(3, 9, 34, 24))
		draw_rect(Rect2(5, 5, 15, 8), Color("efbc50"))
		draw_colored_polygon(PackedVector2Array([Vector2(2, 14), Vector2(39, 14), Vector2(35, 35), Vector2(5, 35)]), Color("f4cc65"))
	else:
		draw_style_box(_plate(Color("b5c9d4")), Rect2(2, 3, 36, 25))
		draw_rect(Rect2(5, 6, 30, 19), Color("1c85bf"))
		draw_colored_polygon(PackedVector2Array([Vector2(5, 6), Vector2(35, 6), Vector2(5, 25)]), Color("79cfea"))
		draw_rect(Rect2(17, 28, 6, 5), Color("a7b6c3"))
		draw_rect(Rect2(10, 33, 20, 3), Color("d4e0e5"))

func _plate(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(2)
	return style
