extends CanvasLayer

const HITMARKER_DURATION := 0.10
const DAMAGE_FLASH_DURATION := 0.12

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


@onready var crosshair: Label = $Interface/Crosshair
@onready var hit_marker: Label = $Interface/HitMarker

# Vecchia HUD - mantenuta durante la migrazione
@onready var health_label: Label = $Interface/HealthLabel
@onready var ammo_label: Label = $Interface/AmmoLabel
@onready var weapon_label: Label = $Interface/WeaponLabel

@onready var death_label: Label = $Interface/DeathLabel
@onready var damage_flash: ColorRect = $Interface/DamageFlash

# Nuova HUD
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

@onready var mission_label: Label = (
	$Interface/HudBar/MissionLabel
)


var bullet_icons: Array[TextureRect] = []

var hitmarker_time_left := 0.0
var damage_flash_time_left := 0.0


func _ready() -> void:
	add_to_group("hud")

	hit_marker.visible = false
	death_label.visible = false
	damage_flash.visible = false

	# Vecchi elementi ormai sostituiti.
	health_label.visible = false
	weapon_label.visible = false
	ammo_label.visible = false

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

	update_mission("TROVA UNA VIA D'USCITA")


func _process(delta: float) -> void:
	if hitmarker_time_left > 0.0:
		hitmarker_time_left -= delta

		if hitmarker_time_left <= 0.0:
			hit_marker.visible = false

	if damage_flash_time_left > 0.0:
		damage_flash_time_left -= delta

		if damage_flash_time_left <= 0.0:
			damage_flash.visible = false


func show_hitmarker() -> void:
	hit_marker.visible = true
	hitmarker_time_left = HITMARKER_DURATION


func show_damage_flash() -> void:
	damage_flash.visible = true
	damage_flash_time_left = DAMAGE_FLASH_DURATION


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


func update_ammo(
	magazine_ammo: int,
	reserve_ammo: int
) -> void:
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


func update_weapon(
	weapon_name: String
) -> void:
	if weapon_name == "PISTOLA":
		weapon_icon.texture = WEAPON_PISTOL
		return

	weapon_icon.texture = WEAPON_HANDS


func update_mission(
	mission_text: String
) -> void:
	mission_label.text = mission_text


func show_death_screen() -> void:
	crosshair.visible = false
	death_label.visible = true
	damage_flash.visible = false

	face_portrait.texture = FACE_0
