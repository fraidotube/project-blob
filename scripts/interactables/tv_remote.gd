extends Area3D

@export var tv_controller: Node


func interact() -> void:
	if tv_controller == null:
		return

	if tv_controller.has_method("toggle_tv"):
		tv_controller.toggle_tv()
