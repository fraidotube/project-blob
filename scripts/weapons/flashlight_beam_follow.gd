extends SpotLight3D

@export var rotation_source: Node3D


func _process(_delta: float) -> void:
	if rotation_source == null:
		return

	global_basis = rotation_source.global_basis.orthonormalized()
