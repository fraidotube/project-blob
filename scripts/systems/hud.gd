extends CanvasLayer

const HITMARKER_DURATION := 0.10

@onready var hit_marker: Label = $Interface/HitMarker

var hitmarker_time_left := 0.0


func _ready() -> void:
	add_to_group("hud")
	hit_marker.visible = false


func _process(delta: float) -> void:
	if hitmarker_time_left <= 0.0:
		return

	hitmarker_time_left -= delta

	if hitmarker_time_left <= 0.0:
		hit_marker.visible = false


func show_hitmarker() -> void:
	hit_marker.visible = true
	hitmarker_time_left = HITMARKER_DURATION
