extends CanvasLayer

const HITMARKER_DURATION := 0.10

const BATTERY_SEGMENTS := 8
const BATTERY_SEGMENT_SIZE := 100.0 / BATTERY_SEGMENTS

const FACE_0 = preload(
	"res://assets/ui/hud/hud_face_0_v1.png"
)

const FACE_25 = preload(
	"res://assets/ui/hud/hud_face_25_v1.png"
)

const FACE_50 = preload(
	"res://assets/ui/hud/hud_face_50_v1.png"
)

const FACE_75 = preload(
	"res://assets/ui/hud/hud_face_75_v1.png"
)

const FACE_100 = preload(
	"res://assets/ui/hud/hud_face_100_v1.png"
)

const WEAPON_HANDS = preload(
	"res://assets/ui/hud/hud_hands.png"
)

const WEAPON_PISTOL = preload(
	"res://assets/ui/hud/hud_pistol.png"
)

const WEAPON_FLASHLIGHT = preload(
	"res://assets/ui/hud/hud_flashlight.png"
)

const WEAPON_SMG = preload(
	"res://assets/ui/hud/SMG_hud.png"
)


# ============================================================
# HUD
# ============================================================

@export_group("Damage Feedback")
@export_range(0.15, 2.0, 0.05) var damage_flash_duration := 0.65
@export_range(0.0, 1.0, 0.05) var damage_vignette_strength := 0.95
@export_range(0.0, 1.0, 0.05) var damage_center_wash := 0.20
@export_range(0.0, 2.0, 0.05) var damage_texture_strength := 1.15

@export_group("Boss HUD")
@export var boss_phase_1_texture: Texture2D = preload(
	"res://assets/ui/bruno_fase1.png"
)

@export var boss_phase_2_texture: Texture2D = preload(
	"res://assets/ui/bruno_fase2.png"
)

@export var boss_phase_3_texture: Texture2D = preload(
	"res://assets/ui/bruno_fase3.png"
)

# Colori dark dello shader blob della barra boss.
# Fase 1: verde organico scuro
@export var boss_phase_1_blob_color := Color(
	0.078431,
	0.168627,
	0.094118,
	1.0
)

@export var boss_phase_1_glow_color := Color(
	0.207843,
	0.431373,
	0.172549,
	1.0
)

# Fase 2: ambra/marrone scuro
@export var boss_phase_2_blob_color := Color(
	0.227451,
	0.164706,
	0.050980,
	1.0
)

@export var boss_phase_2_glow_color := Color(
	0.541176,
	0.396078,
	0.105882,
	1.0
)

# Fase 3: rosso cupo
@export var boss_phase_3_blob_color := Color(
	0.168627,
	0.039216,
	0.039216,
	1.0
)

@export var boss_phase_3_glow_color := Color(
	0.478431,
	0.117647,
	0.117647,
	1.0
)

@export_range(
	0.05,
	3.0,
	0.05
) var boss_phase_refill_duration: float = 0.75


@export_group("Damage Numbers")
@export_range(
	0.20,
	2.0,
	0.05
) var damage_number_duration: float = 0.75

@export_range(
	10.0,
	140.0,
	1.0
) var damage_number_rise: float = 52.0

@export_range(
	0.0,
	60.0,
	1.0
) var damage_number_spread: float = 18.0

@export_range(
	12,
	72,
	1
) var damage_number_font_size: int = 28

@export_range(
	12,
	84,
	1
) var critical_damage_number_font_size: int = 36

@export var damage_number_color := Color(
	0.90,
	0.86,
	0.72,
	1.0
)

@export var critical_damage_number_color := Color(
	0.92,
	0.42,
	0.14,
	1.0
)


# ============================================================
# NODI HUD
# ============================================================

@onready var crosshair_image: TextureRect = (
	$Interface/CrosshairImage
)

@onready var hit_marker_image: TextureRect = (
	$Interface/HitMarkerImage
)

