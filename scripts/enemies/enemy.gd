extends CharacterBody3D

enum State {
	IDLE,
	CHASE,
	ATTACK,
	SPELL,
	HIT,
	DEAD
}

@export_category("Movement")
@export var walk_speed: float = 1.40
@export var jog_speed: float = 2.80
@export var sprint_speed: float = 4.50
@export var rotation_speed: float = 8.0

@export_category("Locomotion Animation Sync")
@export var walk_anim_reference_speed: float = 1.40
@export var jog_anim_reference_speed: float = 2.80
@export var sprint_anim_reference_speed: float = 4.50
@export var locomotion_min_speed_scale: float = 0.65
@export var locomotion_max_speed_scale: float = 1.60

@export_category("Detection")
@export var detection_distance: float = 14.0
@export var lose_player_memory: float = 4.0
@export var eye_height: float = 1.50

@export_category("Melee Combat")
@export var max_health: int = 30
@export var attack_distance: float = 1.55
@export var attack_hit_distance: float = 1.85
@export var attack_damage_jab: int = 12
@export var attack_damage_cross: int = 20
@export var attack_damage_push: int = 8
@export var attack_interval_min: float = 0.65
@export var attack_interval_max: float = 1.20
@export var jab_hit_time: float = 0.28
@export var cross_hit_time: float = 0.38
@export var push_hit_time: float = 0.32

@export_category("Spell Combat")
@export var spell_projectile_scene: PackedScene
@export var spell_damage: int = 18
@export var spell_min_distance: float = 4.0
@export var spell_max_distance: float = 10.0
@export var spell_cooldown_min: float = 4.0
@export var spell_cooldown_max: float = 7.0
@export_range(0.0, 1.0) var spell_probability: float = 0.38
@export var spell_decision_interval: float = 1.25
@export var spell_aim_min: float = 0.25
@export var spell_aim_max: float = 0.55
@export var spell_release_time: float = 0.18
@export var spell_origin_height: float = 1.35
@export var spell_origin_forward: float = 0.60

# Più basso di prima: mira circa a torace/addome invece che troppo in alto.
@export var spell_target_height: float = 0.82

@export_category("Behaviour")
@export var idle_change_min: float = 3.0
@export var idle_change_max: float = 7.0
@export var cautious_distance: float = 4.0
@export_range(0.0, 1.0) var rage_health_ratio: float = 0.34

@export_category("Boss Bar")
@export var boss_name: String = "Cecca PC"
@export var show_boss_bar: bool = true

@onready var animation_player: AnimationPlayer = $AnimationLibrary_Godot_Standard/AnimationPlayer
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var health: int = 0
var player: CharacterBody3D = null
var state: State = State.IDLE
var rng := RandomNumberGenerator.new()

var idle_timer: float = 0.0
var player_memory_timer: float = 0.0
var last_known_player_position: Vector3

var attack_cooldown: float = 0.0
var attack_hit_timer: float = 0.0
var attack_hit_applied: bool = false
var current_attack: StringName = &""

var spell_cooldown: float = 0.0
var spell_decision_timer: float = 0.0
var spell_phase: StringName = &""
var spell_phase_timer: float = 0.0
var spell_projectile_released: bool = false

var boss_bar_layer: CanvasLayer = null
var boss_bar: ProgressBar = null
var boss_hp_label: Label = null

const ANIM_IDLE: StringName = &"Idle"
const ANIM_IDLE_TALKING: StringName = &"Idle_Talking"
const ANIM_DANCE: StringName = &"Dance"
const ANIM_WALK: StringName = &"Walk"
const ANIM_JOG: StringName = &"Jog_Fwd"
const ANIM_SPRINT: StringName = &"Sprint"
const ANIM_JAB: StringName = &"Punch_Jab"
const ANIM_CROSS: StringName = &"Punch_Cross"
const ANIM_PUSH: StringName = &"Push"
const ANIM_HIT_CHEST: StringName = &"Hit_Chest"
const ANIM_HIT_HEAD: StringName = &"Hit_Head"
const ANIM_DEATH: StringName = &"Death01"
const ANIM_SPELL_ENTER: StringName = &"Spell_Simple_Enter"
const ANIM_SPELL_IDLE: StringName = &"Spell_Simple_Idle"
const ANIM_SPELL_SHOOT: StringName = &"Spell_Simple_Shoot"
const ANIM_SPELL_EXIT: StringName = &"Spell_Simple_Exit"

