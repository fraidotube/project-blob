@tool
extends Node3D


enum SmokePreset {
	CURRENT_CAR,
	CAR_LIGHT,
	CAR_MEDIUM,
	CAR_HEAVY,
	CAR_THIN_GREY,
	CAR_SOFT_GREY,
	CAR_DARK_COLUMN,
	CAR_LONG_SMOKE,
	ALIEN_PURPLE_LIGHT,
	ALIEN_PURPLE_MIST
}


# ============================================================
# PRESET
# ============================================================

@export_group("PRESET")

@export_enum(
	"Current Car",
	"Car Light",
	"Car Medium",
	"Car Heavy",
	"Car Thin Grey",
	"Car Soft Grey",
	"Car Dark Column",
	"Car Long Smoke",
	"Alien Purple Light",
	"Alien Purple Mist"
) var preset: int = SmokePreset.CURRENT_CAR


@export var apply_preset: bool = false:
	set(value):
		apply_preset = value

		if value:
			_apply_selected_preset()
			apply_preset = false


# ============================================================
# SHAPE / FADE
# ============================================================

@export_group("SHAPE / FADE")

@export_range(
	0.01,
	0.49,
	0.01
) var side_fade := 0.20

@export_range(
	0.01,
	0.49,
	0.01
) var vertical_fade := 0.12


# ============================================================
# MANUAL - PLANE 01
# ============================================================

@export_group("MANUAL - PLANE 01")

@export var plane_01_color := Color("5C5A56D9")

@export_range(
	0.0,
	2.0,
	0.01
) var plane_01_density := 1.0

@export_range(
	0.0,
	2.0,
	0.01
) var plane_01_volume := 0.85

@export_range(
	0.0,
	3.0,
	0.01
) var plane_01_aperture := 0.28

@export var plane_01_tex_speed := Vector3(
	0.0,
	-0.60,
	0.50
)

@export var plane_01_position := Vector3(
	0.0,
	0.0,
	0.0
)

@export var plane_01_scale := Vector3(
	1.0,
	1.0,
	1.0
)


# ============================================================
# MANUAL - PLANE 02
# ============================================================

@export_group("MANUAL - PLANE 02")

@export var plane_02_color := Color("6C6964C7")

@export_range(
	0.0,
	2.0,
	0.01
) var plane_02_density := 1.0

@export_range(
	0.0,
	2.0,
	0.01
) var plane_02_volume := 0.72

@export_range(
	0.0,
	3.0,
	0.01
) var plane_02_aperture := 0.28

@export var plane_02_tex_speed := Vector3(
	0.0,
	-0.48,
	0.50
)

@export var plane_02_position := Vector3(
	0.18,
	0.20,
	0.08
)

@export var plane_02_scale := Vector3(
	0.85,
	1.10,
	0.85
)


# ============================================================
# MANUAL - PLANE 03
# ============================================================

@export_group("MANUAL - PLANE 03")

@export var plane_03_color := Color("7A7771BF")

@export_range(
	0.0,
	2.0,
	0.01
) var plane_03_density := 1.0

@export_range(
	0.0,
	2.0,
	0.01
) var plane_03_volume := 0.78

@export_range(
	0.0,
	3.0,
	0.01
) var plane_03_aperture := 0.28

@export var plane_03_tex_speed := Vector3(
	0.0,
	-0.72,
	0.50
)

@export var plane_03_position := Vector3(
	-0.15,
	0.45,
	-0.05
)

@export var plane_03_scale := Vector3(
	1.10,
	0.90,
	1.10
)


# ============================================================
# MANUAL - PLANE 04
# ============================================================

@export_group("MANUAL - PLANE 04")

@export var plane_04_color := Color("8A8780A8")

@export_range(
	0.0,
	2.0,
	0.01
) var plane_04_density := 1.0

@export_range(
	0.0,
	2.0,
	0.01
) var plane_04_volume := 0.85

@export_range(
	0.0,
	3.0,
	0.01
) var plane_04_aperture := 0.28

@export var plane_04_tex_speed := Vector3(
	0.0,
	-0.40,
	0.65
)

@export var plane_04_position := Vector3(
	0.08,
	0.75,
	0.12
)

@export var plane_04_scale := Vector3(
	0.75,
	1.20,
	0.75
)


