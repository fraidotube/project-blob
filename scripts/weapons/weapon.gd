extends Node3D


# ============================================================
# PROJECT BLOB - WEAPON CONTROLLER
# ============================================================


# ------------------------------------------------------------
# TIPI ARMA
# ------------------------------------------------------------

const WEAPON_UNARMED := 0
const WEAPON_PISTOL := 1
const WEAPON_FLASHLIGHT := 2


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

@export var pistol_magazine_size := 9
@export var starting_reserve_ammo := 36

var magazine_ammo: int = 9
var reserve_ammo: int = 36


# ------------------------------------------------------------
# TORCIA / BATTERIE
# ------------------------------------------------------------

@export var flashlight_drain_per_second := 2.0
@export var starting_spare_batteries := 0
@export var max_spare_batteries := 5

var flashlight_charge := 100.0
var flashlight_on := false
var spare_batteries := 0


# ------------------------------------------------------------
# ANIMAZIONI
# ------------------------------------------------------------

@export var reload_animation_speed := 1.25


# ------------------------------------------------------------
# EFFETTI
# ------------------------------------------------------------

@export var muzzle_flash_duration := 0.05

@export var bullet_impact_scene: PackedScene = preload(
	"res://scenes/effects/bullet_impact.tscn"
)

@export var bullet_impact_offset := 0.01


# ------------------------------------------------------------
# ANTI-CLIPPING VIEWMODEL
# ------------------------------------------------------------

@export var wall_pushback := 0.55
@export var wall_drop := 0.20
@export var wall_move_speed := 14.0

var viewmodel_base_position: Vector3


# ------------------------------------------------------------
# NODI PLAYER
# ------------------------------------------------------------

@onready var weapon_ray: RayCast3D = (
	$"../WeaponRay"
)

@onready var viewmodel_wall_cast: ShapeCast3D = (
	$"../ViewmodelWallCast"
)

@onready var muzzle_flash: OmniLight3D = (
	$MuzzleFlash
)


# ------------------------------------------------------------
# AUDIO PISTOLA
# ------------------------------------------------------------

@onready var shot_audio: AudioStreamPlayer = (
	$ShotAudio
)

@onready var empty_audio: AudioStreamPlayer = (
	$EmptyAudio
)

@onready var reload_audio: AudioStreamPlayer = (
	$ReloadAudio
)

@onready var ready_audio: AudioStreamPlayer = (
	$ReadyAudio
)

@onready var shell_casing_audio: AudioStreamPlayer = (
	$ShellCasingAudio
)

@onready var shell_casing_timer: Timer = (
	$ShellCasingTimer
)


# ------------------------------------------------------------
# AUDIO TORCIA
# ------------------------------------------------------------

