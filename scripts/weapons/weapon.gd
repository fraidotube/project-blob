extends Node3D

# ============================================================
# PROJECT BLOB - WEAPON CONTROLLER
# Baseline Low World
# Stati attuali:
#   - UNARMED
#   - PISTOL
# ============================================================


# ----------------------------
# COMBATTIMENTO
# ----------------------------

@export var pistol_damage := 1
@export var melee_damage := 1

@export var melee_range := 1.6
@export var melee_attack_cooldown := 0.45

@export var fire_rate := 4.0


# ----------------------------
# EFFETTI
# ----------------------------

@export var muzzle_flash_duration := 0.05


# ----------------------------
# NODI PLAYER
# ----------------------------

@onready var weapon_ray: RayCast3D = $"../WeaponRay"
@onready var muzzle_flash: OmniLight3D = $MuzzleFlash


# ----------------------------
# LOW WORLD VIEWMODEL
# ----------------------------

@onready var lowworld_viewmodel: Node3D = $LowWorldViewModel

@onready var arms_animation_player: AnimationPlayer = (
	$LowWorldViewModel/smesh_arms_male/AnimationPlayer
)

@onready var pistol_model: Node3D = (
	$LowWorldViewModel/smesh_arms_male/rig_arms/Skeleton3D/PistolSocket/smesh_pistol
)

@onready var pistol_animation_player: AnimationPlayer = (
	$LowWorldViewModel/smesh_arms_male/rig_arms/Skeleton3D/PistolSocket/smesh_pistol/AnimationPlayer
)


# ----------------------------
# STATO
# ----------------------------

var has_pistol := false

var can_attack := true
var is_reloading := false

var attack_cooldown_left := 0.0
var muzzle_flash_time_left := 0.0

var unarmed_attack_index := 1


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	muzzle_flash.visible = false

	# Il giocatore nasce senza pistola.
	has_pistol = false
	pistol_model.visible = false

	play_unarmed_idle()


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
# ATTACCO GENERALE
# ============================================================

func fire() -> void:
	if not can_attack:
		return

	if is_reloading:
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
	attack_cooldown_left = melee_attack_cooldown

	var animation_name := (
		"a_arms_unarmed_attack%d" % unarmed_attack_index
	)

	if arms_animation_player.has_animation(animation_name):
		arms_animation_player.play(animation_name)
	else:
		push_error(
			"Animazione unarmed non trovata: " + animation_name
		)

	# Ciclo dei quattro attacchi disponibili nel pack.
	unarmed_attack_index += 1

	if unarmed_attack_index > 4:
		unarmed_attack_index = 1

	perform_melee_hit()

	await arms_animation_player.animation_finished

	# Se nel frattempo non abbiamo equipaggiato la pistola,
	# torniamo alla posa idle unarmed.
	if not has_pistol:
		play_unarmed_idle()


func perform_melee_hit() -> void:
	weapon_ray.force_raycast_update()

	if not weapon_ray.is_colliding():
		return

	var collider := weapon_ray.get_collider()
	var hit_point := weapon_ray.get_collision_point()

	var distance_to_hit := (
		weapon_ray.global_position.distance_to(hit_point)
	)

	# Il RayCast può colpire oggetti lontani.
	# Il pugno invece deve funzionare solo a distanza melee.
	if distance_to_hit > melee_range:
		return

	if collider == null:
		return

	if collider.has_method("take_damage"):
		collider.take_damage(melee_damage)
		get_tree().call_group("hud", "show_hitmarker")


# ============================================================
# PISTOLA
# ============================================================

func fire_pistol() -> void:
	can_attack = false
	attack_cooldown_left = 1.0 / fire_rate

	# Animazione braccia.
	if arms_animation_player.has_animation(
		"a_arms_pistol_attack1"
	):
		arms_animation_player.play(
			"a_arms_pistol_attack1"
		)

	# Animazione meccanica della pistola.
	if pistol_animation_player.has_animation(
		"pistol_shoot"
	):
		pistol_animation_player.play(
			"pistol_shoot"
		)

	show_muzzle_flash()

	weapon_ray.force_raycast_update()

	if not weapon_ray.is_colliding():
		return

	var collider := weapon_ray.get_collider()

	if collider == null:
		return

	if collider.has_method("take_damage"):
		collider.take_damage(pistol_damage)
		get_tree().call_group("hud", "show_hitmarker")


# ============================================================
# RELOAD
# ============================================================

func reload() -> void:
	if not has_pistol:
		return

	if is_reloading:
		return

	is_reloading = true
	can_attack = false

	if arms_animation_player.has_animation(
		"a_arms_pistol_reload"
	):
		arms_animation_player.play(
			"a_arms_pistol_reload"
		)

	if pistol_animation_player.has_animation(
		"pistol_reload"
	):
		pistol_animation_player.play(
			"pistol_reload"
		)

	await arms_animation_player.animation_finished

	is_reloading = false
	can_attack = true

	play_pistol_idle()


# ============================================================
# EQUIP PISTOLA
# ============================================================

func equip_pistol() -> void:
	if has_pistol:
		return

	has_pistol = true
	pistol_model.visible = true

	if arms_animation_player.has_animation(
		"a_arms_pistol_start"
	):
		arms_animation_player.play(
			"a_arms_pistol_start"
		)

		await arms_animation_player.animation_finished

	play_pistol_idle()


# ============================================================
# ANIMAZIONI IDLE
# ============================================================

func play_unarmed_idle() -> void:
	if arms_animation_player.has_animation(
		"a_arms_unarmed_idle"
	):
		arms_animation_player.play(
			"a_arms_unarmed_idle"
		)
	else:
		push_error(
			"Animazione a_arms_unarmed_idle non trovata"
		)


func play_pistol_idle() -> void:
	if arms_animation_player.has_animation(
		"a_arms_pistol_idle"
	):
		arms_animation_player.play(
			"a_arms_pistol_idle"
		)


# ============================================================
# MUZZLE FLASH
# ============================================================

func show_muzzle_flash() -> void:
	muzzle_flash.visible = true
	muzzle_flash_time_left = muzzle_flash_duration