# ============================================================
# MANUAL APPLY
# ============================================================

@export_group("MANUAL APPLY")

@export var apply_manual: bool = false:
	set(value):
		apply_manual = value

		if value:
			_apply_manual_settings()
			apply_manual = false


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	_ensure_unique_materials()
	_apply_manual_settings()


# ============================================================
# MATERIALI INDIPENDENTI
# ============================================================

func _ensure_unique_materials() -> void:
	for plane_name in [
		"SmokePlane_01",
		"SmokePlane_02",
		"SmokePlane_03",
		"SmokePlane_04"
	]:
		var plane: MeshInstance3D = (
			get_node_or_null(
				NodePath(plane_name)
			)
			as MeshInstance3D
		)

		if plane == null:
			continue

		var material: ShaderMaterial = (
			plane.material_override
			as ShaderMaterial
		)

		if material == null:
			continue

		if material.resource_local_to_scene:
			continue

		var unique_material: ShaderMaterial = (
			material.duplicate()
			as ShaderMaterial
		)

		if unique_material == null:
			continue

		unique_material.resource_local_to_scene = true

		plane.material_override = unique_material


# ============================================================
# PRESET SELECTION
# ============================================================

func _apply_selected_preset() -> void:
	_ensure_unique_materials()

	match preset:
		SmokePreset.CURRENT_CAR:
			_load_current_car()

		SmokePreset.CAR_LIGHT:
			_load_car_light()

		SmokePreset.CAR_MEDIUM:
			_load_car_medium()

		SmokePreset.CAR_HEAVY:
			_load_car_heavy()

		SmokePreset.CAR_THIN_GREY:
			_load_car_thin_grey()

		SmokePreset.CAR_SOFT_GREY:
			_load_car_soft_grey()

		SmokePreset.CAR_DARK_COLUMN:
			_load_car_dark_column()

		SmokePreset.CAR_LONG_SMOKE:
			_load_car_long_smoke()

		SmokePreset.ALIEN_PURPLE_LIGHT:
			_load_alien_purple_light()

		SmokePreset.ALIEN_PURPLE_MIST:
			_load_alien_purple_mist()

	_apply_manual_settings()


# ============================================================
# CURRENT CAR
# ============================================================

func _load_current_car() -> void:
	_set_shape(
		0.20,
		0.12
	)

	_load_plane_01(
		Vector3(0.0, 0.0, 0.0),
		Vector3(1.0, 1.0, 1.0),
		Color("5C5A56D9"),
		0.85,
		0.28,
		1.0,
		Vector3(0.0, -0.60, 0.50)
	)

	_load_plane_02(
		Vector3(0.18, 0.20, 0.08),
		Vector3(0.85, 1.10, 0.85),
		Color("6C6964C7"),
		0.72,
		0.28,
		1.0,
		Vector3(0.0, -0.48, 0.50)
	)

	_load_plane_03(
		Vector3(-0.15, 0.45, -0.05),
		Vector3(1.10, 0.90, 1.10),
		Color("7A7771BF"),
		0.78,
		0.28,
		1.0,
		Vector3(0.0, -0.72, 0.50)
	)

	_load_plane_04(
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
# ============================================================

func _load_car_light() -> void:
	_set_shape(
		0.23,
		0.14
	)

	_load_plane_01(
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.90, 1.10, 0.90),
		Color("77746E8C"),
		0.58,
		0.34,
		0.45,
		Vector3(0.0, -0.42, 0.46)
	)

	_load_plane_02(
		Vector3(0.18, 0.28, 0.08),
		Vector3(0.82, 1.30, 0.82),
		Color("85817A80"),
		0.52,
		0.38,
		0.40,
		Vector3(0.0, -0.36, 0.52)
	)

	_load_plane_03(
		Vector3(-0.16, 0.58, -0.05),
		Vector3(1.00, 1.45, 1.00),
		Color("928E8774"),
		0.48,
		0.42,
		0.34,
		Vector3(0.0, -0.46, 0.42)
	)

	_load_plane_04(
		Vector3(0.08, 0.95, 0.12),
		Vector3(0.75, 1.65, 0.75),
		Color("A09C9466"),
		0.42,
		0.46,
		0.28,
		Vector3(0.0, -0.28, 0.56)
	)


