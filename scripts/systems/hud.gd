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


# ============================================================
# HUD
# ============================================================

@export_group("Damage Feedback")
@export_range(0.15, 2.0, 0.05) var damage_flash_duration := 0.65
@export_range(0.0, 1.0, 0.05) var damage_vignette_strength := 0.95
@export_range(0.0, 1.0, 0.05) var damage_center_wash := 0.20
@export_range(0.0, 2.0, 0.05) var damage_texture_strength := 1.15

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

@onready var ammo_value: Label = (
	$Interface/HudBar/AmmoValue
)

@onready var battery_bar: ProgressBar = (
	$Interface/HudBar/BatteryBar
)

@onready var mission_label: Label = (
	$Interface/HudBar/MissionLabel
)


var bullet_icons: Array[TextureRect] = []

var hitmarker_time_left := 0.0
var damage_flash_time_left := 0.0
var damage_vignette: ColorRect
var _damage_vignette_material: ShaderMaterial


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	add_to_group("hud")

	hit_marker_image.visible = false
	damage_overlay_image.visible = false
	death_label.visible = false

	_setup_damage_vignette()

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

	face_portrait.texture = FACE_100

	update_weapon("MANI NUDE")
	hide_ammo()
	hide_flashlight_battery()

	update_mission("TROVA UNA VIA D'USCITA")


func _setup_damage_vignette() -> void:
	# The overlay lives inside Interface, *behind* the existing HUD and texture.
	# Nothing in hud.tscn or its original PNG is replaced.
	damage_vignette = ColorRect.new()
	damage_vignette.name = "DamageVignette"
	damage_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	damage_vignette.visible = false
	damage_vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

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
	_damage_vignette_material = ShaderMaterial.new()
	_damage_vignette_material.shader = shader
	_damage_vignette_material.set_shader_parameter("intensity", 0.0)
	_damage_vignette_material.set_shader_parameter(
		"center_wash", damage_center_wash
	)
	damage_vignette.material = _damage_vignette_material
	$Interface.add_child(damage_vignette)
	$Interface.move_child(damage_vignette, 0)
	damage_vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


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
			damage_flash_time_left - delta, 0.0
		)

		var fade := damage_flash_time_left / maxf(damage_flash_duration, 0.01)
		# A brief strong peak followed by a smoother, visible fade.
		var intensity := fade * fade * (3.0 - 2.0 * fade)
		_set_damage_intensity(intensity)
	else:
		if damage_vignette != null and damage_vignette.visible:
			_set_damage_intensity(0.0)


# ============================================================
# HITMARKER
# ============================================================

func show_hitmarker() -> void:
	hit_marker_image.visible = true
	hitmarker_time_left = HITMARKER_DURATION


# ============================================================
# DANNO
# ============================================================

func show_damage_flash() -> void:
	# Called by Player.take_damage(), as in the original implementation.
	# Multiple consecutive hits restart the flash rather than creating tweens.
	damage_flash_time_left = damage_flash_duration
	_set_damage_intensity(1.0)


func _set_damage_intensity(intensity: float) -> void:
	var amount := clampf(intensity, 0.0, 1.0)
	if damage_vignette != null:
		damage_vignette.visible = amount > 0.001
		_damage_vignette_material.set_shader_parameter(
			"intensity", amount * damage_vignette_strength
		)
		_damage_vignette_material.set_shader_parameter(
			"center_wash", damage_center_wash
		)
	damage_overlay_image.visible = amount > 0.001
	damage_overlay_image.modulate = Color(
		1.0, 0.55, 0.55,
		clampf(amount * damage_texture_strength, 0.0, 1.0)
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

	health_value.text = str(current_health)

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
# MUNIZIONI
# ============================================================

func update_ammo(
	magazine_ammo: int,
	reserve_ammo: int
) -> void:
	battery_bar.visible = false
	ammo_value.visible = true
	bullet_row.visible = true

	ammo_value.text = (
		"%d / %d"
		% [
			magazine_ammo,
			reserve_ammo
		]
	)

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


func hide_ammo() -> void:
	ammo_value.visible = false
	bullet_row.visible = false


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
				charge / BATTERY_SEGMENT_SIZE
			)
			* BATTERY_SEGMENT_SIZE
		)

	displayed_charge = clampf(
		displayed_charge,
		0.0,
		100.0
	)

	bullet_row.visible = false
	battery_bar.visible = true
	ammo_value.visible = true

	battery_bar.value = displayed_charge

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
	if weapon_name == "PISTOLA":
		weapon_icon.texture = WEAPON_PISTOL
		battery_bar.visible = false
		return

	if weapon_name == "TORCIA":
		weapon_icon.texture = WEAPON_FLASHLIGHT
		bullet_row.visible = false
		return

	weapon_icon.texture = WEAPON_HANDS
	battery_bar.visible = false


# ============================================================
# MISSIONE
# ============================================================

func update_mission(
	mission_text: String
) -> void:
	mission_label.text = mission_text


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
