extends CharacterBody3D

enum State {
	IDLE,
	CHASE,
	RECALL,
	HELD,
	MELEE,
	COMBO,
	THROW,
	HAMMER_AWAY,
	TAUNT,
	HIT,
	DEAD
}

@export_category("Movement")
@export var jog_speed: float = 2.8
@export var sprint_speed: float = 4.5
@export var rotation_speed: float = 8.0
@export var detection_distance: float = 16.0
@export var lose_player_memory: float = 4.0
@export var eye_height: float = 1.5

@export_category("Health")
@export var max_health: int = 180
@export var headshot_height: float = 1.55
@export var headshot_multiplier: float = 3.0

@export_category("Vulnerability")
@export var damage_only_when_taunting: bool = false
@export var taunt_damage_multiplier: float = 1.75

@export_category("Hammer")
@export var hammer_flight_scene: PackedScene
@export var hammer_damage: int = 28
@export var hammer_recall_distance: float = 18.0
@export var hammer_throw_min_distance: float = 3.0
@export var hammer_throw_max_distance: float = 13.0
@export var hammer_cooldown_min: float = 4.0
@export var hammer_cooldown_max: float = 6.0
@export var initial_recall_delay: float = 1.0
@export var held_before_throw_min: float = 0.8
@export var held_before_throw_max: float = 2.2
@export var throw_release_time: float = 0.40
@export var recall_spawn_distance: float = 12.0
@export var recall_spawn_height: float = 3.0
@export var hammer_socket_path: NodePath = NodePath("dr_carloni11/Sketchfab_model/root/GLTF_SceneRootNode/kratos_ARM_106/GLTF_created_0/GeneralSkeleton/HammerSocket")

@export_category("Melee con martello")
@export var melee_range: float = 3.20
@export var melee_damage: int = 18
@export var melee_cooldown_min: float = 1.0
@export var melee_cooldown_max: float = 1.5
@export_range(0.0, 1.0) var melee_hit_fraction: float = 0.48

@export_category("Combo fase 2")
@export_range(0.0, 1.0) var combo_health_threshold: float = 0.35
@export_range(0.0, 1.0) var combo_chance: float = 0.50
@export var combo_cooldown_time: float = 8.0
@export var combo_hit_damages: Array[int] = [12, 12, 15, 25]
@export var combo_hit_fractions: Array[float] = [0.22, 0.46, 0.68, 0.88]

@export_category("Taunt / Insulti")
@export_range(0.0, 1.0) var taunt_after_hammer_chance: float = 0.70
@export var taunt_duration_min: float = 2.2
@export var taunt_duration_max: float = 4.0

@export_category("Boss Bar")
@export var boss_name: String = "Dr. Carloni"
@export var show_boss_bar: bool = true

@onready var standard_player: AnimationPlayer = $AnimationLibrary_Godot_Standard/AnimationPlayer
@onready var ual2_player: AnimationPlayer = $UAL2_Standard/AnimationPlayer
@onready var human_idle_player: AnimationPlayer = $HumanM_Idle01/AnimationPlayer
@onready var mirror_player: AnimationPlayer = $AnimationLibrary_Carloni_Mirror/AnimationPlayer
@onready var hammer_socket: BoneAttachment3D = get_node_or_null(hammer_socket_path) as BoneAttachment3D

var held_hammer: Node3D = null
var flying_hammer: Node = null

var health: int = 0
var player: CharacterBody3D = null
var state: State = State.IDLE
var rng := RandomNumberGenerator.new()

var player_memory_timer: float = 0.0
var last_known_player_position: Vector3 = Vector3.ZERO

var hammer_cooldown: float = 0.0
var held_timer: float = 0.0
var throw_timer: float = 0.0
var throw_released: bool = false
var taunt_timer: float = 0.0
var melee_cooldown: float = 0.0
var combo_cooldown: float = 0.0
var attack_elapsed: float = 0.0
var attack_duration: float = 0.0
var melee_hit_done: bool = false
var combo_next_hit_index: int = 0
var current_melee_animation: StringName = &""
var last_hammer_position: Vector3 = Vector3.ZERO
var have_last_hammer_position: bool = false