func _ready() -> void:
	rng.randomize()
	health = max_health
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	idle_timer = _new_idle_time()
	spell_decision_timer = spell_decision_interval

	if animation_player != null:
		animation_player.animation_finished.connect(_on_animation_finished)

	if show_boss_bar:
		_create_boss_bar()
		_update_boss_bar()

	_play_normal_animation(ANIM_IDLE, 0.15)

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		velocity.x = 0.0
		velocity.z = 0.0
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if attack_cooldown > 0.0:
		attack_cooldown -= delta

	if spell_cooldown > 0.0:
		spell_cooldown -= delta

	if spell_decision_timer > 0.0:
		spell_decision_timer -= delta

	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as CharacterBody3D

	_update_player_awareness(delta)

	match state:
		State.IDLE:
			_process_idle(delta)
		State.CHASE:
			_process_chase()
		State.ATTACK:
			_process_attack(delta)
		State.SPELL:
			_process_spell(delta)
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

func _process_idle(delta: float) -> void:
	_stop_horizontal_motion()
	idle_timer -= delta

	if idle_timer > 0.0:
		return

	idle_timer = _new_idle_time()
	var choice := rng.randf()

	if choice < 0.68:
		_play_normal_animation(ANIM_IDLE, 0.20)
	elif choice < 0.96:
		_play_normal_animation(ANIM_IDLE_TALKING, 0.20)
	else:
		_play_normal_animation(ANIM_DANCE, 0.25)

func _new_idle_time() -> float:
	return rng.randf_range(idle_change_min, idle_change_max)

func _process_chase() -> void:
	if player == null:
		_set_state(State.IDLE)
		return

	var distance := global_position.distance_to(player.global_position)

	if distance <= attack_distance:
		_stop_horizontal_motion()
		_face_player()
		if attack_cooldown <= 0.0:
			_start_random_attack()
		return

	if (
		distance >= spell_min_distance
		and distance <= spell_max_distance
		and spell_cooldown <= 0.0
		and spell_decision_timer <= 0.0
		and _has_line_of_sight_to_player()
	):
		spell_decision_timer = spell_decision_interval
		if rng.randf() <= spell_probability:
			_start_spell()
			return

	if player_memory_timer <= 0.0:
		_set_state(State.IDLE)
		return

	var target_position := last_known_player_position

	if _has_line_of_sight_to_player():
		target_position = player.global_position
		last_known_player_position = target_position

	var direction := target_position - global_position
	direction.y = 0.0

	if direction.length_squared() <= 0.0001:
		_stop_horizontal_motion()
		return

	direction = direction.normalized()
	var health_ratio := float(health) / float(max_health)

	if health_ratio <= rage_health_ratio:
		_set_horizontal_velocity(direction, sprint_speed)
		_play_locomotion(ANIM_SPRINT, sprint_speed, sprint_anim_reference_speed)
	elif distance <= cautious_distance:
		_set_horizontal_velocity(direction, walk_speed)
		_play_locomotion(ANIM_WALK, walk_speed, walk_anim_reference_speed)
	else:
		_set_horizontal_velocity(direction, jog_speed)
		_play_locomotion(ANIM_JOG, jog_speed, jog_anim_reference_speed)

	_rotate_toward(direction)

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

func _start_random_attack() -> void:
	if state == State.DEAD:
		return

	state = State.ATTACK
	_stop_horizontal_motion()
	_face_player()
	attack_hit_applied = false

	var choice := rng.randf()

	if choice < 0.45:
		current_attack = ANIM_JAB
		attack_hit_timer = jab_hit_time
		_play_normal_animation(ANIM_JAB, 0.08)
	elif choice < 0.85:
		current_attack = ANIM_CROSS
		attack_hit_timer = cross_hit_time
		_play_normal_animation(ANIM_CROSS, 0.08)
	else:
		current_attack = ANIM_PUSH
		attack_hit_timer = push_hit_time
		_play_normal_animation(ANIM_PUSH, 0.08)

func _process_attack(delta: float) -> void:
	_stop_horizontal_motion()
	_face_player()

	if attack_hit_applied:
		return

	attack_hit_timer -= delta

	if attack_hit_timer <= 0.0:
		attack_hit_applied = true
		_apply_attack_damage()