@onready var flashlight_click_audio: AudioStreamPlayer = (
	$FlashlightClickAudio
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

@onready var flashlight_model: Node3D = (
	$LowWorldViewModel
	/smesh_arms_male
	/rig_arms
	/Skeleton3D
	/FlashlightSocket
	/Flashlight
)

@onready var flashlight_light: SpotLight3D = (
	$"../FlashlightBeam"
)


# ------------------------------------------------------------
# STATO INVENTARIO / ARMA EQUIPAGGIATA
# ------------------------------------------------------------

var owns_pistol := false
var owns_flashlight := false

var equipped_weapon := WEAPON_UNARMED

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

	# Il raycast non deve mai colpire il CharacterBody3D che lo possiede.
	var player_body := get_node("../../..") as CollisionObject3D
	if player_body == null:
		push_error("WeaponRay: Player non trovato; verificare gerarchia WeaponHolder")
	else:
		weapon_ray.add_exception(player_body)

	owns_pistol = false
	owns_flashlight = false

	equipped_weapon = WEAPON_UNARMED

	pistol_model.visible = false
	flashlight_model.visible = false
	flashlight_light.visible = false

	flashlight_on = false
	flashlight_charge = 100.0
	spare_batteries = clampi(
		starting_spare_batteries,
		0,
		max_spare_batteries
	)

	magazine_ammo = pistol_magazine_size
	reserve_ammo = starting_reserve_ammo

	viewmodel_base_position = position

	arms_animation_player.animation_finished.connect(
		_on_arms_animation_finished
	)

	shell_casing_timer.timeout.connect(
		_on_shell_casing_timer_timeout
	)

	get_tree().call_group(
		"hud",
		"update_weapon",
		"MANI NUDE"
	)

	get_tree().call_group(
		"hud",
		"hide_ammo"
	)

	get_tree().call_group(
		"hud",
		"hide_flashlight_battery"
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

	_update_flashlight_battery(delta)


func _physics_process(delta: float) -> void:
	update_viewmodel_wall_push(delta)


# ============================================================
# BATTERIA TORCIA
# ============================================================

func _update_flashlight_battery(delta: float) -> void:
	if not flashlight_on:
		return

	if flashlight_charge <= 0.0:
		_deplete_flashlight_battery()
		return

	flashlight_charge -= (
		flashlight_drain_per_second * delta
	)

	flashlight_charge = clampf(
		flashlight_charge,
		0.0,
		100.0
	)

	if is_flashlight_equipped():
		update_flashlight_battery_hud()

	if flashlight_charge <= 0.0:
		_deplete_flashlight_battery()


func _deplete_flashlight_battery() -> void:
	flashlight_charge = 0.0
	flashlight_on = false
	flashlight_light.visible = false

	if is_flashlight_equipped():
		update_flashlight_battery_hud()


func update_flashlight_battery_hud() -> void:
	get_tree().call_group(
		"hud",
		"update_flashlight_battery",
		flashlight_charge
	)


func add_flashlight_battery(
	amount: int = 1
) -> bool:
	if amount <= 0:
		return false

	if spare_batteries >= max_spare_batteries:
		return false

	var previous_amount := spare_batteries

	spare_batteries = mini(
		spare_batteries + amount,
		max_spare_batteries
	)

	return spare_batteries > previous_amount


func reload_flashlight_battery() -> void:
	if not owns_flashlight:
		return

	if not is_flashlight_equipped():
		return

	if flashlight_charge >= 100.0:
		return

	if spare_batteries <= 0:
		return

	spare_batteries -= 1
	flashlight_charge = 100.0

	update_flashlight_battery_hud()


# ============================================================
# ANTI-CLIPPING VIEWMODEL
# ============================================================

func update_viewmodel_wall_push(
	delta: float
) -> void:
	var target_position: Vector3 = (
		viewmodel_base_position
	)

	viewmodel_wall_cast.force_shapecast_update()

	if viewmodel_wall_cast.is_colliding():
		var safe_fraction: float = (
			viewmodel_wall_cast
			.get_closest_collision_safe_fraction()
		)

		var proximity: float = (
			1.0 - safe_fraction
		)

		proximity = clampf(
			proximity,
			0.0,
			1.0
		)

		target_position += Vector3(
			0.0,
			-wall_drop * proximity,
			wall_pushback * proximity
		)

	var interpolation: float = clampf(
		wall_move_speed * delta,
		0.0,
		1.0
	)

	position = position.lerp(
		target_position,
		interpolation
	)


# ============================================================
# STATO ARMA
# ============================================================

func is_pistol_equipped() -> bool:
	return equipped_weapon == WEAPON_PISTOL


func is_flashlight_equipped() -> bool:
	return equipped_weapon == WEAPON_FLASHLIGHT


# ============================================================
# SELEZIONE SLOT
# ============================================================

func select_weapon_slot(slot: int) -> void:
	if slot == 1:
		equip_unarmed()
		return

	if slot == 2:
		equip_owned_pistol()
		return

	if slot == 3:
		equip_owned_flashlight()
		return


# ============================================================
# MANI NUDE
# ============================================================

func equip_unarmed() -> void:
	if equipped_weapon == WEAPON_UNARMED:
		return

	if is_reloading:
		return

	if is_performing_action:
		return

	is_performing_action = true
	current_locomotion_animation = ""

	equipped_weapon = WEAPON_UNARMED

	pistol_model.visible = false
	flashlight_model.visible = false

	flashlight_on = false
	flashlight_light.visible = false

	get_tree().call_group(
		"hud",
		"update_weapon",
		"MANI NUDE"
	)

	get_tree().call_group(
		"hud",
		"hide_ammo"
	)

	get_tree().call_group(
		"hud",
		"hide_flashlight_battery"
	)

	if arms_animation_player.has_animation(
		"a_arms_unarmed_start"
	):
		arms_animation_player.play(
			"a_arms_unarmed_start",
			0.08
		)

		await arms_animation_player.animation_finished

	is_performing_action = false

	play_current_locomotion(true)


# ============================================================
# PISTOLA - PICKUP
# ============================================================

func equip_pistol() -> void:
	owns_pistol = true

	await equip_owned_pistol()


# ============================================================
# PISTOLA - EQUIP
# ============================================================

func equip_owned_pistol() -> void:
	if not owns_pistol:
		return

	if equipped_weapon == WEAPON_PISTOL:
		return

	if is_reloading:
		return

	if is_performing_action:
		return

	is_performing_action = true
	current_locomotion_animation = ""

	equipped_weapon = WEAPON_PISTOL

	pistol_model.visible = true
	flashlight_model.visible = false

	flashlight_on = false
	flashlight_light.visible = false

	get_tree().call_group(
		"hud",
		"update_weapon",
		"PISTOLA"
	)

	get_tree().call_group(
		"hud",
		"hide_flashlight_battery"
	)

	update_ammo_hud()

	if ready_audio.stream != null:
		ready_audio.play()

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
# TORCIA - PICKUP
# ============================================================

func equip_flashlight() -> void:
	owns_flashlight = true

	await equip_owned_flashlight()


# ============================================================
# TORCIA - EQUIP
# ============================================================

func equip_owned_flashlight() -> void:
	if not owns_flashlight:
		return

	if equipped_weapon == WEAPON_FLASHLIGHT:
		return

	if is_reloading:
		return

	if is_performing_action:
		return

	is_performing_action = true
	current_locomotion_animation = ""

	equipped_weapon = WEAPON_FLASHLIGHT

	pistol_model.visible = false
	flashlight_model.visible = true

	flashlight_on = false
	flashlight_light.visible = false

	get_tree().call_group(
		"hud",
		"update_weapon",
		"TORCIA"
	)

	update_flashlight_battery_hud()

	if not arms_animation_player.has_animation(
		"a_arms_hold_idle"
	):
		push_error(
			"Animazione a_arms_hold_idle non trovata"
		)

		is_performing_action = false
		return

	current_locomotion_animation = (
		"a_arms_hold_idle"
	)

	arms_animation_player.play(
		"a_arms_hold_idle",
		0.0
	)

	is_performing_action = false


# ============================================================
# TORCIA - ON/OFF
# ============================================================

func toggle_flashlight() -> void:
	if not owns_flashlight:
		return

	if not is_flashlight_equipped():
		return

	if flashlight_charge <= 0.0:
		flashlight_on = false
		flashlight_light.visible = false
		update_flashlight_battery_hud()
		return

	flashlight_on = not flashlight_on

	if flashlight_click_audio.stream != null:
		flashlight_click_audio.play()

	flashlight_light.visible = (
		flashlight_on
	)


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

	if is_flashlight_equipped():
		if not player_is_moving:
			animation_name = (
				"a_arms_hold_idle"
			)

		elif player_is_sprinting:
			animation_name = (
				"a_arms_hold_run"
			)

		else:
			animation_name = (
				"a_arms_hold_walk"
			)

	elif is_pistol_equipped():
		if not player_is_moving:
			animation_name = (
				"a_arms_pistol_idle"
			)

		elif player_is_sprinting:
			animation_name = (
				"a_arms_pistol_run"
			)

		else:
			animation_name = (
				"a_arms_pistol_walk"
			)

	else:
		if not player_is_moving:
			animation_name = (
				"a_arms_unarmed_idle"
			)

		elif player_is_sprinting:
			animation_name = (
				"a_arms_unarmed_run"
			)

		else:
			animation_name = (
				"a_arms_unarmed_walk"
			)

	if not arms_animation_player.has_animation(
		animation_name
	):
		push_error(
			"Animazione locomotion non trovata: "
			+ animation_name
		)

		return

	if (
		not force
		and current_locomotion_animation == animation_name
		and arms_animation_player.is_playing()
	):
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

	if String(animation_name) != (
		current_locomotion_animation
	):
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

	if is_flashlight_equipped():
		return

	if is_pistol_equipped():
		fire_pistol()
	else:
		attack_unarmed()


# ============================================================
# MANI NUDE - ATTACCO
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

	var distance_to_hit: float = (
		weapon_ray.global_position.distance_to(
			hit_point
		)
	)

	if distance_to_hit > melee_range:
		return

	if collider == null:
		return

	if collider.has_method("take_damage"):
		var health_before := _get_target_health(
			collider
		)

		collider.take_damage(
			melee_damage
		)

		_show_damage_feedback(
			collider,
			hit_point,
			melee_damage,
			health_before
		)


# ============================================================
# PISTOLA - SPARO
# ============================================================

func fire_pistol() -> void:
	if not is_pistol_equipped():
		return

	if magazine_ammo <= 0:
		if empty_audio.stream != null:
			empty_audio.play()

		return

	magazine_ammo -= 1
	update_ammo_hud()

	can_attack = false
	is_performing_action = true

	attack_cooldown_left = (
		1.0 / fire_rate
	)

	current_locomotion_animation = ""

	if shot_audio.stream != null:
		shot_audio.play()

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

	shell_casing_timer.start()

	weapon_ray.force_raycast_update()

	if weapon_ray.is_colliding():
		var collider := weapon_ray.get_collider()
		var hit_point := weapon_ray.get_collision_point()
		var hit_normal := weapon_ray.get_collision_normal()

		if collider != null:
			var dodged := false

			if collider.has_method(
				"try_dodge_shot"
			):
				dodged = bool(
					collider.try_dodge_shot(
						hit_point
					)
				)

			if not dodged:
				if (
					collider.has_method(
						"take_bullet_hit"
					)
					or collider.has_method(
						"take_damage"
					)
				):
					_apply_pistol_hit(
						collider,
						hit_point
					)
				else:
					spawn_bullet_impact(
						hit_point,
						hit_normal
					)

		else:
			spawn_bullet_impact(
				hit_point,
				hit_normal
			)

	await arms_animation_player.animation_finished

	is_performing_action = false

	play_current_locomotion(true)


func _apply_pistol_hit(
	collider: Object,
	hit_point: Vector3
) -> void:
	var health_before := _get_target_health(
		collider
	)

	if collider.has_method(
		"take_bullet_hit"
	):
		collider.take_bullet_hit(
			pistol_damage,
			hit_point
		)
	elif collider.has_method(
		"take_damage"
	):
		collider.take_damage(
			pistol_damage
		)
	else:
		return

	_show_damage_feedback(
		collider,
		hit_point,
		pistol_damage,
		health_before
	)


func _show_damage_feedback(
	target: Object,
	hit_point: Vector3,
	fallback_damage: int,
	health_before: int
) -> void:
	get_tree().call_group(
		"hud",
		"show_hitmarker"
	)

	var applied_damage := fallback_damage
	var health_after := _get_target_health(
		target
	)

	if (
		health_before >= 0
		and health_after >= 0
	):
		applied_damage = maxi(
			health_before - health_after,
			0
		)

	if applied_damage <= 0:
		return

	var critical := (
		applied_damage > fallback_damage
	)

	get_tree().call_group(
		"hud",
		"show_damage_number",
		applied_damage,
		hit_point,
		critical
	)


func _get_target_health(
	target: Object
) -> int:
	if target == null:
		return -1

	for property_info: Dictionary in (
		target.get_property_list()
	):
		var property_name := StringName(
			String(
				property_info.get(
					"name",
					""
				)
			)
		)

		if property_name != &"health":
			continue

		return int(
			target.get(
				"health"
			)
		)

	return -1


# ============================================================
# AUDIO BOSSOLI
# ============================================================

func _on_shell_casing_timer_timeout() -> void:
	if shell_casing_audio.stream == null:
		return

	shell_casing_audio.play()


# ============================================================
# BULLET IMPACT - Project Blob, materiali e suoni condivisi
# ============================================================

func spawn_bullet_impact(
	hit_point: Vector3,
	hit_normal: Vector3
) -> void:
	# Nel poligono questa risorsa e' disattivata per lasciare attiva
	# soltanto la diagnostica locale e non duplicare gli impatti.
	if bullet_impact_scene == null:
		return

	var game_scene := get_tree().current_scene
	if game_scene == null:
		return

	var manager := game_scene.get_node_or_null("ImpactManager_Runtime")
	if manager == null:
		manager = preload("res://scripts/effects/impact_manager.gd").new()
		manager.name = "ImpactManager_Runtime"
		game_scene.add_child(manager)

	var collider: Object = weapon_ray.get_collider() if weapon_ray.is_colliding() else null
	manager.spawn_impact(collider, hit_point, hit_normal)


# ============================================================
# RELOAD
# ============================================================

func reload() -> void:
	if is_flashlight_equipped():
		reload_flashlight_battery()
		return

	if not is_pistol_equipped():
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

	if reload_audio.stream != null:
		reload_audio.play()

	if arms_animation_player.has_animation(
		"a_arms_pistol_reload"
	):
		arms_animation_player.play(
			"a_arms_pistol_reload",
			0.08,
			reload_animation_speed
		)

	if pistol_animation_player.has_animation(
		"pistol_reload"
	):
		pistol_animation_player.play(
			"pistol_reload",
			-1.0,
			reload_animation_speed
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
# PICKUP MUNIZIONI
# ============================================================

func add_ammo(amount: int) -> void:
	if amount <= 0:
		return

	reserve_ammo += amount

	if is_pistol_equipped():
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
	muzzle_flash_time_left = (
		muzzle_flash_duration
	)