# ============================================================
# CAR MEDIUM
# ============================================================

func _load_car_medium() -> void:
	_set_shape(
		0.22,
		0.13
	)

	_load_plane_01(
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.95, 1.25, 0.95),
		Color("625F5ABF"),
		0.82,
		0.27,
		0.80,
		Vector3(0.0, -0.55, 0.52)
	)

	_load_plane_02(
		Vector3(0.20, 0.30, 0.09),
		Vector3(0.88, 1.50, 0.88),
		Color("716E68B2"),
		0.74,
		0.30,
		0.72,
		Vector3(0.0, -0.46, 0.55)
	)

	_load_plane_03(
		Vector3(-0.18, 0.67, -0.06),
		Vector3(1.02, 1.75, 1.02),
		Color("817D76A6"),
		0.70,
		0.33,
		0.64,
		Vector3(0.0, -0.62, 0.46)
	)

	_load_plane_04(
		Vector3(0.10, 1.06, 0.13),
		Vector3(0.78, 2.00, 0.78),
		Color("918D8590"),
		0.64,
		0.38,
		0.52,
		Vector3(0.0, -0.36, 0.64)
	)


# ============================================================
# CAR HEAVY
# ============================================================

func _load_car_heavy() -> void:
	_set_shape(
		0.19,
		0.11
	)

	_load_plane_01(
		Vector3(0.0, 0.0, 0.0),
		Vector3(1.08, 1.40, 1.08),
		Color("504E4AE6"),
		1.05,
		0.20,
		1.35,
		Vector3(0.0, -0.70, 0.55)
	)

	_load_plane_02(
		Vector3(0.22, 0.35, 0.10),
		Vector3(0.98, 1.70, 0.98),
		Color("5E5B56D9"),
		0.98,
		0.22,
		1.25,
		Vector3(0.0, -0.58, 0.52)
	)

	_load_plane_03(
		Vector3(-0.20, 0.82, -0.08),
		Vector3(1.15, 2.00, 1.15),
		Color("6C6963CC"),
		0.90,
		0.25,
		1.15,
		Vector3(0.0, -0.78, 0.48)
	)

	_load_plane_04(
		Vector3(0.12, 1.30, 0.14),
		Vector3(0.90, 2.30, 0.90),
		Color("7A766FB8"),
		0.82,
		0.30,
		1.00,
		Vector3(0.0, -0.48, 0.68)
	)


# ============================================================
# CAR THIN GREY
# Leggero, trasparente, lungo
# ============================================================

func _load_car_thin_grey() -> void:
	_set_shape(
		0.30,
		0.18
	)

	_load_plane_01(
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.68, 1.45, 0.68),
		Color("696A6870"),
		0.50,
		0.42,
		0.22,
		Vector3(0.02, -0.34, 0.44)
	)

	_load_plane_02(
		Vector3(0.15, 0.40, 0.06),
		Vector3(0.73, 1.75, 0.73),
		Color("76777462"),
		0.44,
		0.48,
		0.18,
		Vector3(-0.03, -0.28, 0.50)
	)

	_load_plane_03(
		Vector3(-0.13, 0.86, -0.05),
		Vector3(0.80, 2.10, 0.80),
		Color("84858054"),
		0.38,
		0.54,
		0.14,
		Vector3(0.04, -0.38, 0.42)
	)

	_load_plane_04(
		Vector3(0.08, 1.35, 0.10),
		Vector3(0.65, 2.45, 0.65),
		Color("92938D48"),
		0.32,
		0.60,
		0.10,
		Vector3(-0.02, -0.24, 0.56)
	)


# ============================================================
# CAR SOFT GREY
# Primo preset che proverei in gioco
# ============================================================

func _load_car_soft_grey() -> void:
	_set_shape(
		0.27,
		0.16
	)

	_load_plane_01(
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.80, 1.35, 0.80),
		Color("5F605E91"),
		0.62,
		0.38,
		0.34,
		Vector3(0.02, -0.42, 0.46)
	)

	_load_plane_02(
		Vector3(0.17, 0.36, 0.07),
		Vector3(0.84, 1.65, 0.84),
		Color("6D6E6B82"),
		0.56,
		0.43,
		0.30,
		Vector3(-0.03, -0.35, 0.52)
	)

	_load_plane_03(
		Vector3(-0.15, 0.80, -0.05),
		Vector3(0.92, 2.00, 0.92),
		Color("7C7D7974"),
		0.49,
		0.49,
		0.24,
		Vector3(0.04, -0.48, 0.43)
	)

	_load_plane_04(
		Vector3(0.09, 1.25, 0.11),
		Vector3(0.73, 2.35, 0.73),
		Color("8A8B8662"),
		0.41,
		0.56,
		0.18,
		Vector3(-0.02, -0.30, 0.58)
	)