@onready var damage_overlay_image: TextureRect = (
	$Interface/DamageOverlayImage
)

@onready var death_label: Label = (
	$Interface/DeathLabel
)

@onready var health_bar: ProgressBar = (
	$Interface/HudBar/HealthBar
)

@onready var health_value: Label = (
	$Interface/HudBar/HealthValue
)

@onready var face_portrait: TextureRect = (
	$Interface/HudBar/FacePortrait
)

@onready var weapon_icon: TextureRect = (
	$Interface/HudBar/WeaponIcon
)

@onready var bullet_row: Control = (
	$Interface/HudBar/BulletRow
)

@onready var smg_bullet_background: TextureRect = (
	$Interface/HudBar/SMG_bullet
)

@onready var smg_bullets: Control = (
	$Interface/HudBar/SMG_Bullets
)

@onready var ammo_value: Label = (
	$Interface/HudBar/AmmoValue
)

@onready var battery_bar: ProgressBar = (
	$Interface/HudBar/BatteryBar
)

@onready var mission_label: Label = (
	$Interface/HudBar/MissionLabel
)

@onready var boss_hud: Control = (
	$Interface/BossHud
)

@onready var boss_frame: TextureRect = (
	$Interface/BossHud/BossFrame
)

@onready var boss_health_bar: ProgressBar = (
	$Interface/BossHud/BossHealthBar
)

@onready var boss_health_value: Label = (
	$Interface/BossHud/BossHealthValue
)


var bullet_icons: Array[TextureRect] = []
var smg_bullet_icons: Array[TextureRect] = []

var current_weapon_name := "MANI NUDE"

var hitmarker_time_left := 0.0
var damage_flash_time_left := 0.0
var damage_vignette: ColorRect

var _damage_vignette_material: ShaderMaterial
var _boss_fill_style: StyleBoxFlat
var _boss_shader_material: ShaderMaterial
var _boss_refill_tween: Tween

var _boss_last_phase: int = 0
var _boss_display_phase_max: int = 1

var _damage_number_font: SystemFont


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	add_to_group("hud")

	hit_marker_image.visible = false
	damage_overlay_image.visible = false
	death_label.visible = false
	boss_hud.visible = false

	smg_bullet_background.visible = false
	smg_bullets.visible = false

	_setup_damage_vignette()
	_setup_boss_bar_style()
	_setup_damage_number_font()

	bullet_icons = [
		$Interface/HudBar/BulletRow/Bullet01,
		$Interface/HudBar/BulletRow/Bullet02,
		$Interface/HudBar/BulletRow/Bullet03,
		$Interface/HudBar/BulletRow/Bullet04,
		$Interface/HudBar/BulletRow/Bullet05,
		$Interface/HudBar/BulletRow/Bullet06,
		$Interface/HudBar/BulletRow/Bullet07,
		$Interface/HudBar/BulletRow/Bullet08,
		$Interface/HudBar/BulletRow/Bullet09
	]

	_setup_smg_bullet_icons()

	face_portrait.texture = FACE_100

	update_weapon("MANI NUDE")
	hide_ammo()
	hide_flashlight_battery()

	update_mission(
		"TROVA UNA VIA D'USCITA"
	)


func _setup_smg_bullet_icons() -> void:
	smg_bullet_icons.clear()

	for i: int in range(1, 31):
		var bullet_name := (
			"SMG_Bullet%d" % i
		)

		var bullet := (
			smg_bullets.get_node_or_null(
				bullet_name
			)
			as TextureRect
		)

		if bullet == null:
			push_error(
				"HUD: nodo SMG mancante: "
				+ bullet_name
			)
			continue

		smg_bullet_icons.append(
			bullet
		)


