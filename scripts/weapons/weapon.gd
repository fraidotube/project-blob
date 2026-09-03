extends Node3D


# ============================================================
# PROJECT BLOB - WEAPON CONTROLLER
# ============================================================


# ------------------------------------------------------------
# COMBATTIMENTO
# ------------------------------------------------------------

@export var pistol_damage := 1
@export var melee_damage := 1

@export var melee_range := 1.6
@export var melee_attack_cooldown := 0.45

@export var fire_rate := 4.0


# ------------------------------------------------------------
# MUNIZIONI PISTOLA
# ------------------------------------------------------------

@export var pistol_magazine_size := 12
@export var starting_reserve_ammo := 36

var magazine_ammo: int = 12
var reserve_ammo: int = 36


# ------------------------------------------------------------
# EFFETTI
# ------------------------------------------------------------

@export var muzzle_flash_duration := 0.05


# ------------------------------------------------------------
# NODI PLAYER
# ------------------------------------------------------------

@onready var weapon_ray: RayCast3D = (
	$"../WeaponRay"
)

@onready var muzzle_flash: OmniLight3D = (
	$MuzzleFlash
)


# ------------------------------------------------------------
# LOW WORLD VIEWMODEL
# ------------------------------------------------------------

@onready var lowworld_viewmodel: Node3D = (
	$LowWorldViewModel
)

@onready var arms_animation_player: AnimationPlayer = (
	$LowWorldViewModel
	/smesh_arms_male
	/AnimationPlayer
)

@onready var pistol_model: Node3D = (
	$LowWorldViewModel
	/smesh_arms_male
	/rig_arms
	/Skeleton3D
	/PistolSocket
	/smesh_pistol
)

@onready var pistol_animation_player: AnimationPlayer = (
	$LowWorldViewModel
	/smesh_arms_male
	/rig_arms
	/Skeleton3D
	/PistolSocket
	/smesh_pistol
	/AnimationPlayer
)


# ------------------------------------------------------------
# STATO ARMA
# ------------------------------------------------------------

var has_pistol := false

var can_attack := true
var is_reloading := false
var is_performing_action := false

var attack_cooldown_left := 0.0
var muzzle_flash_time_left := 0.0

var unarmed_attack_index := 1


# ------------------------------------------------------------
# STATO MOVIMENTO
# ------------------------------------------------------------

var player_is_moving := false
var player_is_sprinting := false

var current_locomotion_animation := ""


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	muzzle_flash.visible = false

	has_pistol = false
	pistol_model.visible = false

	magazine_ammo = pistol_magazine_size
	reserve_ammo = starting_reserve_ammo

	arms_animation_player.animation_finished.connect(
		_on_arms_animation_finished
	)

	play_current_locomotion(true)


# ============================================================
# PROCESS
# ============================================================

func _process(delta: float) -> void:
	if not can_attack:
		attack_cooldown_left -= delta

		if attack_cooldown_left <= 0.0:
			attack_cooldown_left = 0.0
			can_attack = true

	if muzzle_flash_time_left > 0.0:
		muzzle_flash_time_left -= delta

		if muzzle_flash_time_left <= 0.0:
			muzzle_flash_time_left = 0.0
			muzzle_flash.visible = false


# ============================================================
# MOVIMENTO
# ============================================================

func set_movement_state(
	is_moving: bool,
	is_sprinting: bool
) -> void:
	var changed := (
		player_is_moving != is_moving
		or player_is_sprinting != is_sprinting
	)

	player_is_moving = is_moving
	player_is_sprinting = is_sprinting

	if not changed:
		return

	play_current_locomotion()


func play_current_locomotion(
	force: bool = false
) -> void:
	if is_performing_action:
		return

	if is_reloading:
		return

	var animation_name := ""

	if has_pistol:
		if not player_is_moving:
			animation_name = "a_arms_pistol_idle"
		elif player_is_sprinting:
			animation_name = "a_arms_pistol_run"
		else:
			animation_name = "a_arms_pistol_walk"
	else:
		if not player_is_moving:
			animation_name = "a_arms_unarmed_idle"
		elif player_is_sprinting:
			animation_name = "a_arms_unarmed_run"
		else:
			animation_name = "a_arms_unarmed_walk"

	if (
		not force
		and current_locomotion_animation == animation_name
		and arms_animation_player.is_playing()
	):
		return

	if not arms_animation_player.has_animation(
		animation_name
	):
		push_error(
			"Animazione locomotion non trovata: "
			+ animation_name
		)
		return

	current_locomotion_animation = animation_name

	arms_animation_player.play(
		animation_name,
		0.15
	)


func _on_arms_animation_finished(
	animation_name: StringName
) -> void:
	if is_performing_action:
		return

	if is_reloading:
		return

	if String(animation_name) != current_locomotion_animation:
		return

	play_current_locomotion(true)


# ============================================================
# ATTACCO
# ============================================================

func fire() -> void:
	if not can_attack:
		return

	if is_reloading:
		return

	if is_performing_action:
		return

	if has_pistol:
		fire_pistol()
	else:
		attack_unarmed()