var boss_bar_layer: CanvasLayer = null
var boss_bar: ProgressBar = null
var boss_hp_label: Label = null

const ANIM_IDLE: StringName = &"Idle"
const ANIM_JOG: StringName = &"Jog_Fwd"
const ANIM_SPRINT: StringName = &"Sprint"
const ANIM_HIT_CHEST: StringName = &"Hit_Chest"
const ANIM_HIT_HEAD: StringName = &"Hit_Head"
const ANIM_DEATH: StringName = &"Death01"
const ANIM_RECALL_ENTER: StringName = &"Spell_Simple_Enter_R"
const ANIM_RECALL_EXIT: StringName = &"Spell_Simple_Exit_R"

const ANIM_THROW: StringName = &"OverhandThrow"
const ANIM_SWORD_A: StringName = &"Sword_Regular_A"
const ANIM_SWORD_B: StringName = &"Sword_Regular_B"
const ANIM_SWORD_C: StringName = &"Sword_Regular_C"
const ANIM_SWORD_COMBO: StringName = &"Sword_Regular_Combo"
const ANIM_FOLD_ARMS: StringName = &"Idle_FoldArms"
const ANIM_TALKING_PHONE: StringName = &"Idle_TalkingPhone"
const ANIM_IDLE_PHONE: StringName = &"Idle_Phone"

func _ready() -> void:
	rng.randomize()
	health = max_health
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	hammer_cooldown = initial_recall_delay

	if standard_player != null:
		standard_player.animation_finished.connect(_on_standard_animation_finished)
	if ual2_player != null:
		ual2_player.animation_finished.connect(_on_ual2_animation_finished)
	if mirror_player != null:
		mirror_player.animation_finished.connect(_on_mirror_animation_finished)

	if hammer_socket == null:
		push_error("DrCarloni: HammerSocket non trovato: " + String(hammer_socket_path))
	else:
		held_hammer = hammer_socket.get_node_or_null("martello") as Node3D
		if held_hammer == null:
			push_error("DrCarloni: nodo 'martello' non trovato sotto HammerSocket.")
		else:
			held_hammer.visible = false

	if show_boss_bar:
		_create_boss_bar()
		_update_boss_bar()

	_play_standard(ANIM_IDLE)

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		_stop_horizontal_motion()
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if hammer_cooldown > 0.0:
		hammer_cooldown -= delta
	if melee_cooldown > 0.0:
		melee_cooldown -= delta
	if combo_cooldown > 0.0:
		combo_cooldown -= delta

	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as CharacterBody3D

	_update_player_awareness(delta)

	match state:
		State.IDLE:
			_process_idle()
		State.CHASE:
			_process_chase()
		State.RECALL:
			_process_recall()
		State.HELD:
			_process_held(delta)
		State.MELEE:
			_process_melee(delta)
		State.COMBO:
			_process_combo(delta)
		State.THROW:
			_process_throw(delta)
		State.HAMMER_AWAY:
			_process_hammer_away()
		State.TAUNT:
			_process_taunt(delta)
		State.HIT:
			_stop_horizontal_motion()
		State.DEAD:
			pass

	move_and_slide()

func _update_player_awareness(delta: float) -> void:
	if player == null:
		return

	var distance := global_position.distance_to(player.global_position)
	var can_see := false

	if distance <= detection_distance:
		can_see = _has_line_of_sight_to_player()

	if can_see:
		last_known_player_position = player.global_position
		player_memory_timer = lose_player_memory

		if state == State.IDLE:
			_set_state(State.CHASE)
	else:
		if player_memory_timer > 0.0:
			player_memory_timer -= delta

