extends "res://scripts/cinematics/angelastri_encounter.gd"

var return_requests := 0

func _director(_delta: float, _time: float = -1.0) -> void:
	cinematic = false
	returning = false
	event.stage = "waiting"

func _begin_return() -> void:
	return_requests += 1
	preview.clear_preview()