# ============================================================
# MANI NUDE
# ============================================================

func attack_unarmed() -> void:
	can_attack = false
	is_performing_action = true

	attack_cooldown_left = melee_attack_cooldown

	var animation_name := (
		"a_arms_unarmed_attack%d"
		% unarmed_attack_index
	)

	if not arms_animation_player.has_animation(
		animation_name
	):
		push_error(
			"Animazione unarmed non trovata: "
			+ animation_name
		)

		is_performing_action = false
		return

	current_locomotion_animation = ""

	arms_animation_player.play(
		animation_name,
		0.08
	)

	unarmed_attack_index += 1

	if unarmed_attack_index > 4:
		unarmed_attack_index = 1

	perform_melee_hit()

	await arms_animation_player.animation_finished

	is_performing_action = false

	play_current_locomotion(true)


func perform_melee_hit() -> void:
	weapon_ray.force_raycast_update()

	if not weapon_ray.is_colliding():
		return

	var collider := weapon_ray.get_collider()
	var hit_point := weapon_ray.get_collision_point()

	var distance_to_hit := (
		weapon_ray.global_position.distance_to(
			hit_point
		)
	)

	if distance_to_hit > melee_range:
		return

	if collider == null:
		return

	if collider.has_method("take_damage"):
		collider.take_damage(
			melee_damage
		)

		get_tree().call_group(
			"hud",
			"show_hitmarker"
		)


# ============================================================
# PISTOLA - SPARO
# ============================================================

func fire_pistol() -> void:
	if magazine_ammo <= 0:
		return

	magazine_ammo -= 1
	update_ammo_hud()

	can_attack = false
	is_performing_action = true

	attack_cooldown_left = (
		1.0 / fire_rate
	)

	current_locomotion_animation = ""

	if arms_animation_player.has_animation(
		"a_arms_pistol_attack1"
	):
		arms_animation_player.play(
			"a_arms_pistol_attack1",
			0.05
		)

	if pistol_animation_player.has_animation(
		"pistol_shoot"
	):
		pistol_animation_player.play(
			"pistol_shoot"
		)

	show_muzzle_flash()

	weapon_ray.force_raycast_update()

	if weapon_ray.is_colliding():
		var collider := weapon_ray.get_collider()

		if (
			collider != null
			and collider.has_method("take_damage")
		):
			collider.take_damage(
				pistol_damage
			)

			get_tree().call_group(
				"hud",
				"show_hitmarker"
			)

	await arms_animation_player.animation_finished

	is_performing_action = false

	play_current_locomotion(true)


# ============================================================
# RELOAD
# ============================================================

func reload() -> void:
	if not has_pistol:
		return

	if is_reloading:
		return

	if is_performing_action:
		return

	if magazine_ammo >= pistol_magazine_size:
		return

	if reserve_ammo <= 0:
		return

	is_reloading = true
	is_performing_action = true
	can_attack = false

	current_locomotion_animation = ""

	if arms_animation_player.has_animation(
		"a_arms_pistol_reload"
	):
		arms_animation_player.play(
			"a_arms_pistol_reload",
			0.08
		)

	if pistol_animation_player.has_animation(
		"pistol_reload"
	):
		pistol_animation_player.play(
			"pistol_reload"
		)

	await arms_animation_player.animation_finished

	var ammo_needed: int = (
		pistol_magazine_size - magazine_ammo
	)

	var ammo_to_load: int = mini(
		ammo_needed,
		reserve_ammo
	)

	magazine_ammo += ammo_to_load
	reserve_ammo -= ammo_to_load

	update_ammo_hud()

	is_reloading = false
	is_performing_action = false
	can_attack = true

	play_current_locomotion(true)


# ============================================================
# EQUIP PISTOLA
# ============================================================

func equip_pistol() -> void:
	if has_pistol:
		return

	is_performing_action = true

	has_pistol = true
	pistol_model.visible = true

	current_locomotion_animation = ""

	get_tree().call_group(
		"hud",
		"update_weapon",
		"PISTOLA"
	)

	update_ammo_hud()

	if arms_animation_player.has_animation(
		"a_arms_pistol_start"
	):
		arms_animation_player.play(
			"a_arms_pistol_start",
			0.08
		)

		await arms_animation_player.animation_finished

	is_performing_action = false

	play_current_locomotion(true)


# ============================================================
# PICKUP MUNIZIONI
# ============================================================

func add_ammo(amount: int) -> void:
	if amount <= 0:
		return

	reserve_ammo += amount

	if has_pistol:
		update_ammo_hud()


func update_ammo_hud() -> void:
	get_tree().call_group(
		"hud",
		"update_ammo",
		magazine_ammo,
		reserve_ammo
	)


# ============================================================
# MUZZLE FLASH
# ============================================================

func show_muzzle_flash() -> void:
	muzzle_flash.visible = true
	muzzle_flash_time_left = muzzle_flash_duration