func _has_line_of_sight_to_player() -> bool:
	if player == null:
		return false

	var from := global_position + Vector3.UP * eye_height
	var to := player.global_position + Vector3.UP
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [get_rid()]
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var result := get_world_3d().direct_space_state.intersect_ray(query)

	if result.is_empty():
		return true

	var collider = result.get("collider")
	if collider == player:
		return true
	if collider is Node and collider.is_in_group("player"):
		return true

	return false

func _process_idle() -> void:
	_stop_horizontal_motion()

	if player != null and _should_chase_player():
		_set_state(State.CHASE)

func _process_chase() -> void:
	if player == null:
		_set_state(State.IDLE)
		return

	if player_memory_timer <= 0.0:
		_set_state(State.IDLE)
		return

	var distance := _horizontal_distance_to_player()

	if flying_hammer == null and held_hammer != null and not held_hammer.visible:
		if hammer_cooldown <= 0.0 and distance <= hammer_recall_distance and _has_line_of_sight_to_player():
			_start_recall()
			return

	var target := last_known_player_position
	if _has_line_of_sight_to_player():
		target = player.global_position
		last_known_player_position = target

	var direction := target - global_position
	direction.y = 0.0

	if direction.length_squared() <= 0.0001:
		_stop_horizontal_motion()
		return

	direction = direction.normalized()

	var speed := jog_speed
	var anim := ANIM_JOG

	if distance > 9.0:
		speed = sprint_speed
		anim = ANIM_SPRINT

	_set_horizontal_velocity(direction, speed)
	_rotate_toward(direction)
	_play_standard(anim)

func _start_recall() -> void:
	if state == State.DEAD or hammer_flight_scene == null or hammer_socket == null:
		return

	state = State.RECALL
	_stop_horizontal_motion()
	_face_player()
	_play_mirror(ANIM_RECALL_ENTER)

func _process_recall() -> void:
	_stop_horizontal_motion()
	_face_player()

func _spawn_recall_hammer() -> void:
	if hammer_flight_scene == null or hammer_socket == null:
		_finish_recall_without_hammer()
		return

	var hammer := hammer_flight_scene.instantiate()
	get_tree().current_scene.add_child(hammer)
	flying_hammer = hammer

	var start_position: Vector3

	if have_last_hammer_position:
		start_position = last_hammer_position
	else:
		var side := 1.0 if rng.randf() >= 0.5 else -1.0
		var right := global_transform.basis.x.normalized()
		var back := global_transform.basis.z.normalized()
		start_position = (
			global_position
			+ right * recall_spawn_distance * side
			+ back * recall_spawn_distance * 0.35
			+ Vector3.UP * recall_spawn_height
		)

	hammer.global_position = start_position

	if hammer.has_signal("reached_hand"):
		hammer.reached_hand.connect(_on_hammer_reached_hand)
	if hammer.has_signal("flight_finished"):
		hammer.flight_finished.connect(_on_hammer_flight_finished)

	if hammer.has_method("setup_recall"):
		hammer.setup_recall(hammer_socket, self)
	else:
		push_error("DrCarloni: hammer_flight_scene non implementa setup_recall().")

func _on_hammer_reached_hand() -> void:
	flying_hammer = null
	have_last_hammer_position = false

	if held_hammer != null:
		held_hammer.visible = true

	_play_mirror(ANIM_RECALL_EXIT)

func _finish_recall_without_hammer() -> void:
	flying_hammer = null
	hammer_cooldown = rng.randf_range(hammer_cooldown_min, hammer_cooldown_max)
	_set_state(State.CHASE)

func _process_held(delta: float) -> void:
	if player == null:
		return

	held_timer -= delta
	var distance := _horizontal_distance_to_player()

	# ZONA MELEE:
	# appena entra nel raggio corpo a corpo NON continua a correre addosso al player.
	# Se il cooldown è pronto attacca; altrimenti aspetta/lo fronteggia per pochi istanti.
	if distance <= melee_range:
		_stop_horizontal_motion()
		_face_player()

		if melee_cooldown <= 0.0 and _has_line_of_sight_to_player():
			if _can_use_combo():
				_start_combo()
			else:
				_start_melee()
		else:
			_play_standard(ANIM_IDLE)

		return

	# FUORI DAL MELEE:
	# nessun "buco" tra melee_range e hammer_throw_min_distance.
	# Se ha tenuto il martello abbastanza e il player è a portata, può lanciarlo.
	if held_timer <= 0.0:
		if distance <= hammer_throw_max_distance and _has_line_of_sight_to_player():
			_start_throw()
			return

	_process_chase_with_hammer()