func _setup_damage_vignette() -> void:
	# The overlay lives inside Interface, behind the existing HUD and texture.
	# Nothing in hud.tscn or its original PNG is replaced.
	damage_vignette = ColorRect.new()
	damage_vignette.name = "DamageVignette"
	damage_vignette.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)
	damage_vignette.visible = false

	damage_vignette.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	var shader := Shader.new()

	shader.code = """
shader_type canvas_item;
render_mode unshaded;
uniform float intensity = 0.0;
uniform float center_wash = 0.20;
void fragment() {
    vec2 p = (UV - vec2(0.5)) * vec2(1.55, 1.0);
    float radial = length(p);
    float edge = smoothstep(0.17, 0.77, radial);
    float alpha = intensity * mix(center_wash, 0.89, edge);
    COLOR = vec4(0.83, 0.012, 0.018, alpha);
}
"""

	_damage_vignette_material = (
		ShaderMaterial.new()
	)

	_damage_vignette_material.shader = shader

	_damage_vignette_material.set_shader_parameter(
		"intensity",
		0.0
	)

	_damage_vignette_material.set_shader_parameter(
		"center_wash",
		damage_center_wash
	)

	damage_vignette.material = (
		_damage_vignette_material
	)

	$Interface.add_child(
		damage_vignette
	)

	$Interface.move_child(
		damage_vignette,
		0
	)

	damage_vignette.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)


func _setup_boss_bar_style() -> void:
	# Manteniamo una copia locale del fill come fallback.
	var existing_fill := (
		boss_health_bar.get_theme_stylebox(
			"fill"
		)
	)

	if existing_fill is StyleBoxFlat:
		_boss_fill_style = (
			existing_fill.duplicate()
			as StyleBoxFlat
		)

	else:
		_boss_fill_style = (
			StyleBoxFlat.new()
		)

	boss_health_bar.add_theme_stylebox_override(
		"fill",
		_boss_fill_style
	)

	# Se alla BossHealthBar è assegnato il nostro ShaderMaterial,
	# ne duplichiamo una copia locale così le modifiche di fase
	# riguardano solo questa barra.
	if (
		boss_health_bar.material
		is ShaderMaterial
	):
		_boss_shader_material = (
			boss_health_bar.material.duplicate()
			as ShaderMaterial
		)

		boss_health_bar.material = (
			_boss_shader_material
		)

	_set_boss_bar_colors(
		boss_phase_1_blob_color,
		boss_phase_1_glow_color
	)


# ============================================================
# PROCESS
# ============================================================

func _process(delta: float) -> void:
	if hitmarker_time_left > 0.0:
		hitmarker_time_left -= delta

		if hitmarker_time_left <= 0.0:
			hit_marker_image.visible = false

	if damage_flash_time_left > 0.0:
		damage_flash_time_left = maxf(
			damage_flash_time_left - delta,
			0.0
		)

		var fade := (
			damage_flash_time_left
			/ maxf(
				damage_flash_duration,
				0.01
			)
		)

		var intensity := (
			fade
			* fade
			* (
				3.0
				- 2.0
				* fade
			)
		)

		_set_damage_intensity(
			intensity
		)

	else:
		if (
			damage_vignette != null
			and damage_vignette.visible
		):
			_set_damage_intensity(
				0.0
			)


# ============================================================
# HITMARKER
# ============================================================

func show_hitmarker() -> void:
	hit_marker_image.visible = true

	hitmarker_time_left = (
		HITMARKER_DURATION
	)


# ============================================================
# DAMAGE NUMBERS
# ============================================================

func _setup_damage_number_font() -> void:
	_damage_number_font = (
		SystemFont.new()
	)

	_damage_number_font.font_names = (
		PackedStringArray([
			"Bebas Neue"
		])
	)


