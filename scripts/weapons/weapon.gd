extends Node3D

@export var damage := 1
@export var fire_rate := 4.0
@export var recoil_distance := 0.08
@export var recoil_return_speed := 12.0
@export var muzzle_flash_duration := 0.05

@onready var weapon_ray: RayCast3D = $"../WeaponRay"
@onready var muzzle_flash: OmniLight3D = $MuzzleFlash

var can_fire := true
var cooldown_time := 0.0
var muzzle_flash_time_left := 0.0
var original_position: Vector3


func _ready() -> void:
	original_position = position
	muzzle_flash.visible = false


func _process(delta: float) -> void:
	if not can_fire:
		cooldown_time -= delta

		if cooldown_time <= 0.0:
			can_fire = true

	if muzzle_flash_time_left > 0.0:
		muzzle_flash_time_left -= delta

		if muzzle_flash_time_left <= 0.0:
			muzzle_flash.visible = false

	position = position.lerp(
		original_position,
		recoil_return_speed * delta
	)


func fire() -> void:
	if not can_fire:
		return

	can_fire = false
	cooldown_time = 1.0 / fire_rate

	show_muzzle_flash()

	weapon_ray.force_raycast_update()

	if weapon_ray.is_colliding():
		var collider := weapon_ray.get_collider()

		if collider != null and collider.has_method("take_damage"):
			collider.take_damage(damage)
			get_tree().call_group("hud", "show_hitmarker")

	apply_recoil()


func apply_recoil() -> void:
	position.z += recoil_distance


func show_muzzle_flash() -> void:
	muzzle_flash.visible = true
	muzzle_flash_time_left = muzzle_flash_duration