# ============================================================
# CAR DARK COLUMN
# Fumo più scuro da incendio importante
# ============================================================

func _load_car_dark_column() -> void:
	_set_shape(
		0.25,
		0.15
	)

	_load_plane_01(
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.82, 1.55, 0.82),
		Color("393A39C9"),
		0.76,
		0.31,
		0.72,
		Vector3(0.02, -0.50, 0.48)
	)

	_load_plane_02(
		Vector3(0.17, 0.42, 0.08),
		Vector3(0.88, 1.90, 0.88),
		Color("464744B8"),
		0.70,
		0.36,
		0.62,
		Vector3(-0.04, -0.42, 0.54)
	)

	_load_plane_03(
		Vector3(-0.17, 0.92, -0.06),
		Vector3(0.96, 2.30, 0.96),
		Color("555652A5"),
		0.62,
		0.42,
		0.50,
		Vector3(0.05, -0.56, 0.44)
	)

	_load_plane_04(
		Vector3(0.10, 1.45, 0.12),
		Vector3(0.78, 2.70, 0.78),
		Color("6565608F"),
		0.52,
		0.50,
		0.38,
		Vector3(-0.03, -0.36, 0.62)
	)


# ============================================================
# CAR LONG SMOKE
# Stretto e molto allungato
# ============================================================

func _load_car_long_smoke() -> void:
	_set_shape(
		0.31,
		0.19
	)

	_load_plane_01(
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.62, 1.75, 0.62),
		Color("5657547A"),
		0.54,
		0.42,
		0.26,
		Vector3(0.02, -0.34, 0.46)
	)

	_load_plane_02(
		Vector3(0.14, 0.48, 0.06),
		Vector3(0.68, 2.15, 0.68),
		Color("6667646C"),
		0.48,
		0.48,
		0.22,
		Vector3(-0.04, -0.29, 0.54)
	)

	_load_plane_03(
		Vector3(-0.12, 1.02, -0.05),
		Vector3(0.76, 2.60, 0.76),
		Color("7677735D"),
		0.41,
		0.54,
		0.17,
		Vector3(0.05, -0.40, 0.44)
	)

	_load_plane_04(
		Vector3(0.08, 1.60, 0.10),
		Vector3(0.62, 3.10, 0.62),
		Color("8788834C"),
		0.34,
		0.61,
		0.12,
		Vector3(-0.03, -0.24, 0.62)
	)


# ============================================================
# ALIEN PURPLE LIGHT
# ============================================================