func show_damage_number(
	damage_amount: int,
	world_position: Vector3,
	critical: bool = false
) -> void:
	if damage_amount <= 0:
		return

	var camera := (
		get_viewport().get_camera_3d()
	)

	if camera == null:
		return

	if camera.is_position_behind(
		world_position
	):
		return

	var screen_position := (
		camera.unproject_position(
			world_position
		)
	)

	var label := Label.new()

	label.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	label.z_index = 200
	label.text = str(damage_amount)

	label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	label.custom_minimum_size = Vector2(
		96.0,
		54.0
	)

	label.size = Vector2(
		96.0,
		54.0
	)

	if _damage_number_font != null:
		label.add_theme_font_override(
			"font",
			_damage_number_font
		)

	var font_size := (
		damage_number_font_size
	)

	var font_color := (
		damage_number_color
	)

	var start_scale := Vector2(
		0.82,
		0.82
	)

	if critical:
		font_size = (
			critical_damage_number_font_size
		)

		font_color = (
			critical_damage_number_color
		)

		start_scale = Vector2(
			1.05,
			1.05
		)

	label.add_theme_font_size_override(
		"font_size",
		font_size
	)

	label.add_theme_color_override(
		"font_color",
		font_color
	)

	label.add_theme_color_override(
		"font_outline_color",
		Color(
			0.0,
			0.0,
			0.0,
			0.95
		)
	)

	label.add_theme_constant_override(
		"outline_size",
		3
	)

	$Interface.add_child(
		label
	)

	var random_offset := Vector2(
		randf_range(
			-damage_number_spread,
			damage_number_spread
		),
		randf_range(
			-damage_number_spread * 0.45,
			damage_number_spread * 0.20
		)
	)

	var start_position := (
		screen_position
		- label.size * 0.5
		+ random_offset
	)

	label.position = start_position
	label.pivot_offset = label.size * 0.5
	label.scale = start_scale

	var target_position := (
		start_position
		+ Vector2(
			randf_range(
				-8.0,
				8.0
			),
			-damage_number_rise
		)
	)

	var tween := create_tween()

	tween.set_parallel(true)

	tween.tween_property(
		label,
		"position",
		target_position,
		damage_number_duration
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_OUT
	)

	tween.tween_property(
		label,
		"modulate:a",
		0.0,
		damage_number_duration
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_IN
	)

	tween.tween_property(
		label,
		"scale",
		Vector2.ONE,
		minf(
			damage_number_duration
			* 0.30,
			0.22
		)
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_OUT
	)

	tween.finished.connect(
		label.queue_free
	)


# ============================================================
# DANNO
# ============================================================

func show_damage_flash() -> void:
	damage_flash_time_left = (
		damage_flash_duration
	)

	_set_damage_intensity(
		1.0
	)


func _set_damage_intensity(
	intensity: float
) -> void:
	var amount := clampf(
		intensity,
		0.0,
		1.0
	)

	if damage_vignette != null:
		damage_vignette.visible = (
			amount > 0.001
		)

		_damage_vignette_material.set_shader_parameter(
			"intensity",
			amount
			* damage_vignette_strength
		)

		_damage_vignette_material.set_shader_parameter(
			"center_wash",
			damage_center_wash
		)

	damage_overlay_image.visible = (
		amount > 0.001
	)

	damage_overlay_image.modulate = Color(
		1.0,
		0.55,
		0.55,
		clampf(
			amount
			* damage_texture_strength,
			0.0,
			1.0
		)
	)


# ============================================================
# SALUTE
# ============================================================

func update_health(
	current_health: int,
	max_health: int
) -> void:
	health_bar.max_value = max_health
	health_bar.value = current_health

	health_value.text = (
		str(current_health)
	)

	_update_face_from_health(
		current_health,
		max_health
	)


func _update_face_from_health(
	current_health: int,
	max_health: int
) -> void:
	if current_health <= 0:
		face_portrait.texture = FACE_0
		return

	if max_health <= 0:
		face_portrait.texture = FACE_0
		return

	var health_percent: float = (
		float(current_health)
		/ float(max_health)
		* 100.0
	)

	if health_percent <= 25.0:
		face_portrait.texture = FACE_25

	elif health_percent <= 50.0:
		face_portrait.texture = FACE_50

	elif health_percent <= 75.0:
		face_portrait.texture = FACE_75

	else:
		face_portrait.texture = FACE_100


