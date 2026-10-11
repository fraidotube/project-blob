extends Control

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("05314e"))
	var origin := Vector2(730, 280)
	for i in range(90, 0, -1):
		var radius := i * 6.0
		draw_circle(origin, radius, Color(0.02, 0.45, 0.76, 0.013))
	var corners: Array[Vector2] = [Vector2(633, 183), Vector2(797, 153), Vector2(797, 368), Vector2(633, 338)]
	for row in 2:
		for col in 2:
			var left := float(col) / 2 + 0.018
			var right := float(col + 1) / 2 - 0.018
			var top := float(row) / 2 + 0.012
			var bottom := float(row + 1) / 2 - 0.012
			var a := corners[0].lerp(corners[1], left).lerp(corners[3].lerp(corners[2], left), top)
			var b := corners[0].lerp(corners[1], right).lerp(corners[3].lerp(corners[2], right), top)
			var c := corners[0].lerp(corners[1], right).lerp(corners[3].lerp(corners[2], right), bottom)
			var d := corners[0].lerp(corners[1], left).lerp(corners[3].lerp(corners[2], left), bottom)
			draw_colored_polygon(PackedVector2Array([a, b, c, d]), Color("29b8ff"))
	for edge in [corners[0], corners[3]]:
		draw_colored_polygon(PackedVector2Array([edge, edge + Vector2(-600, -90), edge + Vector2(-600, 90)]), Color(0.05, 0.5, 0.9, 0.06))
