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


# ============================================================
# PRESET
# ============================================================

@export_group("PRESET")

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
# APPLY MANUAL
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
# APPLICAZIONE PRESET
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

		SmokePreset.ALIEN_PURPLE_LIGHT:
			_load_alien_purple_light()

		SmokePreset.ALIEN_PURPLE_MIST:
			_load_alien_purple_mist()

	_apply_manual_settings()


# ============================================================
# PRESET: CURRENT CAR
# Baseline verificata
# ============================================================

func _load_current_car() -> void:
	plane_01_position = Vector3(
		0.0,
		0.0,
		0.0
	)

	plane_01_scale = Vector3(
		1.0,
		1.0,
		1.0
	)

	plane_01_color = Color("5C5A56D9")
	plane_01_volume = 0.85
	plane_01_aperture = 0.28
	plane_01_density = 1.0

	plane_01_tex_speed = Vector3(
		0.0,
		-0.60,
		0.50
	)

	plane_02_position = Vector3(
		0.18,
		0.20,
		0.08
	)

	plane_02_scale = Vector3(
		0.85,
		1.10,
		0.85
	)

	plane_02_color = Color("6C6964C7")
	plane_02_volume = 0.72
	plane_02_aperture = 0.28
	plane_02_density = 1.0

	plane_02_tex_speed = Vector3(
		0.0,
		-0.48,
		0.50
	)

	plane_03_position = Vector3(
		-0.15,
		0.45,
		-0.05
	)

	plane_03_scale = Vector3(
		1.10,
		0.90,
		1.10
	)

	plane_03_color = Color("7A7771BF")
	plane_03_volume = 0.78
	plane_03_aperture = 0.28
	plane_03_density = 1.0

	plane_03_tex_speed = Vector3(
		0.0,
		-0.72,
		0.50
	)

	plane_04_position = Vector3(
		0.08,
		0.75,
		0.12
	)

	plane_04_scale = Vector3(
		0.75,
		1.20,
		0.75
	)

	plane_04_color = Color("8A8780A8")
	plane_04_volume = 0.85
	plane_04_aperture = 0.28
	plane_04_density = 1.0

	plane_04_tex_speed = Vector3(
		0.0,
		-0.40,
		0.65
	)


# ============================================================
# PRESET: CAR LIGHT
# ============================================================

func _load_car_light() -> void:
	plane_01_position = Vector3(
		0.0,
		0.0,
		0.0
	)

	plane_01_scale = Vector3(
		0.90,
		0.95,
		0.90
	)

	plane_01_color = Color("77746E8C")
	plane_01_volume = 0.58
	plane_01_aperture = 0.34
	plane_01_density = 0.45

	plane_01_tex_speed = Vector3(
		0.0,
		-0.42,
		0.46
	)

	plane_02_position = Vector3(
		0.18,
		0.24,
		0.08
	)

	plane_02_scale = Vector3(
		0.82,
		1.08,
		0.82
	)

	plane_02_color = Color("85817A80")
	plane_02_volume = 0.52
	plane_02_aperture = 0.38
	plane_02_density = 0.40

	plane_02_tex_speed = Vector3(
		0.0,
		-0.36,
		0.52
	)

	plane_03_position = Vector3(
		-0.16,
		0.48,
		-0.05
	)

	plane_03_scale = Vector3(
		1.00,
		0.95,
		1.00
	)

	plane_03_color = Color("928E8774")
	plane_03_volume = 0.48
	plane_03_aperture = 0.42
	plane_03_density = 0.34

	plane_03_tex_speed = Vector3(
		0.0,
		-0.46,
		0.42
	)

	plane_04_position = Vector3(
		0.08,
		0.78,
		0.12
	)

	plane_04_scale = Vector3(
		0.75,
		1.25,
		0.75
	)

	plane_04_color = Color("A09C9466")
	plane_04_volume = 0.42
	plane_04_aperture = 0.46
	plane_04_density = 0.28

	plane_04_tex_speed = Vector3(
		0.0,
		-0.28,
		0.56
	)


# ============================================================
# PRESET: CAR MEDIUM
# ============================================================

func _load_car_medium() -> void:
	plane_01_position = Vector3(
		0.0,
		0.0,
		0.0
	)

	plane_01_scale = Vector3(
		1.00,
		1.05,
		1.00
	)

	plane_01_color = Color("625F5ABF")
	plane_01_volume = 0.82
	plane_01_aperture = 0.27
	plane_01_density = 0.80

	plane_01_tex_speed = Vector3(
		0.0,
		-0.55,
		0.52
	)

	plane_02_position = Vector3(
		0.20,
		0.22,
		0.09
	)

	plane_02_scale = Vector3(
		0.90,
		1.15,
		0.90
	)

	plane_02_color = Color("716E68B2")
	plane_02_volume = 0.74
	plane_02_aperture = 0.30
	plane_02_density = 0.72

	plane_02_tex_speed = Vector3(
		0.0,
		-0.46,
		0.55
	)

	plane_03_position = Vector3(
		-0.18,
		0.48,
		-0.06
	)

	plane_03_scale = Vector3(
		1.12,
		1.00,
		1.12
	)

	plane_03_color = Color("817D76A6")
	plane_03_volume = 0.70
	plane_03_aperture = 0.33
	plane_03_density = 0.64

	plane_03_tex_speed = Vector3(
		0.0,
		-0.62,
		0.46
	)

	plane_04_position = Vector3(
		0.10,
		0.80,
		0.13
	)

	plane_04_scale = Vector3(
		0.82,
		1.32,
		0.82
	)

	plane_04_color = Color("918D8590")
	plane_04_volume = 0.64
	plane_04_aperture = 0.38
	plane_04_density = 0.52

	plane_04_tex_speed = Vector3(
		0.0,
		-0.36,
		0.64
	)


