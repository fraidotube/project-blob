extends CanvasLayer

const HITMARKER_DURATION := 0.10
const DAMAGE_FLASH_DURATION := 0.12

@onready var crosshair: Label = $Interface/Crosshair
@onready var hit_marker: Label = $Interface/HitMarker
@onready var health_label: Label = $Interface/HealthLabel
@onready var death_label: Label = $Interface/DeathLabel
@onready var damage_flash: ColorRect = $Interface/DamageFlash

var hitmarker_time_left := 0.0
var damage_flash_time_left := 0.0


func _ready() -> void:
	add_to_group("hud")
	hit_marker.visible = false
	death_label.visible = false
	damage_flash.visible = false


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


func update_health(current_health: int, max_health: int) -> void:
	health_label.text = "HP: %d / %d" % [current_health, max_health]


func show_death_screen() -> void:
	crosshair.visible = false
	death_label.visible = true
	damage_flash.visible = false