func _load_alien_purple_light() -> void:
	_set_shape(
		0.28,
		0.17
	)

	_load_plane_01(
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.70, 0.75, 0.70),
		Color("8B63A866"),
		0.42,
		0.42,
		0.28,
		Vector3(0.08, -0.18, 0.58)
	)

	_load_plane_02(
		Vector3(0.24, 0.18, 0.12),
		Vector3(0.65, 0.95, 0.65),
		Color("9A72B85C"),
		0.38,
		0.46,
		0.24,
		Vector3(-0.08, -0.22, 0.70)
	)

	_load_plane_03(
		Vector3(-0.22, 0.38, -0.10),
		Vector3(0.90, 0.78, 0.90),
		Color("AA82C44F"),
		0.34,
		0.50,
		0.20,
		Vector3(0.12, -0.16, 0.48)
	)

	_load_plane_04(
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
# ============================================================

func _load_alien_purple_mist() -> void:
	_set_shape(
		0.34,
		0.20
	)

	_load_plane_01(
		Vector3(0.0, 0.0, 0.0),
		Vector3(1.20, 0.55, 1.20),
		Color("75538F59"),
		0.44,
		0.46,
		0.24,
		Vector3(0.10, -0.10, 0.52)
	)

	_load_plane_02(
		Vector3(0.35, 0.08, 0.20),
		Vector3(1.10, 0.65, 1.10),
		Color("8965A355"),
		0.40,
		0.50,
		0.22,
		Vector3(-0.12, -0.12, 0.62)
	)

	_load_plane_03(
		Vector3(-0.32, 0.18, -0.18),
		Vector3(1.35, 0.58, 1.35),
		Color("9C79B84C"),
		0.36,
		0.54,
		0.18,
		Vector3(0.15, -0.08, 0.44)
	)

	_load_plane_04(
		Vector3(0.12, 0.32, 0.22),
		Vector3(0.95, 0.80, 0.95),
		Color("B095C93F"),
		0.30,
		0.58,
		0.14,
		Vector3(-0.08, -0.08, 0.70)
	)


# ============================================================
# LOAD HELPERS
# ============================================================

func _set_shape(
	new_side_fade: float,
	new_vertical_fade: float
) -> void:
	side_fade = new_side_fade
	vertical_fade = new_vertical_fade


func _load_plane_01(
	new_position: Vector3,
	new_scale: Vector3,
	new_color: Color,
	new_volume: float,
	new_aperture: float,
	new_density: float,
	new_tex_speed: Vector3
) -> void:
	plane_01_position = new_position
	plane_01_scale = new_scale
	plane_01_color = new_color
	plane_01_volume = new_volume
	plane_01_aperture = new_aperture
	plane_01_density = new_density
	plane_01_tex_speed = new_tex_speed


func _load_plane_02(
	new_position: Vector3,
	new_scale: Vector3,
	new_color: Color,
	new_volume: float,
	new_aperture: float,
	new_density: float,
	new_tex_speed: Vector3
) -> void:
	plane_02_position = new_position
	plane_02_scale = new_scale
	plane_02_color = new_color
	plane_02_volume = new_volume
	plane_02_aperture = new_aperture
	plane_02_density = new_density
	plane_02_tex_speed = new_tex_speed


func _load_plane_03(
	new_position: Vector3,
	new_scale: Vector3,
	new_color: Color,
	new_volume: float,
	new_aperture: float,
	new_density: float,
	new_tex_speed: Vector3
) -> void:
	plane_03_position = new_position
	plane_03_scale = new_scale
	plane_03_color = new_color
	plane_03_volume = new_volume
	plane_03_aperture = new_aperture
	plane_03_density = new_density
	plane_03_tex_speed = new_tex_speed


func _load_plane_04(
	new_position: Vector3,
	new_scale: Vector3,
	new_color: Color,
	new_volume: float,
	new_aperture: float,
	new_density: float,
	new_tex_speed: Vector3
) -> void:
	plane_04_position = new_position
	plane_04_scale = new_scale
	plane_04_color = new_color
	plane_04_volume = new_volume
	plane_04_aperture = new_aperture
	plane_04_density = new_density
	plane_04_tex_speed = new_tex_speed


# ============================================================
# APPLY MANUAL
# ============================================================

func _apply_manual_settings() -> void:
	_ensure_unique_materials()

	_set_plane(
		"SmokePlane_01",
		plane_01_position,
		plane_01_scale,
		plane_01_color,
		plane_01_volume,
		plane_01_aperture,
		plane_01_density,
		plane_01_tex_speed
	)

	_set_plane(
		"SmokePlane_02",
		plane_02_position,
		plane_02_scale,
		plane_02_color,
		plane_02_volume,
		plane_02_aperture,
		plane_02_density,
		plane_02_tex_speed
	)

	_set_plane(
		"SmokePlane_03",
		plane_03_position,
		plane_03_scale,
		plane_03_color,
		plane_03_volume,
		plane_03_aperture,
		plane_03_density,
		plane_03_tex_speed
	)

	_set_plane(
		"SmokePlane_04",
		plane_04_position,
		plane_04_scale,
		plane_04_color,
		plane_04_volume,
		plane_04_aperture,
		plane_04_density,
		plane_04_tex_speed
	)


# ============================================================
# APPLY SINGLE PLANE
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

	material.set_shader_parameter(
		"side_fade",
		side_fade
	)

	material.set_shader_parameter(
		"vertical_fade",
		vertical_fade
	)