# ============================================================
# PRESET: CAR HEAVY
# ============================================================

func _load_car_heavy() -> void:
	plane_01_position = Vector3(
		0.0,
		0.0,
		0.0
	)

	plane_01_scale = Vector3(
		1.15,
		1.15,
		1.15
	)

	plane_01_color = Color("504E4AE6")
	plane_01_volume = 1.05
	plane_01_aperture = 0.20
	plane_01_density = 1.35

	plane_01_tex_speed = Vector3(
		0.0,
		-0.70,
		0.55
	)

	plane_02_position = Vector3(
		0.22,
		0.18,
		0.10
	)

	plane_02_scale = Vector3(
		1.00,
		1.28,
		1.00
	)

	plane_02_color = Color("5E5B56D9")
	plane_02_volume = 0.98
	plane_02_aperture = 0.22
	plane_02_density = 1.25

	plane_02_tex_speed = Vector3(
		0.0,
		-0.58,
		0.52
	)

	plane_03_position = Vector3(
		-0.20,
		0.48,
		-0.08
	)

	plane_03_scale = Vector3(
		1.25,
		1.12,
		1.25
	)

	plane_03_color = Color("6C6963CC")
	plane_03_volume = 0.90
	plane_03_aperture = 0.25
	plane_03_density = 1.15

	plane_03_tex_speed = Vector3(
		0.0,
		-0.78,
		0.48
	)

	plane_04_position = Vector3(
		0.12,
		0.84,
		0.14
	)

	plane_04_scale = Vector3(
		1.00,
		1.42,
		1.00
	)

	plane_04_color = Color("7A766FB8")
	plane_04_volume = 0.82
	plane_04_aperture = 0.30
	plane_04_density = 1.00

	plane_04_tex_speed = Vector3(
		0.0,
		-0.48,
		0.68
	)


# ============================================================
# PRESET: ALIEN PURPLE LIGHT
# ============================================================

func _load_alien_purple_light() -> void:
	plane_01_position = Vector3(
		0.0,
		0.0,
		0.0
	)

	plane_01_scale = Vector3(
		0.70,
		0.75,
		0.70
	)

	plane_01_color = Color("8B63A866")
	plane_01_volume = 0.42
	plane_01_aperture = 0.42
	plane_01_density = 0.28

	plane_01_tex_speed = Vector3(
		0.08,
		-0.18,
		0.58
	)

	plane_02_position = Vector3(
		0.24,
		0.18,
		0.12
	)

	plane_02_scale = Vector3(
		0.65,
		0.95,
		0.65
	)

	plane_02_color = Color("9A72B85C")
	plane_02_volume = 0.38
	plane_02_aperture = 0.46
	plane_02_density = 0.24

	plane_02_tex_speed = Vector3(
		-0.08,
		-0.22,
		0.70
	)

	plane_03_position = Vector3(
		-0.22,
		0.38,
		-0.10
	)

	plane_03_scale = Vector3(
		0.90,
		0.78,
		0.90
	)

	plane_03_color = Color("AA82C44F")
	plane_03_volume = 0.34
	plane_03_aperture = 0.50
	plane_03_density = 0.20

	plane_03_tex_speed = Vector3(
		0.12,
		-0.16,
		0.48
	)

	plane_04_position = Vector3(
		0.10,
		0.64,
		0.15
	)

	plane_04_scale = Vector3(
		0.58,
		1.05,
		0.58
	)

	plane_04_color = Color("B99AD446")
	plane_04_volume = 0.30
	plane_04_aperture = 0.54
	plane_04_density = 0.16

	plane_04_tex_speed = Vector3(
		-0.10,
		-0.14,
		0.76
	)


# ============================================================
# PRESET: ALIEN PURPLE MIST
# ============================================================

func _load_alien_purple_mist() -> void:
	plane_01_position = Vector3(
		0.0,
		0.0,
		0.0
	)

	plane_01_scale = Vector3(
		1.20,
		0.55,
		1.20
	)

	plane_01_color = Color("75538F59")
	plane_01_volume = 0.44
	plane_01_aperture = 0.46
	plane_01_density = 0.24

	plane_01_tex_speed = Vector3(
		0.10,
		-0.10,
		0.52
	)

	plane_02_position = Vector3(
		0.35,
		0.08,
		0.20
	)

	plane_02_scale = Vector3(
		1.10,
		0.65,
		1.10
	)

	plane_02_color = Color("8965A355")
	plane_02_volume = 0.40
	plane_02_aperture = 0.50
	plane_02_density = 0.22

	plane_02_tex_speed = Vector3(
		-0.12,
		-0.12,
		0.62
	)

	plane_03_position = Vector3(
		-0.32,
		0.18,
		-0.18
	)

	plane_03_scale = Vector3(
		1.35,
		0.58,
		1.35
	)

	plane_03_color = Color("9C79B84C")
	plane_03_volume = 0.36
	plane_03_aperture = 0.54
	plane_03_density = 0.18

	plane_03_tex_speed = Vector3(
		0.15,
		-0.08,
		0.44
	)

	plane_04_position = Vector3(
		0.12,
		0.32,
		0.22
	)

	plane_04_scale = Vector3(
		0.95,
		0.80,
		0.95
	)

	plane_04_color = Color("B095C93F")
	plane_04_volume = 0.30
	plane_04_aperture = 0.58
	plane_04_density = 0.14

	plane_04_tex_speed = Vector3(
		-0.08,
		-0.08,
		0.70
	)


# ============================================================
# APPLICAZIONE MANUALE
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
		"SMOKE APPLICATO: ",
		plane_name
	)
