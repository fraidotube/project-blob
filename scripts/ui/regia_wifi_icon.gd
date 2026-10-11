extends Control

func _draw() -> void:
	var center := Vector2(size.x * 0.5, size.y * 0.82)
	var color := Color("88f4fa")
	var radius := minf(size.x * 0.5, size.y * 0.75)
	for fraction in [0.38, 0.65, 0.92]:
		draw_arc(center, radius * fraction, PI * 1.18, PI * 1.82, 48, color, 12.0, true)
	draw_circle(center, 13.0, color, true, -1.0, true)
