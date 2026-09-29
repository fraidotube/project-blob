extends Camera3D

func _ready() -> void:
	_apply_saved_fov()


func _apply_saved_fov() -> void:
	var settings := get_node_or_null(
		"/root/SettingsManager"
	)

	if settings == null:
		return

	fov = clampf(
		float(settings.get("camera_fov")),
		60.0,
		100.0
	)