func _can_use_combo() -> bool:
	if max_health <= 0:
		return false

	var health_ratio := float(health) / float(max_health)

	if health_ratio > combo_health_threshold:
		return false
	if combo_cooldown > 0.0:
		return false
	if rng.randf() > combo_chance:
		return false

	return true

func _start_melee() -> void:
	state = State.MELEE
	_stop_horizontal_motion()
	_face_player()

	var choices: Array[StringName] = [
		ANIM_SWORD_A,
		ANIM_SWORD_B,
		ANIM_SWORD_C
	]

	current_melee_animation = choices[rng.randi_range(0, choices.size() - 1)]
	attack_elapsed = 0.0
	melee_hit_done = false
	melee_cooldown = rng.randf_range(melee_cooldown_min, melee_cooldown_max)
	attack_duration = _get_ual2_animation_length(current_melee_animation)

	_play_ual2(current_melee_animation)

func _process_melee(delta: float) -> void:
	_stop_horizontal_motion()
	_face_player()

	attack_elapsed += delta

	if not melee_hit_done:
		var hit_time := attack_duration * melee_hit_fraction
		if attack_elapsed >= hit_time:
			melee_hit_done = true
			_try_apply_melee_damage(melee_damage)

func _start_combo() -> void:
	state = State.COMBO
	_stop_horizontal_motion()
	_face_player()

	current_melee_animation = ANIM_SWORD_COMBO
	attack_elapsed = 0.0
	combo_next_hit_index = 0
	combo_cooldown = combo_cooldown_time
	melee_cooldown = rng.randf_range(melee_cooldown_min, melee_cooldown_max)
	attack_duration = _get_ual2_animation_length(ANIM_SWORD_COMBO)

	_play_ual2(ANIM_SWORD_COMBO)

func _process_combo(delta: float) -> void:
	_stop_horizontal_motion()
	_face_player()

	attack_elapsed += delta

	var hit_count := mini(combo_hit_fractions.size(), combo_hit_damages.size())

	while combo_next_hit_index < hit_count:
		var hit_fraction := combo_hit_fractions[combo_next_hit_index]
		var hit_time := attack_duration * hit_fraction

		if attack_elapsed < hit_time:
			break

		_try_apply_melee_damage(combo_hit_damages[combo_next_hit_index])
		combo_next_hit_index += 1

func _try_apply_melee_damage(amount: int) -> void:
	if player == null or not is_instance_valid(player):
		return

	var distance := _horizontal_distance_to_player()
	if distance > melee_range + 0.35:
		return

	if not _has_line_of_sight_to_player():
		return

	if player.has_method("take_damage"):
		player.take_damage(amount)

func _get_ual2_animation_length(animation_name: StringName) -> float:
	if ual2_player == null:
		return 1.0
	if not ual2_player.has_animation(animation_name):
		return 1.0

	var anim := ual2_player.get_animation(animation_name)
	if anim == null:
		return 1.0

	return maxf(anim.length, 0.01)

func _process_chase_with_hammer() -> void:
	if player == null:
		return

	var direction := player.global_position - global_position
	direction.y = 0.0

	if direction.length_squared() <= 0.0001:
		_stop_horizontal_motion()
		return

	direction = direction.normalized()
	_set_horizontal_velocity(direction, jog_speed)
	_rotate_toward(direction)
	_play_standard(ANIM_JOG)