func _apply_attack_damage() -> void:
	if player == null:
		return

	var distance := global_position.distance_to(player.global_position)

	if distance > attack_hit_distance:
		return

	var damage := 0

	match current_attack:
		ANIM_JAB:
			damage = attack_damage_jab
		ANIM_CROSS:
			damage = attack_damage_cross
		ANIM_PUSH:
			damage = attack_damage_push

	if damage > 0 and player.has_method("take_damage"):
		player.take_damage(damage)

func _start_spell() -> void:
	if player == null:
		return

	state = State.SPELL
	_stop_horizontal_motion()
	_face_player()

	spell_phase = &"enter"
	spell_projectile_released = false
	_play_normal_animation(ANIM_SPELL_ENTER, 0.12)

func _process_spell(delta: float) -> void:
	_stop_horizontal_motion()
	_face_player()

	if spell_phase == &"aim":
		spell_phase_timer -= delta
		if spell_phase_timer <= 0.0:
			spell_phase = &"shoot"
			spell_phase_timer = spell_release_time
			spell_projectile_released = false
			_play_normal_animation(ANIM_SPELL_SHOOT, 0.05)

	elif spell_phase == &"shoot":
		if spell_projectile_released:
			return

		spell_phase_timer -= delta

		if spell_phase_timer <= 0.0:
			spell_projectile_released = true
			_release_spell_projectile()

func _release_spell_projectile() -> void:
	if spell_projectile_scene == null:
		push_warning("CeccaPC: spell_projectile_scene non assegnata.")
		return

	if player == null:
		return

	var projectile := spell_projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)

	var forward := -global_transform.basis.z
	var origin := (
		global_position
		+ Vector3.UP * spell_origin_height
		+ forward * spell_origin_forward
	)

	projectile.global_position = origin

	# Mira più bassa: torace/addome.
	var target := player.global_position + Vector3.UP * spell_target_height
	var direction := (target - origin).normalized()

	if projectile.has_method("setup"):
		projectile.setup(direction, spell_damage, self)

func take_damage(amount: int) -> void:
	if state == State.DEAD:
		return

	health -= amount
	health = maxi(health, 0)

	print("CeccaPC hit! HP remaining: ", health)
	_update_boss_bar()

	if health <= 0:
		_die()
		return

	state = State.HIT
	_stop_horizontal_motion()
	current_attack = &""
	spell_phase = &""
	attack_hit_applied = true

	if rng.randf() < 0.35:
		_play_normal_animation(ANIM_HIT_HEAD, 0.08)
	else:
		_play_normal_animation(ANIM_HIT_CHEST, 0.08)

func _die() -> void:
	print("CeccaPC dead")

	state = State.DEAD
	_stop_horizontal_motion()
	current_attack = &""
	spell_phase = &""
	attack_hit_applied = true
	_update_boss_bar()

	if navigation_agent != null:
		navigation_agent.avoidance_enabled = false

	_play_normal_animation(ANIM_DEATH, 0.10)

func _on_animation_finished(animation_name: StringName) -> void:
	if state == State.DEAD:
		return

	if state == State.ATTACK:
		if (
			animation_name == ANIM_JAB
			or animation_name == ANIM_CROSS
			or animation_name == ANIM_PUSH
		):
			attack_cooldown = rng.randf_range(
				attack_interval_min,
				attack_interval_max
			)
			current_attack = &""
			attack_hit_applied = false

			if _should_chase_player():
				_set_state(State.CHASE)
			else:
				_set_state(State.IDLE)
			return

	if state == State.SPELL:
		if animation_name == ANIM_SPELL_ENTER:
			spell_phase = &"aim"
			spell_phase_timer = rng.randf_range(spell_aim_min, spell_aim_max)
			_play_normal_animation(ANIM_SPELL_IDLE, 0.06)
			return

		if animation_name == ANIM_SPELL_SHOOT:
			spell_phase = &"exit"
			_play_normal_animation(ANIM_SPELL_EXIT, 0.06)
			return

		if animation_name == ANIM_SPELL_EXIT:
			spell_phase = &""
			spell_cooldown = rng.randf_range(
				spell_cooldown_min,
				spell_cooldown_max
			)
			spell_decision_timer = spell_decision_interval

			if _should_chase_player():
				_set_state(State.CHASE)
			else:
				_set_state(State.IDLE)
			return

	if state == State.HIT:
		if animation_name == ANIM_HIT_HEAD or animation_name == ANIM_HIT_CHEST:
			if _should_chase_player():
				_set_state(State.CHASE)
			else:
				_set_state(State.IDLE)
			return

	if state == State.IDLE:
		if animation_name == ANIM_IDLE_TALKING or animation_name == ANIM_DANCE:
			_play_normal_animation(ANIM_IDLE, 0.15)

