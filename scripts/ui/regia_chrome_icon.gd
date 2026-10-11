extends Control

func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.48
	var colors := [Color("ea4335"), Color("fbbc05"), Color("34a853")]
	for sector in 3:
		var polygon := PackedVector2Array([center])
		for step in 17:
			var angle := -PI / 2 + TAU * (float(sector) / 3 + float(step) / 48)
			polygon.append(center + Vector2(cos(angle), sin(angle)) * radius)
		draw_colored_polygon(polygon, colors[sector])
	draw_circle(center, radius * 0.48, Color.WHITE, true, -1, true)
	draw_circle(center, radius * 0.39, Color("4285f4"), true, -1, true)