# ============================================================
# BOSS HUD
# ============================================================

func show_boss_hud() -> void:
	boss_hud.visible = true


func update_boss_hud(
	current_phase_health: int,
	phase_max_health: int,
	phase: int
) -> void:
	show_boss_hud()

	var safe_phase_max := maxi(
		phase_max_health,
		1
	)

	var clamped_health := clampi(
		current_phase_health,
		0,
		safe_phase_max
	)

	boss_health_bar.min_value = 0.0
	boss_health_bar.max_value = safe_phase_max

	_boss_display_phase_max = (
		safe_phase_max
	)

	var safe_phase := clampi(
		phase,
		1,
		3
	)

	var phase_changed := (
		_boss_last_phase != 0
		and safe_phase
			!= _boss_last_phase
	)

	_set_boss_phase_visual(
		safe_phase
	)

	if phase_changed:
		_play_boss_phase_refill(
			clamped_health,
			safe_phase_max
		)

	else:
		_stop_boss_refill_tween()

		_set_boss_bar_display(
			float(
				clamped_health
			)
		)

	_boss_last_phase = safe_phase


func hide_boss_hud() -> void:
	boss_hud.visible = false

	_stop_boss_refill_tween()

	_boss_last_phase = 0


func _set_boss_phase_visual(
	phase: int
) -> void:
	match clampi(
		phase,
		1,
		3
	):
		1:
			boss_frame.texture = (
				boss_phase_1_texture
			)

			_set_boss_bar_colors(
				boss_phase_1_blob_color,
				boss_phase_1_glow_color
			)

		2:
			boss_frame.texture = (
				boss_phase_2_texture
			)

			_set_boss_bar_colors(
				boss_phase_2_blob_color,
				boss_phase_2_glow_color
			)

		3:
			boss_frame.texture = (
				boss_phase_3_texture
			)

			_set_boss_bar_colors(
				boss_phase_3_blob_color,
				boss_phase_3_glow_color
			)


func _set_boss_bar_colors(
	blob_color: Color,
	glow_color: Color
) -> void:
	if _boss_shader_material != null:
		_boss_shader_material.set_shader_parameter(
			"blob_color",
			blob_color
		)

		_boss_shader_material.set_shader_parameter(
			"glow_color",
			glow_color
		)

	if _boss_fill_style != null:
		_boss_fill_style.bg_color = (
			blob_color
		)


func _play_boss_phase_refill(
	target_health: int,
	phase_max_health: int
) -> void:
	_stop_boss_refill_tween()

	boss_health_bar.max_value = (
		phase_max_health
	)

	_boss_display_phase_max = (
		phase_max_health
	)

	_set_boss_bar_display(
		0.0
	)

	_boss_refill_tween = (
		create_tween()
	)

	_boss_refill_tween.set_trans(
		Tween.TRANS_SINE
	)

	_boss_refill_tween.set_ease(
		Tween.EASE_OUT
	)

	_boss_refill_tween.tween_method(
		_set_boss_bar_display,
		0.0,
		float(target_health),
		boss_phase_refill_duration
	)

	_boss_refill_tween.finished.connect(
		func() -> void:
			_boss_refill_tween = null
	)


func _stop_boss_refill_tween() -> void:
	if _boss_refill_tween != null:
		_boss_refill_tween.kill()
		_boss_refill_tween = null


func _set_boss_bar_display(
	display_health: float
) -> void:
	var clamped_value := clampf(
		display_health,
		0.0,
		float(
			_boss_display_phase_max
		)
	)

	boss_health_bar.value = (
		clamped_value
	)

	var display_int := clampi(
		roundi(
			clamped_value
		),
		0,
		_boss_display_phase_max
	)

	boss_health_value.text = (
		"%d / %d"
		% [
			display_int,
			_boss_display_phase_max
		]
	)