func _start_throw() -> void:
	state = State.THROW
	_stop_horizontal_motion()
	_face_player()
	throw_timer = throw_release_time
	throw_released = false
	_play_ual2(ANIM_THROW)

func _process_throw(delta: float) -> void:
	_stop_horizontal_motion()
	_face_player()

	if throw_released:
		return

	throw_timer -= delta
	if throw_timer <= 0.0:
		throw_released = true
		_release_hammer()

func _release_hammer() -> void:
	if held_hammer != null:
		held_hammer.visible = false

	if hammer_flight_scene == null or hammer_socket == null or player == null:
		hammer_cooldown = rng.randf_range(hammer_cooldown_min, hammer_cooldown_max)
		state = State.HAMMER_AWAY
		return

	var hammer := hammer_flight_scene.instantiate()
	get_tree().current_scene.add_child(hammer)
	flying_hammer = hammer

	hammer.global_transform = hammer_socket.global_transform

	if hammer.has_signal("flight_finished"):
		hammer.flight_finished.connect(_on_hammer_flight_finished)

	if hammer.has_method("setup_hunt"):
		hammer.setup_hunt(player, hammer_damage, self)
	else:
		push_error("DrCarloni: hammer_flight_scene non implementa setup_hunt().")

	state = State.HAMMER_AWAY

func _process_hammer_away() -> void:
	if player == null:
		return

	_process_chase()

func _on_hammer_flight_finished(reason: StringName, final_position: Vector3) -> void:
	flying_hammer = null
	last_hammer_position = final_position
	have_last_hammer_position = true
	hammer_cooldown = rng.randf_range(hammer_cooldown_min, hammer_cooldown_max)

	if state == State.DEAD:
		return

	if rng.randf() <= taunt_after_hammer_chance:
		_start_taunt()
	else:
		_set_state(State.CHASE)

func _start_taunt() -> void:
	state = State.TAUNT
	_stop_horizontal_motion()
	_face_player()
	taunt_timer = rng.randf_range(taunt_duration_min, taunt_duration_max)

	var choice := rng.randi_range(0, 2)

	match choice:
		0:
			if ual2_player != null and ual2_player.has_animation(ANIM_FOLD_ARMS):
				_play_ual2(ANIM_FOLD_ARMS)
			else:
				_play_standard(ANIM_IDLE)
		1:
			if ual2_player != null and ual2_player.has_animation(ANIM_TALKING_PHONE):
				_play_ual2(ANIM_TALKING_PHONE)
			else:
				_play_standard(ANIM_IDLE)
		_:
			if ual2_player != null and ual2_player.has_animation(ANIM_IDLE_PHONE):
				_play_ual2(ANIM_IDLE_PHONE)
			else:
				_play_human_idle()

func _process_taunt(delta: float) -> void:
	_stop_horizontal_motion()
	_face_player()
	taunt_timer -= delta

	if taunt_timer <= 0.0:
		_set_state(State.CHASE)

func _horizontal_distance_to_player() -> float:
	if player == null:
		return INF

	var offset := player.global_position - global_position
	offset.y = 0.0
	return offset.length()

func _set_horizontal_velocity(direction: Vector3, speed: float) -> void:
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

func _rotate_toward(direction: Vector3) -> void:
	if direction.length_squared() <= 0.0001:
		return

	var target_yaw := atan2(direction.x, direction.z)
	rotation.y = lerp_angle(
		rotation.y,
		target_yaw,
		get_physics_process_delta_time() * rotation_speed
	)

func _face_player() -> void:
	if player == null:
		return

	var direction := player.global_position - global_position
	direction.y = 0.0

	if direction.length_squared() <= 0.0001:
		return

	rotation.y = atan2(direction.x, direction.z)

func _stop_horizontal_motion() -> void:
	velocity.x = 0.0
	velocity.z = 0.0

func try_dodge_shot(_hit_point: Vector3) -> bool:
	return false

