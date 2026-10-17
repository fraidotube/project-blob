extends Camera3D

@export_group("Preferenze visuale")
## Se attivo, il FOV del menu prevale sul FOV nativo della Camera3D all'avvio.
## Disattivare per usare il valore Fov della scena, ad esempio in una scena di prova.
@export var use_saved_fov := true

func _ready() -> void:
	if use_saved_fov:
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
