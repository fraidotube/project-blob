extends Control

const HUD := preload("res://assets/ui/hud/hud_empty.png")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	if size.x < 30 or size.y < 30:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color("111b20"))
	draw_rect(Rect2(Vector2(6, 6), size - Vector2(12, 12)), Color("223541"))
	draw_rect(Rect2(Vector2(15, 15), size - Vector2(30, 30)), Color("13232d"))
	draw_texture_rect_region(HUD, Rect2(0, 0, size.x, 18), Rect2(28, 35, 400, 18))
	draw_texture_rect_region(HUD, Rect2(0, size.y - 18, size.x, 18), Rect2(450, 243, 460, 18))
	draw_rect(Rect2(0, 18, 9, size.y - 36), Color("566166"))
	draw_rect(Rect2(size.x - 9, 18, 9, size.y - 36), Color("566166"))
	draw_rect(Rect2(14, 14, size.x - 28, size.y - 28), Color("73828a"), false, 1)
	for corner: Vector2 in [Vector2(12, 12), Vector2(size.x - 12, 12), Vector2(12, size.y - 12), size - Vector2(12, 12)]:
		draw_circle(corner, 6, Color("090d0f"))
		draw_circle(corner - Vector2(0, 1), 4, Color("aaa18f"))
		draw_line(corner + Vector2(-2, -2), corner + Vector2(2, 2), Color("323c41"), 2)
	# Painted identification strip, with the restrained blob purple from the menu.
	draw_line(Vector2(30, 24), Vector2(size.x - 30, 24), Color("d8b155"), 3)
	draw_line(Vector2(30, size.y - 25), Vector2(size.x - 30, size.y - 25), Color("74537c"), 2)