func take_bullet_hit(base_damage: int, hit_point: Vector3) -> void:
	if state == State.DEAD:
		return

	var is_headshot := hit_point.y >= global_position.y + headshot_height
	var final_damage := base_damage

	if is_headshot:
		final_damage = maxi(1, roundi(float(base_damage) * headshot_multiplier))

	_apply_damage(final_damage, is_headshot)

func take_damage(amount: int) -> void:
	_apply_damage(amount, false)

func _apply_damage(amount: int, headshot: bool) -> void:
	if state == State.DEAD:
		return

	if damage_only_when_taunting and state != State.TAUNT:
		return

	var final_amount := amount
	if state == State.TAUNT:
		final_amount = maxi(1, roundi(float(amount) * taunt_damage_multiplier))

	health = maxi(health - final_amount, 0)
	_update_boss_bar()

	print(
		"DrCarloni hit! HP remaining: ",
		health,
		" | HEADSHOT: ",
		headshot,
		" | TAUNT: ",
		state == State.TAUNT
	)

	if health <= 0:
		_die()
		return

	state = State.HIT
	_stop_horizontal_motion()

	if headshot:
		_play_standard(ANIM_HIT_HEAD)
	else:
		_play_standard(ANIM_HIT_CHEST)

func _die() -> void:
	state = State.DEAD
	_stop_horizontal_motion()

	if held_hammer != null:
		held_hammer.visible = false

	_play_standard(ANIM_DEATH)
	_update_boss_bar()

func _on_standard_animation_finished(animation_name: StringName) -> void:
	if state == State.DEAD:
		return

	if state == State.HIT:
		if animation_name == ANIM_HIT_CHEST or animation_name == ANIM_HIT_HEAD:
			_set_state(State.CHASE)

func _on_mirror_animation_finished(animation_name: StringName) -> void:
	if state == State.DEAD:
		return

	if state == State.RECALL and animation_name == ANIM_RECALL_ENTER:
		_spawn_recall_hammer()
		return

	if state == State.RECALL and animation_name == ANIM_RECALL_EXIT:
		state = State.HELD
		held_timer = rng.randf_range(held_before_throw_min, held_before_throw_max)
		return

func _on_ual2_animation_finished(animation_name: StringName) -> void:
	if state == State.THROW and animation_name == ANIM_THROW:
		if not throw_released:
			_release_hammer()
		return

	if state == State.MELEE:
		if animation_name == ANIM_SWORD_A or animation_name == ANIM_SWORD_B or animation_name == ANIM_SWORD_C:
			state = State.HELD
			held_timer = maxf(held_timer, 0.25)
			return

	if state == State.COMBO and animation_name == ANIM_SWORD_COMBO:
		state = State.HELD
		held_timer = maxf(held_timer, 0.45)
		return

func _set_state(new_state: State) -> void:
	if state == new_state:
		return

	state = new_state

	match state:
		State.IDLE:
			_stop_horizontal_motion()
			_play_standard(ANIM_IDLE)
		State.CHASE:
			pass
		State.RECALL:
			_stop_horizontal_motion()
		State.HELD:
			pass
		State.MELEE:
			_stop_horizontal_motion()
		State.COMBO:
			_stop_horizontal_motion()
		State.THROW:
			_stop_horizontal_motion()
		State.HAMMER_AWAY:
			pass
		State.TAUNT:
			_stop_horizontal_motion()
		State.HIT:
			_stop_horizontal_motion()
		State.DEAD:
			_stop_horizontal_motion()

func _should_chase_player() -> bool:
	if player == null:
		return false

	var distance := global_position.distance_to(player.global_position)

	if distance > detection_distance:
		return player_memory_timer > 0.0

	return _has_line_of_sight_to_player() or player_memory_timer > 0.0

func _stop_other_players(except: AnimationPlayer) -> void:
	for p in [standard_player, ual2_player, human_idle_player, mirror_player]:
		if p != null and p != except:
			p.stop(true)

