extends Control

var phase := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	phase += delta
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.27
	if radius < 1.0:
		return
	var outline := PackedVector2Array()
	for index in range(97):
		var angle := TAU * index / 96.0
		var wave := 1.0 + 0.12 * sin(angle * 3.0 + phase * 1.7) + 0.06 * sin(angle * 5.0 - phase)
		outline.append(center + Vector2.from_angle(angle) * radius * wave)
	for glow in range(4, 0, -1):
		draw_polyline(outline, Color(0.65, 0.12, 0.9, 0.045), glow * 9.0, true)
	var fill := outline.duplicate()
	fill.resize(96)
	draw_colored_polygon(fill, Color("291039"))
	draw_polyline(outline, Color("d769f7"), 2.5, true)
	for index in range(5):
		var angle := phase * 0.7 + TAU * index / 5.0
		var point := center + Vector2.from_angle(angle) * radius * 1.55
		draw_circle(point, 4.0 + sin(phase * 2.0 + index), Color("70ddeb"), true, -1.0, true)
	draw_circle(center + Vector2(-radius * 0.3, -radius * 0.3), radius * 0.18, Color(0.9, 0.5, 1.0, 0.25), true, -1.0, true)
