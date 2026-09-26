@tool
extends Node3D


enum SmokePreset {
	CURRENT_CAR,
	CAR_LIGHT,
	CAR_MEDIUM,
	CAR_HEAVY,
	ALIEN_PURPLE_LIGHT,
	ALIEN_PURPLE_MIST
}


@export_enum(
	"Current Car",
	"Car Light",
	"Car Medium",
	"Car Heavy",
	"Alien Purple Light",
	"Alien Purple Mist"
) var preset: int = SmokePreset.CURRENT_CAR


@export var apply_preset: bool = false:
	set(value):
		apply_preset = value

		if value:
			_apply_selected_preset()
			apply_preset = false


func _apply_selected_preset() -> void:
	match preset:
		SmokePreset.CURRENT_CAR:
			_apply_current_car()

		SmokePreset.CAR_LIGHT:
			_apply_car_light()

		SmokePreset.CAR_MEDIUM:
			_apply_car_medium()

		SmokePreset.CAR_HEAVY:
			_apply_car_heavy()

		SmokePreset.ALIEN_PURPLE_LIGHT:
			_apply_alien_purple_light()

		SmokePreset.ALIEN_PURPLE_MIST:
			_apply_alien_purple_mist()


# ============================================================
# CURRENT CAR
# Baseline originale verificata da Git
# ============================================================

func _apply_current_car() -> void:
	_set_plane(
		"SmokePlane_01",
		Vector3(0.0, 0.0, 0.0),
		Vector3(1.0, 1.0, 1.0),
		Color("5C5A56D9"),
		0.85,
		0.28,
		1.0,
		Vector3(0.0, -0.60, 0.50)
	)

	_set_plane(
		"SmokePlane_02",
		Vector3(0.18, 0.20, 0.08),
		Vector3(0.85, 1.10, 0.85),
		Color("6C6964C7"),
		0.72,
		0.28,
		1.0,
		Vector3(0.0, -0.48, 0.50)
	)

	_set_plane(
		"SmokePlane_03",
		Vector3(-0.15, 0.45, -0.05),
		Vector3(1.10, 0.90, 1.10),
		Color("7A7771BF"),
		0.78,
		0.28,
		1.0,
		Vector3(0.0, -0.72, 0.50)
	)

	_set_plane(
		"SmokePlane_04",
		Vector3(0.08, 0.75, 0.12),
		Vector3(0.75, 1.20, 0.75),
		Color("8A8780A8"),
		0.85,
		0.28,
		1.0,
		Vector3(0.0, -0.40, 0.65)
	)


# ============================================================
# CAR LIGHT
# Poco fumo, grigio abbastanza chiaro
# ============================================================

func _apply_car_light() -> void:
	_set_plane(
		"SmokePlane_01",
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.90, 0.95, 0.90),
		Color("77746E8C"),
		0.58,
		0.34,
		0.45,
		Vector3(0.0, -0.42, 0.46)
	)

	_set_plane(
		"SmokePlane_02",
		Vector3(0.18, 0.24, 0.08),
		Vector3(0.82, 1.08, 0.82),
		Color("85817A80"),
		0.52,
		0.38,
		0.40,
		Vector3(0.0, -0.36, 0.52)
	)

	_set_plane(
		"SmokePlane_03",
		Vector3(-0.16, 0.48, -0.05),
		Vector3(1.00, 0.95, 1.00),
		Color("928E8774"),
		0.48,
		0.42,
		0.34,
		Vector3(0.0, -0.46, 0.42)
	)

	_set_plane(
		"SmokePlane_04",
		Vector3(0.08, 0.78, 0.12),
		Vector3(0.75, 1.25, 0.75),
		Color("A09C9466"),
		0.42,
		0.46,
		0.28,
		Vector3(0.0, -0.28, 0.56)
	)


# ============================================================
# CAR MEDIUM
# Fumo incendio normale
# ============================================================

func _apply_car_medium() -> void:
	_set_plane(
		"SmokePlane_01",
		Vector3(0.0, 0.0, 0.0),
		Vector3(1.00, 1.05, 1.00),
		Color("625F5ABF"),
		0.82,
		0.27,
		0.80,
		Vector3(0.0, -0.55, 0.52)
	)

	_set_plane(
		"SmokePlane_02",
		Vector3(0.20, 0.22, 0.09),
		Vector3(0.90, 1.15, 0.90),
		Color("716E68B2"),
		0.74,
		0.30,
		0.72,
		Vector3(0.0, -0.46, 0.55)
	)

	_set_plane(
		"SmokePlane_03",
		Vector3(-0.18, 0.48, -0.06),
		Vector3(1.12, 1.00, 1.12),
		Color("817D76A6"),
		0.70,
		0.33,
		0.64,
		Vector3(0.0, -0.62, 0.46)
	)

	_set_plane(
		"SmokePlane_04",
		Vector3(0.10, 0.80, 0.13),
		Vector3(0.82, 1.32, 0.82),
		Color("918D8590"),
		0.64,
		0.38,
		0.52,
		Vector3(0.0, -0.36, 0.64)
	)


# ============================================================
# CAR HEAVY
# Incendio importante / molto fumo
# ============================================================