func _play_standard(animation_name: StringName) -> void:
	if standard_player == null:
		return
	if not standard_player.has_animation(animation_name):
		push_warning("DrCarloni Standard: animazione non trovata: " + String(animation_name))
		return

	_stop_other_players(standard_player)

	if standard_player.current_animation == animation_name and standard_player.is_playing():
		return

	standard_player.speed_scale = 1.0
	standard_player.play(animation_name, 0.12)

func _play_ual2(animation_name: StringName) -> void:
	if ual2_player == null:
		return
	if not ual2_player.has_animation(animation_name):
		push_warning("DrCarloni UAL2: animazione non trovata: " + String(animation_name))
		return

	_stop_other_players(ual2_player)

	if ual2_player.current_animation == animation_name and ual2_player.is_playing():
		return

	ual2_player.speed_scale = 1.0
	ual2_player.play(animation_name, 0.10)

func _play_mirror(animation_name: StringName) -> void:
	if mirror_player == null:
		push_error("DrCarloni Mirror: AnimationPlayer non trovato.")
		return
	if not mirror_player.has_animation(animation_name):
		push_warning("DrCarloni Mirror: animazione non trovata: " + String(animation_name))
		return

	_stop_other_players(mirror_player)

	if mirror_player.current_animation == animation_name and mirror_player.is_playing():
		return

	mirror_player.speed_scale = 1.0
	mirror_player.play(animation_name, 0.10)

func _play_human_idle() -> void:
	if human_idle_player == null:
		_play_standard(ANIM_IDLE)
		return

	var anims := human_idle_player.get_animation_list()
	if anims.is_empty():
		_play_standard(ANIM_IDLE)
		return

	_stop_other_players(human_idle_player)
	human_idle_player.speed_scale = 1.0
	human_idle_player.play(anims[0], 0.10)

func _create_boss_bar() -> void:
	boss_bar_layer = CanvasLayer.new()
	boss_bar_layer.name = "DrCarloniBossBar"
	boss_bar_layer.layer = 100
	add_child(boss_bar_layer)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_bar_layer.add_child(root)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_TOP_WIDE)
	center.offset_top = 5.0
	center.offset_bottom = 61.0
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(460.0, 48.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(panel)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.035, 0.025, 0.025, 0.90)
	panel_style.border_color = Color(0.45, 0.10, 0.10, 1.0)
	panel_style.set_border_width_all(2)
	panel_style.corner_radius_top_left = 7
	panel_style.corner_radius_top_right = 7
	panel_style.corner_radius_bottom_left = 7
	panel_style.corner_radius_bottom_right = 7
	panel.add_theme_stylebox_override("panel", panel_style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 2)
	margin.add_child(column)

	var title := Label.new()
	title.text = boss_name
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 17)
	column.add_child(title)

	boss_bar = ProgressBar.new()
	boss_bar.min_value = 0.0
	boss_bar.max_value = float(max_health)
	boss_bar.value = float(health)
	boss_bar.show_percentage = false
	boss_bar.custom_minimum_size = Vector2(430.0, 10.0)
	column.add_child(boss_bar)

	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.12, 0.08, 0.08, 1.0)
	bg.corner_radius_top_left = 3
	bg.corner_radius_top_right = 3
	bg.corner_radius_bottom_left = 3
	bg.corner_radius_bottom_right = 3
	boss_bar.add_theme_stylebox_override("background", bg)

	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.72, 0.08, 0.08, 1.0)
	fill.corner_radius_top_left = 3
	fill.corner_radius_top_right = 3
	fill.corner_radius_bottom_left = 3
	fill.corner_radius_bottom_right = 3
	boss_bar.add_theme_stylebox_override("fill", fill)

	boss_hp_label = Label.new()
	boss_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_hp_label.add_theme_font_size_override("font_size", 11)
	column.add_child(boss_hp_label)

func _update_boss_bar() -> void:
	if boss_bar != null:
		boss_bar.max_value = float(max_health)
		boss_bar.value = float(health)

	if boss_hp_label != null:
		boss_hp_label.text = "%d / %d" % [health, max_health]