func _set_state(new_state: State) -> void:
	if state == new_state:
		return

	state = new_state

	match state:
		State.IDLE:
			idle_timer = _new_idle_time()
			_stop_horizontal_motion()
			_play_normal_animation(ANIM_IDLE, 0.18)
		State.CHASE:
			pass
		State.ATTACK:
			_stop_horizontal_motion()
		State.SPELL:
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

func _stop_horizontal_motion() -> void:
	velocity.x = 0.0
	velocity.z = 0.0

func _play_normal_animation(
	animation_name: StringName,
	blend_time: float = 0.15
) -> void:
	if animation_player == null:
		return

	animation_player.speed_scale = 1.0

	if not animation_player.has_animation(animation_name):
		push_warning("CeccaPC: animazione non trovata: " + String(animation_name))
		return

	if (
		animation_player.current_animation == animation_name
		and animation_player.is_playing()
	):
		return

	animation_player.play(animation_name, blend_time)

func _play_locomotion(
	animation_name: StringName,
	actual_speed: float,
	reference_speed: float
) -> void:
	if animation_player == null:
		return

	if reference_speed <= 0.0:
		reference_speed = actual_speed

	var playback_scale := actual_speed / reference_speed

	playback_scale = clampf(
		playback_scale,
		locomotion_min_speed_scale,
		locomotion_max_speed_scale
	)

	animation_player.speed_scale = playback_scale

	if not animation_player.has_animation(animation_name):
		push_warning(
			"CeccaPC: animazione locomotion non trovata: "
			+ String(animation_name)
		)
		return

	if (
		animation_player.current_animation != animation_name
		or not animation_player.is_playing()
	):
		animation_player.play(animation_name, 0.18)

# ================================================================
# BOSS BAR
# ================================================================

func _create_boss_bar() -> void:
	boss_bar_layer = CanvasLayer.new()
	boss_bar_layer.name = "CeccaPCBossBar"
	boss_bar_layer.layer = 100
	add_child(boss_bar_layer)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_bar_layer.add_child(root)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_TOP_WIDE)
	center.offset_top = 18.0
	center.offset_bottom = 88.0
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560.0, 64.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(panel)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.035, 0.025, 0.025, 0.90)
	panel_style.border_color = Color(0.45, 0.10, 0.10, 1.0)
	panel_style.set_border_width_all(2)
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", panel_style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 5)
	margin.add_child(column)

	var title := Label.new()
	title.text = boss_name
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	column.add_child(title)

	boss_bar = ProgressBar.new()
	boss_bar.min_value = 0.0
	boss_bar.max_value = float(max_health)
	boss_bar.value = float(health)
	boss_bar.show_percentage = false
	boss_bar.custom_minimum_size = Vector2(520.0, 18.0)
	column.add_child(boss_bar)

	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.12, 0.08, 0.08, 1.0)
	bg.corner_radius_top_left = 4
	bg.corner_radius_top_right = 4
	bg.corner_radius_bottom_left = 4
	bg.corner_radius_bottom_right = 4
	boss_bar.add_theme_stylebox_override("background", bg)

	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.72, 0.08, 0.08, 1.0)
	fill.corner_radius_top_left = 4
	fill.corner_radius_top_right = 4
	fill.corner_radius_bottom_left = 4
	fill.corner_radius_bottom_right = 4
	boss_bar.add_theme_stylebox_override("fill", fill)

	boss_hp_label = Label.new()
	boss_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_hp_label.add_theme_font_size_override("font_size", 13)
	column.add_child(boss_hp_label)

func _update_boss_bar() -> void:
	if boss_bar != null:
		boss_bar.max_value = float(max_health)
		boss_bar.value = float(health)

	if boss_hp_label != null:
		boss_hp_label.text = "%d / %d" % [health, max_health]