func _apply_car_heavy() -> void:
	_set_plane(
		"SmokePlane_01",
		Vector3(0.0, 0.0, 0.0),
		Vector3(1.15, 1.15, 1.15),
		Color("504E4AE6"),
		1.05,
		0.20,
		1.35,
		Vector3(0.0, -0.70, 0.55)
	)

	_set_plane(
		"SmokePlane_02",
		Vector3(0.22, 0.18, 0.10),
		Vector3(1.00, 1.28, 1.00),
		Color("5E5B56D9"),
		0.98,
		0.22,
		1.25,
		Vector3(0.0, -0.58, 0.52)
	)

	_set_plane(
		"SmokePlane_03",
		Vector3(-0.20, 0.48, -0.08),
		Vector3(1.25, 1.12, 1.25),
		Color("6C6963CC"),
		0.90,
		0.25,
		1.15,
		Vector3(0.0, -0.78, 0.48)
	)

	_set_plane(
		"SmokePlane_04",
		Vector3(0.12, 0.84, 0.14),
		Vector3(1.00, 1.42, 1.00),
		Color("7A766FB8"),
		0.82,
		0.30,
		1.00,
		Vector3(0.0, -0.48, 0.68)
	)


# ============================================================
# ALIEN PURPLE LIGHT
# Molto meno fumo, trasparente, quasi una contaminazione
# ============================================================

func _apply_alien_purple_light() -> void:
	_set_plane(
		"SmokePlane_01",
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.70, 0.75, 0.70),
		Color("8B63A866"),
		0.42,
		0.42,
		0.28,
		Vector3(0.08, -0.18, 0.58)
	)

	_set_plane(
		"SmokePlane_02",
		Vector3(0.24, 0.18, 0.12),
		Vector3(0.65, 0.95, 0.65),
		Color("9A72B85C"),
		0.38,
		0.46,
		0.24,
		Vector3(-0.08, -0.22, 0.70)
	)

	_set_plane(
		"SmokePlane_03",
		Vector3(-0.22, 0.38, -0.10),
		Vector3(0.90, 0.78, 0.90),
		Color("AA82C44F"),
		0.34,
		0.50,
		0.20,
		Vector3(0.12, -0.16, 0.48)
	)

	_set_plane(
		"SmokePlane_04",
		Vector3(0.10, 0.64, 0.15),
		Vector3(0.58, 1.05, 0.58),
		Color("B99AD446"),
		0.30,
		0.54,
		0.16,
		Vector3(-0.10, -0.14, 0.76)
	)


# ============================================================
# ALIEN PURPLE MIST
# Più largo ma ancora molto trasparente
# Utile attorno al meteorite, vicino al terreno
# ============================================================

func _apply_alien_purple_mist() -> void:
	_set_plane(
		"SmokePlane_01",
		Vector3(0.0, 0.0, 0.0),
		Vector3(1.20, 0.55, 1.20),
		Color("75538F59"),
		0.44,
		0.46,
		0.24,
		Vector3(0.10, -0.10, 0.52)
	)

	_set_plane(
		"SmokePlane_02",
		Vector3(0.35, 0.08, 0.20),
		Vector3(1.10, 0.65, 1.10),
		Color("8965A355"),
		0.40,
		0.50,
		0.22,
		Vector3(-0.12, -0.12, 0.62)
	)

	_set_plane(
		"SmokePlane_03",
		Vector3(-0.32, 0.18, -0.18),
		Vector3(1.35, 0.58, 1.35),
		Color("9C79B84C"),
		0.36,
		0.54,
		0.18,
		Vector3(0.15, -0.08, 0.44)
	)

	_set_plane(
		"SmokePlane_04",
		Vector3(0.12, 0.32, 0.22),
		Vector3(0.95, 0.80, 0.95),
		Color("B095C93F"),
		0.30,
		0.58,
		0.14,
		Vector3(-0.08, -0.08, 0.70)
	)


# ============================================================
# APPLICAZIONE AL SINGOLO SMOKE PLANE
# ============================================================

func _set_plane(
	plane_name: String,
	plane_position: Vector3,
	plane_scale: Vector3,
	plane_color: Color,
	plane_volume: float,
	plane_aperture: float,
	plane_density: float,
	plane_tex_speed: Vector3
) -> void:
	var plane: MeshInstance3D = (
		get_node_or_null(
			NodePath(plane_name)
		)
		as MeshInstance3D
	)

	if plane == null:
		push_error(
			"Smoke plane non trovato: "
			+ plane_name
		)
		return

	plane.position = plane_position
	plane.scale = plane_scale

	var material: ShaderMaterial = (
		plane.material_override
		as ShaderMaterial
	)

	if material == null:
		push_error(
			"ShaderMaterial non trovato su: "
			+ plane_name
		)
		return

	material.set_shader_parameter(
		"smoke_color",
		plane_color
	)

	material.set_shader_parameter(
		"smoke_volume",
		plane_volume
	)

	material.set_shader_parameter(
		"smoke_aperture",
		plane_aperture
	)

	material.set_shader_parameter(
		"density",
		plane_density
	)

	material.set_shader_parameter(
		"tex_speed",
		plane_tex_speed
	)

	print(
		"PRESET APPLICATO: ",
		plane_name
	)