# ============================================================
# MUNIZIONI
# ============================================================

func update_ammo(
	magazine_ammo: int,
	reserve_ammo: int
) -> void:
	battery_bar.visible = false
	ammo_value.visible = true

	ammo_value.text = (
		"%d / %d"
		% [
			magazine_ammo,
			reserve_ammo
		]
	)

	if current_weapon_name == "SMG":
		bullet_row.visible = false

		smg_bullet_background.visible = true
		smg_bullets.visible = true

		_update_smg_bullet_icons(
			magazine_ammo
		)

		return

	smg_bullet_background.visible = false
	smg_bullets.visible = false

	bullet_row.visible = true

	_update_bullet_icons(
		magazine_ammo
	)


func _update_bullet_icons(
	magazine_ammo: int
) -> void:
	for i: int in range(
		bullet_icons.size()
	):
		bullet_icons[i].visible = (
			i < magazine_ammo
		)


func _update_smg_bullet_icons(
	magazine_ammo: int
) -> void:
	for i: int in range(
		smg_bullet_icons.size()
	):
		smg_bullet_icons[i].visible = (
			i < magazine_ammo
		)


func hide_ammo() -> void:
	ammo_value.visible = false

	bullet_row.visible = false

	smg_bullet_background.visible = false
	smg_bullets.visible = false


# ============================================================
# BATTERIA TORCIA
# ============================================================

func update_flashlight_battery(
	charge_percent: float
) -> void:
	var charge := clampf(
		charge_percent,
		0.0,
		100.0
	)

	var displayed_charge := 0.0

	if charge > 0.0:
		displayed_charge = (
			ceil(
				charge
				/ BATTERY_SEGMENT_SIZE
			)
			* BATTERY_SEGMENT_SIZE
		)

	displayed_charge = clampf(
		displayed_charge,
		0.0,
		100.0
	)

	bullet_row.visible = false

	smg_bullet_background.visible = false
	smg_bullets.visible = false

	battery_bar.visible = true
	ammo_value.visible = true

	battery_bar.value = (
		displayed_charge
	)

	ammo_value.text = (
		"%d%%"
		% roundi(charge)
	)


func hide_flashlight_battery() -> void:
	battery_bar.visible = false


# ============================================================
# ARMA / OGGETTO EQUIPAGGIATO
# ============================================================

func update_weapon(
	weapon_name: String
) -> void:
	current_weapon_name = weapon_name

	if weapon_name == "PISTOLA":
		weapon_icon.texture = (
			WEAPON_PISTOL
		)

		battery_bar.visible = false

		smg_bullet_background.visible = false
		smg_bullets.visible = false

		return

	if weapon_name == "SMG":
		weapon_icon.texture = (
			WEAPON_SMG
		)

		battery_bar.visible = false
		bullet_row.visible = false

		return

	if weapon_name == "TORCIA":
		weapon_icon.texture = (
			WEAPON_FLASHLIGHT
		)

		bullet_row.visible = false

		smg_bullet_background.visible = false
		smg_bullets.visible = false

		return

	weapon_icon.texture = (
		WEAPON_HANDS
	)

	battery_bar.visible = false

	smg_bullet_background.visible = false
	smg_bullets.visible = false


# ============================================================
# MISSIONE
# ============================================================

func update_mission(
	mission_text: String
) -> void:
	mission_label.text = (
		mission_text
	)


# ============================================================
# MORTE
# ============================================================

func show_death_screen() -> void:
	crosshair_image.visible = false
	hit_marker_image.visible = false
	damage_overlay_image.visible = false

	if damage_vignette != null:
		damage_vignette.visible = false

	damage_flash_time_left = 0.0

	death_label.visible = true

	face_portrait.texture = FACE_0
