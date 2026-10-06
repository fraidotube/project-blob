extends CharacterBody3D


enum State {
	IDLE,
	MOVE_TO_PLAYER,
	SEEK_RACKET,
	PICKUP_RACKET,
	BALL_ATTACK,
	MELEE_ATTACK,
	SEARCH_PLAYER,
	DOWN,
	GETTING_UP,
	DEAD
}


@export_category("Test")
@export var test_mode: bool = false
@export var test_start_delay: float = 2.0
@export var has_racket: bool = false

@export_category("Boss Movement Debug")
@export var boss_movement_debug: bool = true
@export_range(0.10, 2.00, 0.05) var boss_movement_debug_interval: float = 0.40


# ============================================================
# ACTIVATION / CINEMATIC INTRO
# ============================================================

@export_category("Activation / Cinematic")
@export var start_active: bool = true
@export var cinematic_start_hidden: bool = false
@export var cinematic_start_animation: StringName = &"mie/sitting_clap1"

@export var cinematic_walk_speed: float = 1.6
@export var cinematic_arrival_distance: float = 0.35
@export var cinematic_rotation_speed: float = 7.0
@export var cinematic_disable_collider: bool = true
@export var cinematic_shrink_collider: bool = true
@export_range(0.05, 0.50, 0.01) var cinematic_collider_radius: float = 0.16
@export var cinematic_debug_logging: bool = true
@export_range(0.05, 2.0, 0.05) var cinematic_debug_interval: float = 0.25
@export_range(0.20, 1.00, 0.01) var cinematic_path_desired_distance: float = 0.35


# ============================================================
# HEALTH / BOSS
# ============================================================

@export_category("Health")
@export var max_health: int = 180
@export var headshot_height: float = 1.55
@export var headshot_multiplier: float = 2.0

@export_category("Boss Bar")
@export var boss_name: String = "BRUNO BUOZZI"
@export var show_boss_bar: bool = true


# ============================================================
# PERCEPTION
# ============================================================

@export_category("Perception")
@export var detection_distance: float = 18.0
@export var eye_height: float = 1.55
@export var player_target_height: float = 0.85
@export var player_memory_time: float = 5.0
@export var search_duration: float = 3.0
@export var search_rotation_speed: float = 1.8
@export var last_position_reached_distance: float = 0.75


# ============================================================
# MOVEMENT
# ============================================================

@export_category("Movement")
@export var rotation_speed: float = 7.0
@export var phase_1_walk_speed: float = 1.60
@export var phase_2_walk_speed: float = 1.90
@export var phase_3_walk_speed: float = 2.20
@export var phase_3_run_speed: float = 4.50
@export var phase_3_run_distance: float = 6.50
@export var preferred_ball_distance: float = 5.50
@export var minimum_ball_distance: float = 2.50
@export var maximum_ball_distance: float = 10.0
@export var preferred_melee_distance: float = 2.20
@export var maximum_melee_distance: float = 5.00
@export var maximum_racket_wave_distance: float = 15.0


# ============================================================
# NAVIGATION
# ============================================================

@export_category("Navigation")
@export var navigation_repath_distance: float = 0.45
@export var navigation_direct_fallback: bool = true
@export_range(0.20, 1.00, 0.01) var combat_path_desired_distance: float = 0.35
@export_range(0.01, 0.25, 0.01) var combat_horizontal_waypoint_skip_distance: float = 0.08
@export_category("Combat Collider Test")
@export var use_narrow_combat_collider: bool = true
@export_range(0.10, 0.50, 0.01) var narrow_combat_collider_radius: float = 0.18
@export var debug_slide_collisions: bool = true
@export var phase_2_racket_run_speed: float = 3.80
@export var phase_3_racket_run_speed: float = 4.50

@export_category("Combat Stuck Recovery")
@export var combat_stuck_recovery_enabled: bool = true
@export_range(0.05, 0.35, 0.01) var combat_step_height: float = 0.20
@export_range(0.05, 0.40, 0.01) var combat_step_forward_distance: float = 0.18
@export_range(0.01, 0.20, 0.01) var combat_step_floor_probe_extra: float = 0.06
@export_range(0.10, 2.00, 0.05) var combat_stuck_trigger_time: float = 0.45
@export_range(0.05, 0.80, 0.05) var combat_stuck_retry_delay: float = 0.40
@export_range(0.05, 0.50, 0.01) var combat_stuck_progress_ratio: float = 0.20
@export var combat_stuck_force_repath: bool = true
@export var combat_stuck_debug: bool = true


# ============================================================
# CINEMATIC MOVEMENT
# ============================================================

func _process_cinematic_move(delta: float) -> void:
	var horizontal_to_target := (
		cinematic_move_target
		- global_position
	)

	horizontal_to_target.y = 0.0

	var distance_to_target: float = (
		horizontal_to_target.length()
	)

	if (
		distance_to_target
		<= cinematic_arrival_distance
	):
		_cinematic_debug_write(
			"ARRIVED threshold root=%s dist=%.4f" % [
				str(global_position),
				distance_to_target
			]
		)

		cinematic_stop_move()
		return

	var direction := _get_navigation_direction(
		cinematic_move_target
	)

	cinematic_debug_elapsed += delta

	if (
		cinematic_debug_logging
		and cinematic_debug_elapsed
			>= cinematic_debug_interval
	):
		cinematic_debug_elapsed = 0.0
		_cinematic_debug_snapshot(
			direction,
			distance_to_target
		)

	if direction == Vector3.ZERO:
		_stop_horizontal_motion()
		return

	var desired_yaw := atan2(
		direction.x,
		direction.z
	)

	rotation.y = lerp_angle(
		rotation.y,
		desired_yaw,
		cinematic_rotation_speed * delta
	)

	var movement_distance: float = minf(
		cinematic_walk_speed * delta,
		distance_to_target
	)

	var next_position := global_position

	next_position.x += (
		direction.x
		* movement_distance
	)

	next_position.z += (
		direction.z
		* movement_distance
	)

	next_position.y = global_position.y

	global_position = next_position
	velocity = Vector3.ZERO


# ============================================================
# CINEMATIC DEBUG LOG
# ============================================================

func _open_cinematic_debug_log() -> void:
	if not cinematic_debug_logging:
		return

	cinematic_debug_file = FileAccess.open(
		cinematic_debug_path,
		FileAccess.WRITE
	)

	if cinematic_debug_file == null:
		push_warning(
			"BrunoBuozzi: impossibile creare il log cinematico."
		)
		return

	_cinematic_debug_write(
		"=== BRUNO CINEMATIC DEBUG START ==="
	)

	_cinematic_debug_write(
		"root=%s model=%s nav_agent_parent=%s" % [
			str(global_position),
			str(model_root.global_position if model_root != null else Vector3.ZERO),
			str(
				navigation_agent.get_parent().global_position
				if (
					navigation_agent != null
					and navigation_agent.get_parent() is Node3D
				)
				else Vector3.ZERO
			)
		]
	)


func _cinematic_debug_write(
	message: String
) -> void:
	if not cinematic_debug_logging:
		return

	var stamped := (
		"[%0.3f] %s" % [
			Time.get_ticks_msec() / 1000.0,
			message
		]
	)

	print(
		"[BrunoCinematicDebug] ",
		message
	)

	if cinematic_debug_file != null:
		cinematic_debug_file.store_line(
			stamped
		)

		cinematic_debug_file.flush()


func _cinematic_debug_snapshot(
	direction: Vector3,
	distance_to_target: float
) -> void:
	var next_path_position := Vector3.ZERO
	var nav_finished := false
	var nav_map_valid := false
	var map_iteration: int = -1
	var path_index: int = -1
	var path_size: int = -1

	if navigation_agent != null:
		next_path_position = (
			navigation_agent.get_next_path_position()
		)

		nav_finished = (
			navigation_agent.is_navigation_finished()
		)

		var navigation_map := (
			navigation_agent.get_navigation_map()
		)

		nav_map_valid = (
			navigation_map.is_valid()
		)

		if nav_map_valid:
			map_iteration = (
				NavigationServer3D.map_get_iteration_id(
					navigation_map
				)
			)

		path_index = (
			navigation_agent.get_current_navigation_path_index()
		)

		path_size = (
			navigation_agent.get_current_navigation_path().size()
		)

	var hips_world := Vector3.ZERO

	if (
		general_skeleton != null
		and cinematic_hips_bone_index >= 0
	):
		hips_world = _get_hips_world_position()

	_cinematic_debug_write(
		(
			"root=%s model=%s hips=%s target=%s dist=%.4f "
			+ "dir=%s next=%s nav_finished=%s "
			+ "map_valid=%s iteration=%d path_index=%d path_size=%d "
			+ "nav_target=%s path_desired=%.3f collider_disabled=%s walk_hips_lock=%s"
		) % [
			str(global_position),
			str(model_root.global_position if model_root != null else Vector3.ZERO),
			str(hips_world),
			str(cinematic_move_target),
			distance_to_target,
			str(direction),
			str(next_path_position),
			str(nav_finished),
			str(nav_map_valid),
			map_iteration,
			path_index,
			path_size,
			str(navigation_agent.target_position if navigation_agent != null else Vector3.ZERO),
			navigation_agent.path_desired_distance if navigation_agent != null else 0.0,
			str(body_collision_shape.disabled if body_collision_shape != null else false),
			str(cinematic_walk_hips_lock_active)
		]
	)


# ============================================================
# ACTION SHIELD
# ============================================================

@export_category("Action Shield")
@export var shield_enabled: bool = true
@export var shield_vertical_offset: float = 1.05
@export var shield_scale: float = 1.15
@export var shield_pulse_speed: float = 3.2
@export var shield_pulse_amount: float = 0.025
@export var shield_hidden_during_down_states: bool = true
@export var shield_hit_duration: float = 0.33
@export var shield_hit_color: Color = Color(1.0, 0.08, 0.22, 1.0)

const ACTION_SHIELD_SCENE: PackedScene = preload(
	"res://assets/vfx/shields/scifi_shield/bruno_scifi_shield.tscn"
)


func _get_current_animation_real_duration() -> float:
	if animation_player == null:
		return 0.0

	var length := animation_player.current_animation_length
	var speed := absf(animation_player.speed_scale)

	if length <= 0.0:
		return 0.0

	if speed <= 0.0001:
		speed = 1.0

	return length / speed


func _set_model_visual_y(target_y: float) -> void:
	if model_root == null:
		return

	var position := model_root.position
	position.y = target_y
	model_root.position = position


func _kill_visual_y_tween() -> void:
	if (
		visual_y_tween != null
		and visual_y_tween.is_valid()
	):
		visual_y_tween.kill()

	visual_y_tween = null


func _start_visual_y_animation(
	target_y: float,
	duration: float
) -> void:
	if model_root == null:
		return

	_kill_visual_y_tween()

	if duration <= 0.0:
		_set_model_visual_y(target_y)
		return

	visual_y_tween = create_tween()
	visual_y_tween.set_trans(Tween.TRANS_SINE)
	visual_y_tween.set_ease(Tween.EASE_IN_OUT)
	visual_y_tween.tween_property(
		model_root,
		"position:y",
		target_y,
		duration
	)


func _start_delayed_visual_y_animation(
	target_y: float,
	delay: float,
	duration: float
) -> void:
	if model_root == null:
		return

	_kill_visual_y_tween()

	visual_y_tween = create_tween()
	visual_y_tween.set_trans(Tween.TRANS_SINE)
	visual_y_tween.set_ease(Tween.EASE_IN_OUT)

	if delay > 0.0:
		visual_y_tween.tween_interval(delay)

	visual_y_tween.tween_property(
		model_root,
		"position:y",
		target_y,
		maxf(duration, 0.01)
	)


# ============================================================
# DEATH VISUAL
# ============================================================

@export_category("Death Visual")
@export var death_visual_y_offset: float = 0.78
@export var death_reach_ground_time: float = 2.20

@export_category("Visual Animation Offsets")
@export var fall_visual_y_offset: float = 0.78
@export var sitting_visual_y_offset: float = 0.33
@export var fall_reach_ground_time: float = 1.46
@export var getup_start_rise_time: float = 4.58
@export var getup_reach_standing_time: float = 6.21
@export var sit_to_stand_start_rise_time: float = 0.70
@export var sit_to_stand_reach_standing_time: float = 1.70


# ============================================================
# RACKET PICKUP
# ============================================================

@export_category("Racket Pickup")
@export var racket_pickup_distance: float = 0.25
@export_range(0.0, 1.0, 0.01) var racket_pickup_fraction: float = 0.20
@export var racket_pickup_animation_speed: float = 1.0


# ============================================================
# NORMAL TENNIS BALL
# ============================================================

@export_category("Normal Tennis Ball")
@export var tennis_ball_projectile_scene: PackedScene = preload(
	"res://scenes/enemies/tennis_ball_projectile.tscn"
)
@export var ball_damage: int = 15
@export var base_ball_release_time: float = 0.57
@export var ball_target_height: float = 0.80
@export var phase_1_ball_flight_time: float = 0.55
@export var phase_2_ball_flight_time: float = 0.42
@export var phase_3_ball_flight_time: float = 0.30
@export var phase_1_cast_speed: float = 1.00
@export var phase_2_cast_speed: float = 1.25
@export var phase_3_cast_speed: float = 1.50
@export var phase_1_ball_cooldown_min: float = 1.30
@export var phase_1_ball_cooldown_max: float = 2.00
@export var phase_2_ball_cooldown_min: float = 0.90
@export var phase_2_ball_cooldown_max: float = 1.50
@export var phase_3_ball_cooldown_min: float = 0.55
@export var phase_3_ball_cooldown_max: float = 1.10


# ============================================================
# EXPLOSIVE RACKET BALL
# ============================================================

@export_category("Explosive Racket Ball")
@export var explosive_ball_gravity: float = 22.0
@export var phase_1_explosive_flight_time: float = 0.72
@export var phase_2_explosive_flight_time: float = 0.60
@export var phase_3_explosive_flight_time: float = 0.48
@export_range(0.0, 1.0) var phase_1_explosive_ball_chance: float = 0.10
@export_range(0.0, 1.0) var phase_2_explosive_ball_chance: float = 0.20
@export_range(0.0, 1.0) var phase_3_explosive_ball_chance: float = 0.32


# ============================================================
# RACKET MELEE
# ============================================================

@export_category("Racket Melee")
@export var left_slash_damage: int = 18
@export var charged_slash_damage: int = 28
@export var left_slash_range: float = 3.60
@export var charged_slash_range: float = 5.00
@export var melee_cone_dot: float = 0.25
@export var left_slash_hit_fraction: float = 0.48
@export var charged_slash_hit_fraction: float = 0.55
@export var phase_1_melee_cooldown_min: float = 0.80
@export var phase_1_melee_cooldown_max: float = 1.20
@export var phase_2_melee_cooldown_min: float = 0.58
@export var phase_2_melee_cooldown_max: float = 0.90
@export var phase_3_melee_cooldown_min: float = 0.38
@export var phase_3_melee_cooldown_max: float = 0.65
@export var phase_1_melee_animation_speed: float = 1.00
@export var phase_2_melee_animation_speed: float = 1.15
@export var phase_3_melee_animation_speed: float = 1.30

@export_category("Combat Rhythm")
@export var hit_reaction_cooldown_time: float = 1.25
@export var phase_1_post_attack_idle_min: float = 0.65
@export var phase_1_post_attack_idle_max: float = 1.20
@export var phase_2_post_attack_idle_min: float = 0.25
@export var phase_2_post_attack_idle_max: float = 0.55
@export var phase_3_post_attack_idle_min: float = 0.0
@export var phase_3_post_attack_idle_max: float = 0.0


# ============================================================
# MELEE WAVE
# ============================================================

@export_category("Melee Wave")
@export var melee_wave_scene: PackedScene = preload(
	"res://assets/vfx/bruno_melee_banana3d/bruno_melee_banana3d.tscn"
)
@export var melee_wave_enabled: bool = true
@export var melee_wave_spawn_height_fallback: float = 1.15
@export var melee_wave_forward_offset_fallback: float = 0.90


# ============================================================
# NODES
# ============================================================

@onready var model_root: Node3D = (
	$BetterBuozzi
)


@onready var general_skeleton: Skeleton3D = (
	$BetterBuozzi
	/Armature
	/GeneralSkeleton
)

@onready var animation_player: AnimationPlayer = (
	$BetterBuozzi/AnimationPlayer
)

@onready var tennis_ball_spawn: Marker3D = (
	$BetterBuozzi
	/Armature
	/GeneralSkeleton
	/BoneAttachment3D
	/TennisBallSpawn
)

@onready var racket_visual: Node3D = (
	$BetterBuozzi
	/Armature
	/GeneralSkeleton
	/BoneAttachment3D
	/Racket_Wilson_Blade
)

@onready var racket_ball_spawn: Marker3D = get_node_or_null(
	"BetterBuozzi/Armature/GeneralSkeleton/"
	+ "BoneAttachment3D/Racket_Wilson_Blade/RacketBallSpawn"
) as Marker3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var body_collision_shape: CollisionShape3D = $CollisionShape3D


# ============================================================
# GENERAL STATE
# ============================================================

var player: CharacterBody3D = null
var racket_target: Node3D = null
var racket_pickup_position: Marker3D = null
var state: State = State.IDLE
var rng := RandomNumberGenerator.new()

var ai_active: bool = true
var cinematic_locked: bool = false
var cinematic_move_active: bool = false
var cinematic_move_target: Vector3 = Vector3.ZERO
var cinematic_move_animation: StringName = &"Casual_Walk"

var cinematic_hips_anchor_active: bool = false
var cinematic_hips_anchor_world: Vector3 = Vector3.ZERO
var cinematic_model_base_position: Vector3 = Vector3.ZERO
var cinematic_hips_bone_index: int = -1
var original_collider_shape: Shape3D
var original_collider_disabled: bool = false
var original_capsule_radius: float = 0.0
var original_capsule_height: float = 0.0
var cinematic_collider_is_shrunk: bool = false

var cinematic_walk_hips_lock_active: bool = false
var cinematic_walk_hips_anchor_local: Vector3 = Vector3.ZERO

var cinematic_debug_elapsed: float = 0.0
var cinematic_debug_file: FileAccess
var cinematic_debug_path: String = "user://bruno_cinematic_debug.log"
var original_path_desired_distance: float = 0.20


# ============================================================
# NAVIGATION STATE
# ============================================================

var navigation_ready: bool = false
var navigation_target_initialized: bool = false
var last_navigation_target: Vector3 = Vector3.ZERO

# Diagnostica movimento boss: non altera la logica AI.
var boss_debug_elapsed: float = 0.0
var boss_debug_due: bool = false
var boss_debug_last_nav_reason: String = "not_called"
var boss_debug_last_direction: Vector3 = Vector3.ZERO

# Recupero anti-incastro SOLO per il movimento AI di combattimento.
# Non viene mai usato dalla cinematic.
var combat_stuck_elapsed: float = 0.0
var combat_stuck_retry_timer: float = 0.0


# ============================================================
# SHIELD / DEATH VISUAL STATE
# ============================================================

var shield_root: Node3D = null
var shield_mesh: MeshInstance3D = null
var shield_material: ShaderMaterial = null
var shield_active: bool = false
var shield_pulse_phase: float = 0.0
var shield_hit_active: bool = false
var shield_hit_elapsed: float = 0.0

var death_visual_settled: bool = false


# ============================================================
# HEALTH STATE
# ============================================================

var health: int = 0
var combat_phase: int = 1
var pending_combat_phase: int = 1
var phase_transition_active: bool = false
var invulnerable: bool = false


# ============================================================
# PERCEPTION STATE
# ============================================================

var player_visible: bool = false
var last_known_player_position: Vector3 = Vector3.ZERO
var player_memory_timer: float = 0.0
var search_timer: float = 0.0


# ============================================================
# ATTACK STATE
# ============================================================

var ball_released: bool = false
var cast_elapsed: float = 0.0
var ball_cooldown: float = 0.0
var current_ball_animation: StringName = &""
var burst_remaining: int = 0
var melee_cooldown: float = 0.0
var melee_hit_done: bool = false
var current_melee_animation: StringName = &""
var racket_pickup_done: bool = false
var hit_reaction_active: bool = false
var current_hit_reaction_animation: StringName = &""
var hit_reaction_cooldown: float = 0.0
var post_attack_idle_timer: float = 0.0
var visual_y_tween: Tween = null


# ============================================================
# BOSS BAR
# ============================================================

var boss_bar_layer: CanvasLayer = null
var boss_segment_1: ProgressBar = null
var boss_segment_2: ProgressBar = null
var boss_segment_3: ProgressBar = null
var boss_hp_label: Label = null
var boss_phase_label: Label = null


# ============================================================
# CONSTANTS
# ============================================================

const RACKET_TARGET_GROUP: StringName = &"bruno_racket_target"

const ANIM_IDLE: StringName = &"mie/idle_combat"
const ANIM_RACKET_IDLE: StringName = &"mie/idle_racchetta"
const ANIM_WALK: StringName = &"mie/walking"
const ANIM_RACKET_WALK: StringName = &"mie/walking"
const ANIM_RUN: StringName = &"mie/running"
const ANIM_BALL_CAST: StringName = &"mie/lancio_pallina"
const ANIM_RACKET_BALL_CAST: StringName = &"mie/recchetta_dritto"
const ANIM_LEFT_SLASH: StringName = &"mie/recchetta_dritto"
const ANIM_CHARGED_SLASH: StringName = &"mie/racchetta_rovescio"
const ANIM_RACKET_PICKUP: StringName = &"mie/raccogli"
const ANIM_HIT_SMALL_1: StringName = &"mie/combat_small_hit"
const ANIM_HIT_SMALL_2: StringName = &"mie/combat_small_hit2"
const ANIM_FALLING_DOWN: StringName = &"mie/caduta"
const ANIM_STAND_UP: StringName = &"mie/rialzati2"
const ANIM_DEATH_FRONT: StringName = &"mie/morte2"
const ANIM_DEATH_BACK: StringName = &"mie/morte2"
const ANIM_SITTING_CLAP: StringName = &"mie/sitting_clap1"
const ANIM_SIT_TO_STAND: StringName = &"mie/sit_to_to stand"


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	rng.randomize()

	_open_cinematic_debug_log()

	cinematic_model_base_position = model_root.position

	if general_skeleton != null:
		cinematic_hips_bone_index = (
			general_skeleton.find_bone(
				"mixamorig_Hips"
			)
		)

		if cinematic_hips_bone_index < 0:
			cinematic_hips_bone_index = (
				general_skeleton.find_bone(
					"mixamorig:Hips"
				)
			)

	if body_collision_shape != null:
		original_collider_disabled = (
			body_collision_shape.disabled
		)

	if (
		body_collision_shape != null
		and body_collision_shape.shape != null
	):
		original_collider_shape = (
			body_collision_shape.shape
		)

		if original_collider_shape is CapsuleShape3D:
			var original_capsule := (
				original_collider_shape
				as CapsuleShape3D
			)

			original_capsule_radius = (
				original_capsule.radius
			)

			original_capsule_height = (
				original_capsule.height
			)

	health = max_health
	combat_phase = 1
	pending_combat_phase = 1

	player = get_tree().get_first_node_in_group("player") as CharacterBody3D

	if animation_player == null:
		push_error("BrunoBuozzi: AnimationPlayer non trovato.")
		return

	if tennis_ball_spawn == null:
		push_error("BrunoBuozzi: TennisBallSpawn non trovato.")
		return

	if racket_visual == null:
		push_error("BrunoBuozzi: racchetta in mano non trovata.")
		return

	if navigation_agent == null:
		push_error("BrunoBuozzi: NavigationAgent3D non trovato.")
		return

	original_path_desired_distance = (
		navigation_agent.path_desired_distance
	)

	_create_action_shield()

	animation_player.animation_finished.connect(_on_animation_finished)

	_sync_racket_visual()

	if not has_racket:
		_find_racket_target()

	if player != null:
		last_known_player_position = player.global_position

	_update_player_visibility()

	ai_active = start_active
	cinematic_locked = not start_active

	if start_active:
		if show_boss_bar:
			_create_boss_bar()
			_update_boss_bar()

		_set_state(State.IDLE)
	else:
		_prepare_cinematic_start()

	_setup_navigation.call_deferred()

	if test_mode and start_active:
		_start_test_after_delay()


# ============================================================
# ACTIVATION / CINEMATIC API
# ============================================================

func _prepare_cinematic_start() -> void:
	ai_active = false
	cinematic_locked = true
	_stop_horizontal_motion()

	_enable_cinematic_collider()

	if navigation_agent != null:
		navigation_agent.path_desired_distance = (
			cinematic_path_desired_distance
		)

	invulnerable = true
	player_visible = false

	if navigation_agent != null:
		navigation_agent.target_position = global_position

	_set_action_shield(false)
	invulnerable = true

	if model_root != null:
		model_root.visible = not cinematic_start_hidden

	if (
		animation_player != null
		and cinematic_start_animation != &""
	):
		if (
			cinematic_start_animation == ANIM_SITTING_CLAP
			or String(cinematic_start_animation).contains("sitting_")
		):
			_set_model_visual_y(
				cinematic_model_base_position.y - sitting_visual_y_offset
			)

		_play_animation(
			cinematic_start_animation,
			0.0,
			1.0
		)


func cinematic_set_visible(visible_state: bool) -> void:
	if model_root != null:
		model_root.visible = visible_state


func cinematic_play_animation(
	animation_name: StringName,
	blend_time: float = 0.15,
	playback_speed: float = 1.0
) -> void:
	if ai_active:
		return

	_play_animation(
		animation_name,
		blend_time,
		playback_speed
	)


func cinematic_play_sitting() -> void:
	_set_model_visual_y(
		cinematic_model_base_position.y - sitting_visual_y_offset
	)

	cinematic_play_animation(
		ANIM_SITTING_CLAP,
		0.15,
		1.0
	)


func cinematic_play_sit_to_stand() -> void:
	_set_model_visual_y(
		cinematic_model_base_position.y - sitting_visual_y_offset
	)

	cinematic_play_animation(
		ANIM_SIT_TO_STAND,
		0.15,
		1.0
	)

	var animation_duration := _get_current_animation_real_duration()

	var rise_start := minf(
		sit_to_stand_start_rise_time,
		animation_duration
	)

	var rise_end := minf(
		sit_to_stand_reach_standing_time,
		animation_duration
	)

	_start_delayed_visual_y_animation(
		cinematic_model_base_position.y,
		rise_start,
		maxf(rise_end - rise_start, 0.01)
	)


func cinematic_lock() -> void:
	ai_active = false
	cinematic_locked = true
	cinematic_move_active = false
	_stop_horizontal_motion()

	_enable_cinematic_collider()

	if navigation_agent != null:
		navigation_agent.path_desired_distance = (
			cinematic_path_desired_distance
		)
	player_visible = false
	invulnerable = true

	if navigation_agent != null:
		navigation_agent.target_position = global_position

	_set_action_shield(false)
	invulnerable = true


func cinematic_play_animation_and_wait(
	animation_name: StringName,
	blend_time: float = 0.15,
	playback_speed: float = 1.0
) -> void:
	if ai_active:
		return

	if animation_player == null:
		return

	var compensate_horizontal_hips: bool = (
		animation_name == ANIM_SIT_TO_STAND
		and general_skeleton != null
		and cinematic_hips_bone_index >= 0
	)

	if compensate_horizontal_hips:
		cinematic_hips_anchor_world = (
			_get_hips_world_position()
		)

		cinematic_hips_anchor_active = true

	if animation_name == ANIM_SIT_TO_STAND:
		_set_model_visual_y(
			cinematic_model_base_position.y - sitting_visual_y_offset
		)

	_play_animation(
		animation_name,
		blend_time,
		playback_speed
	)

	if animation_name == ANIM_SIT_TO_STAND:
		var animation_duration := _get_current_animation_real_duration()

		var rise_start := minf(
			sit_to_stand_start_rise_time,
			animation_duration
		)

		var rise_end := minf(
			sit_to_stand_reach_standing_time,
			animation_duration
		)

		_start_delayed_visual_y_animation(
			cinematic_model_base_position.y,
			rise_start,
			maxf(rise_end - rise_start, 0.01)
		)

	while (
		is_inside_tree()
		and animation_player != null
		and animation_player.is_playing()
		and animation_player.current_animation == String(animation_name)
	):
		await get_tree().process_frame

		if compensate_horizontal_hips:
			_compensate_cinematic_hips_xz()

	if compensate_horizontal_hips:
		_compensate_cinematic_hips_xz()
		_commit_cinematic_model_offset()

	cinematic_hips_anchor_active = false


func _get_hips_world_position() -> Vector3:
	if (
		general_skeleton == null
		or cinematic_hips_bone_index < 0
	):
		return global_position

	var hips_pose: Transform3D = (
		general_skeleton.get_bone_global_pose(
			cinematic_hips_bone_index
		)
	)

	return general_skeleton.to_global(
		hips_pose.origin
	)


func _compensate_cinematic_hips_xz() -> void:
	if not cinematic_hips_anchor_active:
		return

	if (
		general_skeleton == null
		or cinematic_hips_bone_index < 0
		or model_root == null
	):
		return

	var current_hips_world := (
		_get_hips_world_position()
	)

	var correction_world := (
		cinematic_hips_anchor_world
		- current_hips_world
	)

	correction_world.y = 0.0

	model_root.global_position += correction_world


func _commit_cinematic_model_offset() -> void:
	if model_root == null:
		return

	var local_offset := (
		model_root.position
		- cinematic_model_base_position
	)

	local_offset.y = 0.0

	if local_offset.length_squared() <= 0.000001:
		model_root.position.x = cinematic_model_base_position.x
		model_root.position.z = cinematic_model_base_position.z
		return

	var world_offset := (
		global_transform.basis
		* local_offset
	)

	world_offset.y = 0.0

	global_position += world_offset

	model_root.position.x = cinematic_model_base_position.x
	model_root.position.z = cinematic_model_base_position.z

	_invalidate_navigation_target()


func cinematic_move_to(
	target_position: Vector3,
	walk_animation: StringName = &"Casual_Walk"
) -> void:
	if ai_active:
		return

	cinematic_move_target = target_position
	cinematic_move_target.y = global_position.y
	cinematic_move_animation = walk_animation
	cinematic_move_active = true
	cinematic_debug_elapsed = 0.0
	_invalidate_navigation_target()

	_cinematic_debug_write(
		"MOVE_START target=%s root=%s model=%s" % [
			str(cinematic_move_target),
			str(global_position),
			str(model_root.global_position if model_root != null else Vector3.ZERO)
		]
	)

	if (
		general_skeleton != null
		and cinematic_hips_bone_index >= 0
	):
		cinematic_walk_hips_anchor_local = (
			to_local(
				_get_hips_world_position()
			)
		)

		cinematic_walk_hips_lock_active = true

	if cinematic_move_animation != &"":
		_play_animation(
			cinematic_move_animation,
			0.15,
			1.0
		)


func cinematic_stop_move(
	idle_animation: StringName = &"Idle_3"
) -> void:
	_cinematic_debug_write(
		"MOVE_STOP root=%s distance_to_target=%.4f" % [
			str(global_position),
			global_position.distance_to(cinematic_move_target)
		]
	)

	cinematic_move_active = false
	cinematic_walk_hips_lock_active = false
	_stop_horizontal_motion()
	_invalidate_navigation_target()

	if model_root != null:
		model_root.position.x = (
			cinematic_model_base_position.x
		)

		model_root.position.z = (
			cinematic_model_base_position.z
		)

	if navigation_agent != null:
		navigation_agent.target_position = global_position

	if idle_animation != &"":
		_play_animation(
			idle_animation,
			0.15,
			1.0
		)


func cinematic_is_moving() -> bool:
	return cinematic_move_active


func _compensate_cinematic_walk_hips_xz() -> void:
	if not cinematic_walk_hips_lock_active:
		return

	if (
		general_skeleton == null
		or cinematic_hips_bone_index < 0
		or model_root == null
	):
		return

	var current_hips_local := (
		to_local(
			_get_hips_world_position()
		)
	)

	var correction_local := (
		cinematic_walk_hips_anchor_local
		- current_hips_local
	)

	correction_local.y = 0.0

	var correction_world := (
		global_transform.basis
		* correction_local
	)

	correction_world.y = 0.0

	model_root.global_position += (
		correction_world
	)


func _enable_cinematic_collider() -> void:
	if body_collision_shape == null:
		return

	if cinematic_disable_collider:
		body_collision_shape.set_deferred(
			"disabled",
			true
		)

		cinematic_collider_is_shrunk = false
		return

	if not cinematic_shrink_collider:
		return

	if cinematic_collider_is_shrunk:
		return

	if original_collider_shape == null:
		return

	if not original_collider_shape is CapsuleShape3D:
		push_warning(
			"BrunoBuozzi: collider cinematico supportato solo per CapsuleShape3D."
		)
		return

	var cinematic_capsule := (
		original_collider_shape.duplicate()
		as CapsuleShape3D
	)

	if cinematic_capsule == null:
		return

	cinematic_capsule.radius = minf(
		cinematic_collider_radius,
		original_capsule_radius
	)

	cinematic_capsule.height = maxf(
		original_capsule_height,
		cinematic_capsule.radius * 2.0
	)

	body_collision_shape.shape = cinematic_capsule
	cinematic_collider_is_shrunk = true


func _apply_narrow_combat_collider() -> void:
	if not use_narrow_combat_collider:
		return

	if body_collision_shape == null:
		return

	if original_collider_shape == null:
		return

	if not original_collider_shape is CapsuleShape3D:
		push_warning(
			"BrunoBuozzi: narrow combat collider supportato solo per CapsuleShape3D."
		)
		return

	var combat_capsule := (
		original_collider_shape.duplicate()
		as CapsuleShape3D
	)

	if combat_capsule == null:
		return

	combat_capsule.radius = minf(
		narrow_combat_collider_radius,
		original_capsule_radius
	)

	# Altezza invariata: riduciamo solo l'ingombro laterale.
	combat_capsule.height = maxf(
		original_capsule_height,
		combat_capsule.radius * 2.0
	)

	body_collision_shape.shape = combat_capsule
	body_collision_shape.set_deferred(
		"disabled",
		false
	)

	if boss_movement_debug:
		print(
			"[BOSS MOVE DEBUG] NARROW COMBAT COLLIDER",
			" | original_radius=",
			"%.3f" % original_capsule_radius,
			" test_radius=",
			"%.3f" % combat_capsule.radius,
			" height=",
			"%.3f" % combat_capsule.height
		)


func _restore_combat_collider() -> void:
	if body_collision_shape == null:
		return

	if original_collider_shape != null:
		body_collision_shape.shape = (
			original_collider_shape
		)

	body_collision_shape.set_deferred(
		"disabled",
		original_collider_disabled
	)

	cinematic_collider_is_shrunk = false



func _boss_state_name(value: State) -> String:
	match value:
		State.IDLE:
			return "IDLE"
		State.MOVE_TO_PLAYER:
			return "MOVE_TO_PLAYER"
		State.SEEK_RACKET:
			return "SEEK_RACKET"
		State.PICKUP_RACKET:
			return "PICKUP_RACKET"
		State.BALL_ATTACK:
			return "BALL_ATTACK"
		State.MELEE_ATTACK:
			return "MELEE_ATTACK"
		State.SEARCH_PLAYER:
			return "SEARCH_PLAYER"
		State.DOWN:
			return "DOWN"
		State.GETTING_UP:
			return "GETTING_UP"
		State.DEAD:
			return "DEAD"
	return "UNKNOWN"


func _boss_debug_begin_frame(delta: float) -> void:
	if not boss_movement_debug:
		boss_debug_due = false
		return

	boss_debug_elapsed += delta
	if boss_debug_elapsed >= boss_movement_debug_interval:
		boss_debug_elapsed = 0.0
		boss_debug_due = true
	else:
		boss_debug_due = false


func _boss_debug_snapshot(label: String) -> void:
	if not boss_movement_debug or not boss_debug_due:
		return

	var player_dist := -1.0
	var player_pos := Vector3.ZERO

	if player != null and is_instance_valid(player):
		player_pos = player.global_position
		player_dist = global_position.distance_to(player_pos)

	var racket_valid := (
		racket_pickup_position != null
		and is_instance_valid(racket_pickup_position)
	)

	var racket_pos := Vector3.ZERO
	if racket_valid:
		racket_pos = racket_pickup_position.global_position

	var nav_target := Vector3.ZERO
	var nav_next := Vector3.ZERO
	var nav_finished := false
	var nav_ready_now := navigation_ready
	var path_size := -1
	var path_index := -1
	var path_desired := -1.0

	if navigation_agent != null:
		nav_target = navigation_agent.target_position
		nav_next = navigation_agent.get_next_path_position()
		nav_finished = navigation_agent.is_navigation_finished()
		path_size = navigation_agent.get_current_navigation_path().size()
		path_index = navigation_agent.get_current_navigation_path_index()
		path_desired = navigation_agent.path_desired_distance

	print(
		"[BOSS MOVE DEBUG] ", label,
		" | state=", _boss_state_name(state),
		" ai=", ai_active,
		" cin_locked=", cinematic_locked,
		" cin_move=", cinematic_move_active,
		" has_racket=", has_racket,
		" player_visible=", player_visible,
		" memory=", "%.2f" % player_memory_timer,
		" pos=", global_position,
		" vel=", velocity,
		" player_pos=", player_pos,
		" player_dist=", "%.3f" % player_dist,
		" racket_valid=", racket_valid,
		" racket_pos=", racket_pos,
		" nav_ready=", nav_ready_now,
		" nav_target=", nav_target,
		" nav_next=", nav_next,
		" nav_finished=", nav_finished,
		" path_idx=", path_index,
		" path_size=", path_size,
		" path_desired=", "%.3f" % path_desired,
		" nav_reason=", boss_debug_last_nav_reason,
		" nav_dir=", boss_debug_last_direction
	)


func start_boss_fight() -> void:
	if boss_movement_debug:
		print(
			"[BOSS MOVE DEBUG] START_BOSS_FIGHT ENTER",
			" | pos=", global_position,
			" state=", _boss_state_name(state),
			" ai=", ai_active,
			" cin_locked=", cinematic_locked,
			" cin_move=", cinematic_move_active,
			" has_racket=", has_racket
		)

	_set_model_visual_y(
		cinematic_model_base_position.y
	)

	if state == State.DEAD:
		return

	_restore_combat_collider()
	_apply_narrow_combat_collider()

	if navigation_agent != null:
		navigation_agent.path_desired_distance = (
			combat_path_desired_distance
		)

		if boss_movement_debug:
			print(
				"[BOSS MOVE DEBUG] COMBAT path_desired_distance=",
				"%.3f" % navigation_agent.path_desired_distance,
				" | original=",
				"%.3f" % original_path_desired_distance
			)

	if model_root != null:
		model_root.visible = true

	cinematic_locked = false
	cinematic_move_active = false
	cinematic_walk_hips_lock_active = false
	ai_active = true

	if not phase_transition_active:
		invulnerable = false

	if (
		show_boss_bar
		and boss_bar_layer == null
	):
		_create_boss_bar()

	_update_boss_bar()

	if (
		not has_racket
		and (
			racket_target == null
			or not is_instance_valid(racket_target)
		)
	):
		_find_racket_target()

	if player == null or not is_instance_valid(player):
		player = (
			get_tree()
			.get_first_node_in_group("player")
			as CharacterBody3D
		)

	if player != null:
		last_known_player_position = player.global_position

	_update_player_visibility()
	_invalidate_navigation_target()
	_set_state(State.IDLE)

	if boss_movement_debug:
		print(
			"[BOSS MOVE DEBUG] START_BOSS_FIGHT READY",
			" | state=", _boss_state_name(state),
			" ai=", ai_active,
			" cin_locked=", cinematic_locked,
			" cin_move=", cinematic_move_active,
			" player_visible=", player_visible,
			" racket_valid=",
			(
				racket_pickup_position != null
				and is_instance_valid(racket_pickup_position)
			),
			" pos=", global_position
		)



func _setup_navigation() -> void:
	await get_tree().physics_frame

	if not is_inside_tree():
		return

	navigation_ready = true
	_invalidate_navigation_target()


func _process(_delta: float) -> void:
	if cinematic_walk_hips_lock_active:
		_compensate_cinematic_walk_hips_xz()


# ============================================================
# PHYSICS
# ============================================================

func _physics_process(delta: float) -> void:
	_boss_debug_begin_frame(delta)
	_update_action_shield(delta)

	if boss_debug_due:
		_boss_debug_snapshot("PHYSICS_BEGIN")

	if not ai_active:
		if cinematic_move_active:
			_process_cinematic_move(delta)
		else:
			velocity = Vector3.ZERO

		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if state == State.DEAD:
		_stop_horizontal_motion()
		move_and_slide()
		return

	if state == State.DOWN or state == State.GETTING_UP:
		_stop_horizontal_motion()
		move_and_slide()
		return

	if hit_reaction_active:
		_stop_horizontal_motion()
		move_and_slide()
		return

	if post_attack_idle_timer > 0.0:
		post_attack_idle_timer -= delta
		_stop_horizontal_motion()

		_play_animation(
			_get_combat_idle_animation(),
			0.12,
			1.0
		)

		move_and_slide()

		if post_attack_idle_timer <= 0.0:
			post_attack_idle_timer = 0.0
			_resume_after_idle_pause()

		return

	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as CharacterBody3D

	if (
		not has_racket
		and (
			racket_target == null
			or not is_instance_valid(racket_target)
		)
	):
		_find_racket_target()

	_update_perception(delta)

	if ball_cooldown > 0.0:
		ball_cooldown -= delta

	if melee_cooldown > 0.0:
		melee_cooldown -= delta

	if hit_reaction_cooldown > 0.0:
		hit_reaction_cooldown = maxf(
			0.0,
			hit_reaction_cooldown - delta
		)

	match state:
		State.IDLE:
			_process_idle()
		State.MOVE_TO_PLAYER:
			_process_move_to_player(delta)
		State.SEEK_RACKET:
			_process_seek_racket(delta)
		State.PICKUP_RACKET:
			_process_pickup_racket()
		State.BALL_ATTACK:
			_process_ball_attack(delta)
		State.MELEE_ATTACK:
			_process_melee_attack(delta)
		State.SEARCH_PLAYER:
			_process_search_player(delta)
		State.DOWN:
			pass
		State.GETTING_UP:
			pass
		State.DEAD:
			pass

	if boss_debug_due:
		_boss_debug_snapshot("PRE_MOVE_AND_SLIDE")

	var boss_debug_before_move := global_position
	var combat_intended_velocity := Vector3(
		velocity.x,
		0.0,
		velocity.z
	)

	var combat_had_collision := move_and_slide()

	_process_combat_stuck_recovery(
		delta,
		boss_debug_before_move,
		combat_intended_velocity,
		combat_had_collision
	)

	if boss_debug_due:
		print(
			"[BOSS MOVE DEBUG] POST_MOVE_AND_SLIDE",
			" | before=", boss_debug_before_move,
			" after=", global_position,
			" moved=", "%.5f" % boss_debug_before_move.distance_to(global_position),
			" vel_after=", velocity
		)


		if debug_slide_collisions:
			var collision_count := get_slide_collision_count()

			print(
				"[BOSS COLLISION DEBUG] count=",
				collision_count
			)

			for collision_index in range(collision_count):
				var collision := get_slide_collision(
					collision_index
				)

				if collision == null:
					continue

				var collider_object := collision.get_collider()
				var collider_name := "<null>"
				var collider_path := "<non-node>"

				if collider_object is Node:
					var collider_node := collider_object as Node
					collider_name = collider_node.name
					collider_path = str(
						collider_node.get_path()
					)
				elif collider_object != null:
					collider_name = str(collider_object)

				print(
					"[BOSS COLLISION DEBUG] #",
					collision_index,
					" collider=",
					collider_name,
					" path=",
					collider_path,
					" normal=",
					collision.get_normal(),
					" position=",
					collision.get_position(),
					" travel=",
					collision.get_travel(),
					" remainder=",
					collision.get_remainder()
				)





# ============================================================
# ACTION SHIELD
# ============================================================

func _create_action_shield() -> void:
	if not shield_enabled:
		return

	if shield_root != null:
		return

	if ACTION_SHIELD_SCENE == null:
		push_error(
			"BrunoBuozzi: scena scudo Sci-Fi non disponibile."
		)
		return

	var shield_instance := ACTION_SHIELD_SCENE.instantiate()

	if not shield_instance is Node3D:
		push_error(
			"BrunoBuozzi: la scena dello scudo non ha root Node3D."
		)

		shield_instance.queue_free()
		return

	shield_root = shield_instance as Node3D
	shield_root.name = "BrunoActionShield"
	shield_root.position = Vector3(
		0.0,
		shield_vertical_offset,
		0.0
	)

	shield_root.scale = Vector3.ONE * shield_scale
	shield_root.visible = false

	add_child(shield_root)

	shield_mesh = shield_root.get_node_or_null("ShieldMesh") as MeshInstance3D

	if shield_mesh != null:
		var base_material := shield_mesh.get_surface_override_material(0)

		if base_material == null:
			base_material = shield_mesh.get_active_material(0)

		if base_material is ShaderMaterial:
			shield_material = (base_material as ShaderMaterial).duplicate() as ShaderMaterial
			shield_mesh.set_surface_override_material(0, shield_material)
			shield_material.set_shader_parameter("hit_progress", 1.0)
			shield_material.set_shader_parameter("hit_color", shield_hit_color)
			shield_material.set_shader_parameter("hit_position", Vector3.UP)


func _set_action_shield(active: bool) -> void:
	shield_active = active
	_refresh_action_shield_visibility()

	if active:
		invulnerable = true
	else:
		shield_hit_active = false
		shield_hit_elapsed = 0.0
		_reset_shield_hit_visual()

		if (
			not phase_transition_active
			and state != State.DEAD
		):
			invulnerable = false


func _should_show_action_shield() -> bool:
	if not shield_active:
		return false

	if shield_hidden_during_down_states:
		if (
			state == State.DOWN
			or state == State.GETTING_UP
			or state == State.DEAD
		):
			return false

	return true


func _refresh_action_shield_visibility() -> void:
	if shield_root == null:
		return

	shield_root.visible = _should_show_action_shield()


func _reset_shield_hit_visual() -> void:
	if shield_material == null:
		return

	shield_material.set_shader_parameter("hit_progress", 1.0)


func _trigger_shield_hit(world_hit_point: Vector3) -> void:
	if not shield_active:
		return

	if shield_root == null or shield_material == null:
		return

	if not _should_show_action_shield():
		return

	var local_hit := shield_root.to_local(world_hit_point)

	if local_hit.length_squared() <= 0.0001:
		local_hit = Vector3.UP
	else:
		local_hit = local_hit.normalized()

	shield_material.set_shader_parameter("hit_position", local_hit)
	shield_material.set_shader_parameter("hit_color", shield_hit_color)
	shield_material.set_shader_parameter("hit_progress", 0.0)

	shield_hit_active = true
	shield_hit_elapsed = 0.0


func _update_action_shield(delta: float) -> void:
	_refresh_action_shield_visibility()

	if not shield_active:
		return

	if shield_root == null:
		return

	shield_pulse_phase += (
		delta
		* shield_pulse_speed
	)

	var pulse := sin(
		shield_pulse_phase
	)

	var current_scale := (
		shield_scale
		* (
			1.0
			+ pulse
			* shield_pulse_amount
		)
	)

	shield_root.scale = (
		Vector3.ONE
		* current_scale
	)

	if shield_hit_active and shield_material != null:
		shield_hit_elapsed += delta

		var duration := maxf(shield_hit_duration, 0.01)
		var progress := clampf(
			shield_hit_elapsed / duration,
			0.0,
			1.0
		)

		shield_material.set_shader_parameter("hit_progress", progress)

		if progress >= 1.0:
			shield_hit_active = false


# ============================================================
# DEATH VISUAL
# ============================================================

func _settle_dead_visual() -> void:
	if death_visual_settled:
		return

	death_visual_settled = true

	if model_root == null:
		return

	_kill_visual_y_tween()

	_set_model_visual_y(
		cinematic_model_base_position.y - death_visual_y_offset
	)



# ============================================================
# TEST
# ============================================================

func _start_test_after_delay() -> void:
	await get_tree().create_timer(test_start_delay).timeout

	if not is_inside_tree():
		return

	if state == State.DEAD:
		return

	if (
		not has_racket
		and racket_pickup_position != null
		and is_instance_valid(racket_pickup_position)
	):
		_set_state(State.SEEK_RACKET)
		return

	if player_visible:
		_set_state(State.MOVE_TO_PLAYER)


# ============================================================
# NAVIGATION
# ============================================================

func _invalidate_navigation_target() -> void:
	navigation_target_initialized = false


func _combat_stuck_recovery_allowed() -> bool:
	if not combat_stuck_recovery_enabled:
		return false

	if not ai_active:
		return false

	if cinematic_locked or cinematic_move_active:
		return false

	if state != State.MOVE_TO_PLAYER and state != State.SEEK_RACKET:
		return false

	if hit_reaction_active:
		return false

	return true


func _reset_combat_stuck_recovery() -> void:
	combat_stuck_elapsed = 0.0


func _process_combat_stuck_recovery(
	delta: float,
	before_move_position: Vector3,
	intended_velocity: Vector3,
	had_collision: bool
) -> void:
	if combat_stuck_retry_timer > 0.0:
		combat_stuck_retry_timer = maxf(
			0.0,
			combat_stuck_retry_timer - delta
		)

	if not _combat_stuck_recovery_allowed():
		_reset_combat_stuck_recovery()
		return

	var intended_speed := intended_velocity.length()

	if intended_speed <= 0.05:
		_reset_combat_stuck_recovery()
		return

	var moved_delta := global_position - before_move_position
	moved_delta.y = 0.0

	var expected_distance := intended_speed * delta
	var minimum_progress := (
		expected_distance
		* combat_stuck_progress_ratio
	)

	var movement_is_blocked := (
		had_collision
		and moved_delta.length() < minimum_progress
	)

	if not movement_is_blocked:
		_reset_combat_stuck_recovery()
		return

	combat_stuck_elapsed += delta

	if combat_stuck_elapsed < combat_stuck_trigger_time:
		return

	if combat_stuck_retry_timer > 0.0:
		return

	var direction := intended_velocity.normalized()

	if _try_combat_step_up(direction):
		if combat_stuck_debug:
			print(
				"[BOSS STUCK RECOVERY] STEP_UP",
				" | state=", _boss_state_name(state),
				" | pos=", global_position,
				" | step_height=", "%.2f" % combat_step_height
			)

		_reset_combat_stuck_recovery()
		combat_stuck_retry_timer = combat_stuck_retry_delay

		# Dopo lo step chiediamo un nuovo path dal nuovo punto reale.
		_invalidate_navigation_target()
		return

	if combat_stuck_force_repath:
		_force_combat_repath()

	if combat_stuck_debug:
		print(
			"[BOSS STUCK RECOVERY] REPATH",
			" | state=", _boss_state_name(state),
			" | pos=", global_position,
			" | nav_target=", last_navigation_target
		)

	_reset_combat_stuck_recovery()
	combat_stuck_retry_timer = combat_stuck_retry_delay


func _try_combat_step_up(direction: Vector3) -> bool:
	if direction.length_squared() <= 0.0001:
		return false

	if not is_on_floor():
		return false

	var step_height := maxf(
		combat_step_height,
		0.01
	)

	var forward_distance := maxf(
		combat_step_forward_distance,
		0.01
	)

	var horizontal_direction := Vector3(
		direction.x,
		0.0,
		direction.z
	)

	if horizontal_direction.length_squared() <= 0.0001:
		return false

	horizontal_direction = horizontal_direction.normalized()

	var up_motion := Vector3.UP * step_height
	var forward_motion := (
		horizontal_direction * forward_distance
	)

	# 1) Deve esserci spazio sopra Bruno.
	if test_move(global_transform, up_motion):
		return false

	# 2) Alla quota rialzata deve poter avanzare oltre il piccolo ostacolo.
	var raised_transform := global_transform
	raised_transform.origin += up_motion

	if test_move(raised_transform, forward_motion):
		return false

	# 3) Dopo l'avanzamento deve esserci nuovamente un piano sotto i piedi.
	# Questo evita che lo step-up lo faccia salire nel vuoto.
	var forward_transform := raised_transform
	forward_transform.origin += forward_motion

	var down_motion := Vector3.DOWN * (
		step_height
		+ maxf(combat_step_floor_probe_extra, 0.01)
	)

	if not test_move(forward_transform, down_motion):
		return false

	# Esegue lo step usando la fisica del CharacterBody3D.
	var up_collision := move_and_collide(up_motion)

	if up_collision != null:
		return false

	var forward_collision := move_and_collide(forward_motion)

	if forward_collision != null:
		return false

	move_and_collide(down_motion)

	return true


func _force_combat_repath() -> void:
	if navigation_agent == null:
		return

	if not navigation_ready:
		return

	if not navigation_target_initialized:
		return

	var target := last_navigation_target

	# Forza una nuova richiesta di percorso dalla posizione reale attuale.
	navigation_target_initialized = false
	navigation_agent.target_position = target
	last_navigation_target = target
	navigation_target_initialized = true


func _direct_direction_to(target_position: Vector3) -> Vector3:
	var direction := target_position - global_position
	direction.y = 0.0

	if direction.length_squared() <= 0.0001:
		return Vector3.ZERO

	return direction.normalized()


func _get_navigation_direction(target_position: Vector3) -> Vector3:
	boss_debug_last_nav_reason = "start"
	boss_debug_last_direction = Vector3.ZERO
	if navigation_agent == null:
		boss_debug_last_nav_reason = "no_navigation_agent"
		if navigation_direct_fallback:
			return _direct_direction_to(target_position)
		return Vector3.ZERO

	if not navigation_ready:
		boss_debug_last_nav_reason = "navigation_not_ready"
		if navigation_direct_fallback:
			return _direct_direction_to(target_position)
		return Vector3.ZERO

	var navigation_map := navigation_agent.get_navigation_map()

	if not navigation_map.is_valid():
		boss_debug_last_nav_reason = "navigation_map_invalid"
		if navigation_direct_fallback:
			return _direct_direction_to(target_position)
		return Vector3.ZERO

	var map_iteration := NavigationServer3D.map_get_iteration_id(navigation_map)

	if map_iteration == 0:
		boss_debug_last_nav_reason = "navigation_map_iteration_zero"
		if navigation_direct_fallback:
			return _direct_direction_to(target_position)
		return Vector3.ZERO

	var needs_new_target := not navigation_target_initialized

	if navigation_target_initialized:
		var target_shift := last_navigation_target.distance_to(target_position)

		if target_shift >= navigation_repath_distance:
			needs_new_target = true

	if needs_new_target:
		navigation_agent.target_position = target_position
		last_navigation_target = target_position
		navigation_target_initialized = true

	var next_path_position := navigation_agent.get_next_path_position()

	var navigation_finished := navigation_agent.is_navigation_finished()

	var delta_to_next := next_path_position - global_position
	delta_to_next.y = 0.0

	if navigation_finished:
		boss_debug_last_nav_reason = "navigation_finished"
		return Vector3.ZERO

	if delta_to_next.length_squared() <= 0.0001:
		# IMPORTANTE:
		# La cinematic usa questa stessa funzione. Non cambiamo il suo
		# comportamento: il workaround seguente vale SOLO per l'AI di
		# combattimento.
		var combat_navigation_active := (
			ai_active
			and not cinematic_locked
			and not cinematic_move_active
		)

		if combat_navigation_active:
			var current_path := (
				navigation_agent
				.get_current_navigation_path()
			)
			var current_index := (
				navigation_agent
				.get_current_navigation_path_index()
			)

			# In alcuni cambi di quota il waypoint corrente può avere
			# praticamente la stessa X/Z di Bruno ma una Y abbastanza
			# diversa da non essere considerato raggiunto dall'Agent.
			# In quel caso cerchiamo SOLO per la direzione di movimento
			# il primo waypoint successivo realmente distante sul piano.
			for path_index in range(
				current_index + 1,
				current_path.size()
			):
				var candidate := current_path[path_index]
				var candidate_delta := (
					candidate
					- global_position
				)
				candidate_delta.y = 0.0

				if (
					candidate_delta.length()
					<= combat_horizontal_waypoint_skip_distance
				):
					continue

				boss_debug_last_direction = (
					candidate_delta.normalized()
				)
				boss_debug_last_nav_reason = (
					"combat_skip_vertical_waypoint"
					+ "|from_idx="
					+ str(current_index)
					+ "|to_idx="
					+ str(path_index)
				)

				return boss_debug_last_direction

		boss_debug_last_nav_reason = "next_path_equals_current"
		return Vector3.ZERO

	boss_debug_last_direction = delta_to_next.normalized()
	boss_debug_last_nav_reason = "direction_ok"
	return boss_debug_last_direction


# ============================================================
# HEALTH / DAMAGE
# ============================================================

func take_bullet_hit(base_damage: int, hit_point: Vector3) -> void:
	if state == State.DEAD:
		return

	if invulnerable:
		_trigger_shield_hit(hit_point)
		return

	var is_headshot := (
		hit_point.y
		>= global_position.y + headshot_height
	)

	var final_damage := base_damage

	if is_headshot:
		final_damage = maxi(
			1,
			roundi(float(base_damage) * headshot_multiplier)
		)

	_apply_damage(final_damage)


func take_damage(amount: int) -> void:
	_apply_damage(amount)


func _apply_damage(amount: int) -> void:
	if state == State.DEAD or invulnerable or amount <= 0:
		return

	health -= amount
	health = maxi(health, 0)

	_update_boss_bar()

	print(
		"Bruno hit! HP: ",
		health,
		"/",
		max_health,
		" | Phase: ",
		combat_phase
	)

	if health <= 0:
		_die()
		return

	var segment_health := _get_segment_health()

	if combat_phase == 1 and health <= segment_health * 2:
		_start_phase_transition(2)
		return

	if combat_phase == 2 and health <= segment_health:
		_start_phase_transition(3)
		return

	if not has_racket:
		_start_unarmed_hit_reaction()


func _start_unarmed_hit_reaction() -> void:
	if has_racket:
		return

	if hit_reaction_cooldown > 0.0:
		return

	if (
		state == State.DEAD
		or state == State.DOWN
		or state == State.GETTING_UP
		or phase_transition_active
	):
		return

	var choices: Array[StringName] = [
		ANIM_HIT_SMALL_1,
		ANIM_HIT_SMALL_2
	]

	var chosen := choices[
		rng.randi_range(
			0,
			choices.size() - 1
		)
	]

	if (
		animation_player == null
		or not animation_player.has_animation(chosen)
	):
		push_warning(
			"BrunoBuozzi: animazione hit non trovata: "
			+ String(chosen)
		)
		return

	hit_reaction_active = true
	current_hit_reaction_animation = chosen

	_set_action_shield(true)
	_stop_horizontal_motion()

	_play_animation(
		chosen,
		0.05,
		1.0
	)


func _get_segment_health() -> int:
	return maxi(
		1,
		ceili(float(max_health) / 3.0)
	)


func _start_phase_transition(new_phase: int) -> void:
	if phase_transition_active or state == State.DEAD:
		return

	phase_transition_active = true
	post_attack_idle_timer = 0.0
	hit_reaction_cooldown = 0.0
	pending_combat_phase = clampi(new_phase, 1, 3)
	_set_action_shield(true)

	state = State.DOWN

	_invalidate_navigation_target()
	_stop_horizontal_motion()

	burst_remaining = 0
	ball_released = false
	cast_elapsed = 0.0
	current_ball_animation = &""
	melee_hit_done = false
	current_melee_animation = &""
	hit_reaction_active = false
	current_hit_reaction_animation = &""

	_play_animation(
		ANIM_FALLING_DOWN,
		0.08,
		1.0
	)

	var fall_duration := minf(
		fall_reach_ground_time,
		_get_current_animation_real_duration()
	)

	_start_visual_y_animation(
		cinematic_model_base_position.y - fall_visual_y_offset,
		fall_duration
	)


func _start_getting_up() -> void:
	state = State.GETTING_UP
	_stop_horizontal_motion()

	_set_model_visual_y(
		cinematic_model_base_position.y - fall_visual_y_offset
	)

	_play_animation(
		ANIM_STAND_UP,
		0.08,
		1.0
	)

	var animation_duration := (
		_get_current_animation_real_duration()
	)

	var rise_start := minf(
		getup_start_rise_time,
		animation_duration
	)

	var rise_end := minf(
		getup_reach_standing_time,
		animation_duration
	)

	var rise_duration := maxf(
		rise_end - rise_start,
		0.01
	)

	_start_delayed_visual_y_animation(
		cinematic_model_base_position.y,
		rise_start,
		rise_duration
	)


func _finish_phase_transition() -> void:
	combat_phase = pending_combat_phase
	phase_transition_active = false
	_set_action_shield(false)

	_update_boss_bar()
	_resume_after_action()


func _die() -> void:
	if state == State.DEAD:
		return

	state = State.DEAD
	post_attack_idle_timer = 0.0
	hit_reaction_cooldown = 0.0
	phase_transition_active = false
	_set_action_shield(false)
	invulnerable = true
	health = 0

	_invalidate_navigation_target()
	_stop_horizontal_motion()

	burst_remaining = 0
	ball_released = false
	melee_hit_done = true
	hit_reaction_active = false
	current_hit_reaction_animation = &""

	_update_boss_bar()

	_play_animation(
		ANIM_DEATH_FRONT,
		0.08,
		1.0
	)

	# La morte2 è in-place: il modello visuale deve scendere
	# insieme alla caduta senza spostare CharacterBody/collider.
	_start_visual_y_animation(
		cinematic_model_base_position.y - death_visual_y_offset,
		minf(
			death_reach_ground_time,
			_get_current_animation_real_duration()
		)
	)


func _player_is_behind_bruno() -> bool:
	if player == null:
		return false

	var to_player := player.global_position - global_position
	to_player.y = 0.0

	if to_player.length_squared() <= 0.0001:
		return false

	to_player = to_player.normalized()

	var forward := global_transform.basis.z
	forward.y = 0.0

	if forward.length_squared() <= 0.0001:
		return false

	forward = forward.normalized()

	return forward.dot(to_player) < 0.0


# ============================================================
# RACKET TARGET
# ============================================================

func _find_racket_target() -> void:
	var node := get_tree().get_first_node_in_group(RACKET_TARGET_GROUP)

	if not node is Node3D:
		racket_target = null
		racket_pickup_position = null
		return

	racket_target = node as Node3D

	var marker := racket_target.get_node_or_null("PickupPosition")

	if marker is Marker3D:
		racket_pickup_position = marker as Marker3D
	else:
		racket_pickup_position = null
		push_error(
			"BrunoBuozzi: PickupPosition non trovato "
			+ "dentro BrunoRacketPickup."
		)


# ============================================================
# PERCEPTION
# ============================================================

func _update_perception(delta: float) -> void:
	if player == null:
		player_visible = false
		return

	_update_player_visibility()

	if player_visible:
		last_known_player_position = player.global_position
		player_memory_timer = player_memory_time
	else:
		if player_memory_timer > 0.0:
			player_memory_timer -= delta


func _update_player_visibility() -> void:
	player_visible = _has_line_of_sight_to_player()


func _has_line_of_sight_to_player() -> bool:
	if player == null:
		return false

	var distance := global_position.distance_to(player.global_position)

	if distance > detection_distance:
		return false

	var from_position := global_position + Vector3.UP * eye_height
	var to_position := (
		player.global_position
		+ Vector3.UP * player_target_height
	)

	var query := PhysicsRayQueryParameters3D.create(
		from_position,
		to_position
	)

	query.exclude = [get_rid()]
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var result := (
		get_world_3d()
		.direct_space_state
		.intersect_ray(query)
	)

	if result.is_empty():
		return true

	var collider = result.get("collider")

	if collider == player:
		return true

	if collider is Node and collider.is_in_group("player"):
		return true

	return false


# ============================================================
# IDLE
# ============================================================

func _process_idle() -> void:
	_stop_horizontal_motion()

	_play_animation(
		_get_combat_idle_animation(),
		0.15,
		1.0
	)

	if not has_racket:
		if (
			racket_pickup_position != null
			and is_instance_valid(racket_pickup_position)
		):
			_set_state(State.SEEK_RACKET)
			return

		if player_visible:
			_set_state(State.MOVE_TO_PLAYER)

		return

	if player_visible:
		_set_state(State.MOVE_TO_PLAYER)
		return

	if player_memory_timer > 0.0:
		_set_state(State.MOVE_TO_PLAYER)


# ============================================================
# SEEK RACKET
# ============================================================

func _process_seek_racket(delta: float) -> void:
	if has_racket:
		_resume_after_action()
		return

	if (
		racket_pickup_position == null
		or not is_instance_valid(racket_pickup_position)
	):
		_find_racket_target()

	if racket_pickup_position == null:
		_set_state(State.IDLE)
		return

	if player_visible:
		var player_distance := (
			global_position
			.distance_to(player.global_position)
		)

		if (
			ball_cooldown <= 0.0
			and player_distance >= minimum_ball_distance
			and player_distance <= maximum_ball_distance
		):
			start_ball_attack()
			return

	var target_position := racket_pickup_position.global_position

	var direct_distance := global_position.distance_to(target_position)

	if direct_distance <= racket_pickup_distance:
		_start_racket_pickup()
		return

	var direction := _get_navigation_direction(target_position)

	if direction.length_squared() <= 0.0001:
		_stop_horizontal_motion()
		return

	_rotate_toward(direction, delta)

	if combat_phase >= 2:
		var racket_run_speed := phase_2_racket_run_speed

		if combat_phase >= 3:
			racket_run_speed = phase_3_racket_run_speed

		velocity.x = direction.x * racket_run_speed
		velocity.z = direction.z * racket_run_speed

		_play_animation(
			ANIM_RUN,
			0.12,
			1.0
		)

		return

	velocity.x = direction.x * phase_1_walk_speed
	velocity.z = direction.z * phase_1_walk_speed

	_play_animation(
		ANIM_WALK,
		0.15,
		1.0
	)


# ============================================================
# PICKUP RACKET
# ============================================================

func _start_racket_pickup() -> void:
	if has_racket:
		return

	if (
		racket_pickup_position == null
		or not is_instance_valid(racket_pickup_position)
	):
		return

	state = State.PICKUP_RACKET
	_set_action_shield(true)

	_invalidate_navigation_target()
	_stop_horizontal_motion()

	var snap_position := racket_pickup_position.global_position
	var new_position := global_position

	new_position.x = snap_position.x
	new_position.z = snap_position.z

	global_position = new_position
	rotation.y = racket_pickup_position.global_rotation.y

	racket_pickup_done = false

	_play_animation(
		ANIM_RACKET_PICKUP,
		0.10,
		racket_pickup_animation_speed
	)


func _process_pickup_racket() -> void:
	_stop_horizontal_motion()

	if racket_pickup_done or animation_player == null:
		return

	var animation_length := animation_player.current_animation_length

	if animation_length <= 0.0:
		return

	var normalized_position := (
		animation_player.current_animation_position
		/ animation_length
	)

	if normalized_position < racket_pickup_fraction:
		return

	_complete_racket_pickup()


func _complete_racket_pickup() -> void:
	if racket_pickup_done:
		return

	racket_pickup_done = true

	if (
		racket_target != null
		and is_instance_valid(racket_target)
	):
		racket_target.remove_from_group(RACKET_TARGET_GROUP)
		racket_target.visible = false
		racket_target.queue_free()

	racket_target = null
	racket_pickup_position = null

	set_has_racket(true)


# ============================================================
# MOVE TO PLAYER
# ============================================================

func _process_move_to_player(delta: float) -> void:
	if player == null:
		_set_state(State.IDLE)
		return

	if (
		not has_racket
		and racket_pickup_position != null
		and is_instance_valid(racket_pickup_position)
	):
		_set_state(State.SEEK_RACKET)
		return

	if player_visible:
		var visible_distance := (
			global_position
			.distance_to(player.global_position)
		)

		if has_racket:
			if _try_racket_attack(visible_distance):
				return
		else:
			if (
				ball_cooldown <= 0.0
				and visible_distance >= minimum_ball_distance
				and visible_distance <= maximum_ball_distance
			):
				start_ball_attack()
				return

	var target_position := last_known_player_position

	if player_visible:
		target_position = player.global_position

	var direct_distance := global_position.distance_to(target_position)

	if (
		not player_visible
		and direct_distance <= last_position_reached_distance
	):
		_stop_horizontal_motion()

		if has_racket:
			_start_search_player()
		else:
			_set_state(State.IDLE)

		return

	if (
		not player_visible
		and player_memory_timer <= 0.0
	):
		if has_racket:
			_start_search_player()
		else:
			_set_state(State.IDLE)

		return

	var direction := _get_navigation_direction(target_position)

	if direction.length_squared() <= 0.0001:
		_stop_horizontal_motion()

		if not player_visible and has_racket:
			_start_search_player()

		return

	if player_visible:
		if (
			combat_phase == 3
			and direct_distance > phase_3_run_distance
		):
			velocity.x = direction.x * phase_3_run_speed
			velocity.z = direction.z * phase_3_run_speed

			_rotate_toward(direction, delta)

			_play_animation(
				ANIM_RUN,
				0.12,
				1.0
			)

			return

		if (
			has_racket
			and direct_distance <= preferred_melee_distance
		):
			_stop_horizontal_motion()
			_face_player(delta)

			if melee_cooldown <= 0.0:
				_start_melee_attack()

			return

		if (
			not has_racket
			and direct_distance <= preferred_ball_distance
		):
			_stop_horizontal_motion()
			_face_player(delta)
			return

	var speed := _get_walk_speed()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	_rotate_toward(direction, delta)

	var movement_animation := ANIM_WALK

	if has_racket:
		movement_animation = ANIM_RACKET_WALK

	_play_animation(
		movement_animation,
		0.15,
		1.0
	)


# ============================================================
# RACKET ATTACK DECISION
# ============================================================

func _try_racket_attack(distance: float) -> bool:
	# With the racket Bruno's PRIMARY attack is the air wave.
	# The explosive tennis ball becomes the rarer special attack.
	#
	# Without the racket this function is never used, so Bruno keeps
	# his original tennis-ball-only behaviour.

	if melee_cooldown > 0.0:
		return false

	if distance > maximum_racket_wave_distance:
		return false

	var explosive_ball_available: bool = (
		ball_cooldown <= 0.0
		and distance >= minimum_ball_distance
		and distance <= maximum_ball_distance
	)

	if (
		explosive_ball_available
		and rng.randf() <= _get_explosive_ball_chance()
	):
		start_ball_attack()
		return true

	_start_melee_attack()
	return true


# ============================================================
# BALL ATTACK
# ============================================================

func start_ball_attack() -> void:
	if state == State.BALL_ATTACK:
		return

	if not player_visible or player == null:
		return

	_invalidate_navigation_target()

	if has_racket:
		burst_remaining = 1
	else:
		burst_remaining = _choose_normal_burst_count()

	_start_next_ball_in_burst()


func _start_next_ball_in_burst() -> void:
	if burst_remaining <= 0:
		_finish_ball_burst()
		return

	if not player_visible:
		burst_remaining = 0
		_finish_ball_burst()
		return

	burst_remaining -= 1
	state = State.BALL_ATTACK
	_set_action_shield(true)

	_stop_horizontal_motion()

	ball_released = false
	cast_elapsed = 0.0

	_face_player(1.0)

	if has_racket:
		current_ball_animation = ANIM_RACKET_BALL_CAST
	else:
		current_ball_animation = ANIM_BALL_CAST

	_play_animation(
		current_ball_animation,
		0.04,
		_get_cast_animation_speed()
	)


func _process_ball_attack(delta: float) -> void:
	_stop_horizontal_motion()

	if not player_visible:
		burst_remaining = 0
		_finish_ball_burst()
		return

	_face_player(delta)

	cast_elapsed += delta

	var release_time := (
		base_ball_release_time
		/ _get_cast_animation_speed()
	)

	if (
		not ball_released
		and cast_elapsed >= release_time
	):
		ball_released = true
		_release_tennis_ball()


func _release_tennis_ball() -> void:
	if tennis_ball_projectile_scene == null:
		return

	if player == null or not player_visible:
		return

	var projectile := tennis_ball_projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)

	var start_position := tennis_ball_spawn.global_position

	var target_position := (
		player.global_position
		+ Vector3.UP * ball_target_height
	)

	var flight_time := _get_normal_ball_flight_time()
	var gravity_override := -1.0

	if has_racket:
		if racket_ball_spawn != null:
			start_position = racket_ball_spawn.global_position
		else:
			start_position = racket_visual.global_position

		target_position = _get_explosive_ground_target()
		flight_time = _get_explosive_ball_flight_time()
		gravity_override = explosive_ball_gravity

	if projectile.has_method("launch"):
		projectile.launch(
			start_position,
			target_position,
			ball_damage,
			has_racket,
			self,
			flight_time,
			gravity_override
		)
	else:
		projectile.queue_free()


func _get_explosive_ground_target() -> Vector3:
	if player == null:
		return global_position

	var ray_start := player.global_position + Vector3.UP * 2.0
	var ray_end := player.global_position + Vector3.DOWN * 4.0

	var query := PhysicsRayQueryParameters3D.create(
		ray_start,
		ray_end
	)

	query.collide_with_areas = false
	query.collide_with_bodies = true

	if player is CollisionObject3D:
		query.exclude = [
			(player as CollisionObject3D).get_rid()
		]

	var result := (
		get_world_3d()
		.direct_space_state
		.intersect_ray(query)
	)

	if not result.is_empty():
		return result.get(
			"position",
			player.global_position
		)

	return player.global_position


func _finish_ball_burst() -> void:
	burst_remaining = 0
	_set_action_shield(false)

	ball_cooldown = rng.randf_range(
		_get_ball_cooldown_min(),
		_get_ball_cooldown_max()
	)

	_start_post_attack_idle_pause()


func _choose_normal_burst_count() -> int:
	var roll := rng.randf()

	match combat_phase:
		1:
			if roll < 0.55:
				return 1
			if roll < 0.90:
				return 2
			return 3
		2:
			if roll < 0.30:
				return 1
			if roll < 0.75:
				return 2
			return 3
		3:
			if roll < 0.10:
				return 1
			if roll < 0.50:
				return 2
			return 3

	return 1


# ============================================================
# MELEE
# ============================================================

func _start_melee_attack() -> void:
	if state == State.MELEE_ATTACK:
		return

	if not player_visible:
		return

	state = State.MELEE_ATTACK
	_set_action_shield(true)

	_invalidate_navigation_target()
	_stop_horizontal_motion()

	_face_player(1.0)

	melee_hit_done = false

	var charged_chance := 0.25

	match combat_phase:
		2:
			charged_chance = 0.40
		3:
			charged_chance = 0.55

	if rng.randf() <= charged_chance:
		current_melee_animation = ANIM_CHARGED_SLASH
	else:
		current_melee_animation = ANIM_LEFT_SLASH

	_play_animation(
		current_melee_animation,
		0.06,
		_get_melee_animation_speed()
	)


func _process_melee_attack(delta: float) -> void:
	_stop_horizontal_motion()

	if player_visible:
		_face_player(delta)

	if melee_hit_done or animation_player == null:
		return

	var animation_length := animation_player.current_animation_length

	if animation_length <= 0.0:
		return

	var normalized_position := (
		animation_player.current_animation_position
		/ animation_length
	)

	var hit_fraction := left_slash_hit_fraction

	if current_melee_animation == ANIM_CHARGED_SLASH:
		hit_fraction = charged_slash_hit_fraction

	if normalized_position < hit_fraction:
		return

	melee_hit_done = true

	# Da questo istante l'onda è partita: Bruno torna vulnerabile
	# anche se l'animazione della racchetta deve ancora terminare.
	_set_action_shield(false)

	_apply_melee_wind_attack()


func _apply_melee_wind_attack() -> void:
	var attack_range := left_slash_range
	var attack_damage := left_slash_damage

	if current_melee_animation == ANIM_CHARGED_SLASH:
		attack_range = charged_slash_range
		attack_damage = charged_slash_damage

	if melee_wave_enabled:
		if _spawn_melee_wave(
			attack_damage
		):
			return

	# SAFE fallback:
	# if the VFX scene is missing or cannot be started,
	# Bruno still deals the old direct melee damage.
	_apply_melee_fallback_damage(
		attack_range,
		attack_damage
	)


# ============================================================
# MELEE WAVE
# ============================================================

func _spawn_melee_wave(
	attack_damage: int
) -> bool:
	if melee_wave_scene == null:
		push_warning(
			"BrunoBuozzi: melee_wave_scene non assegnata."
		)
		return false

	var world := get_tree().current_scene

	if world == null:
		return false

	var instance := melee_wave_scene.instantiate()

	if not instance is Node3D:
		push_warning(
			"BrunoBuozzi: la scena Melee Wave non ha root Node3D."
		)

		instance.queue_free()
		return false

	var wave := instance as Node3D

	# Set gameplay properties before starting the wave.
	# The visual timing/scale/distance remain controlled by the
	# bruno_melee_banana3d.tscn Inspector values.
	if _object_has_property(
		wave,
		"damage_enabled"
	):
		wave.set(
			"damage_enabled",
			true
		)

	if _object_has_property(
		wave,
		"damage_amount"
	):
		wave.set(
			"damage_amount",
			attack_damage
		)

	world.add_child(
		wave
	)

	var spawn_position := _get_melee_wave_spawn_position()

	var direction := _get_melee_wave_direction(
		spawn_position
	)

	if not wave.has_method(
		"start_wave"
	):
		push_warning(
			"BrunoBuozzi: Melee Wave senza metodo start_wave()."
		)

		wave.queue_free()
		return false

	wave.call(
		"start_wave",
		spawn_position,
		direction,
		self
	)

	return true


func _get_melee_wave_spawn_position() -> Vector3:
	if (
		racket_ball_spawn != null
		and is_instance_valid(
			racket_ball_spawn
		)
	):
		return racket_ball_spawn.global_position

	var forward := global_transform.basis.z
	forward.y = 0.0

	if forward.length_squared() <= 0.0001:
		forward = Vector3.BACK

	forward = forward.normalized()

	return (
		global_position
		+ Vector3.UP
			* melee_wave_spawn_height_fallback
		+ forward
			* melee_wave_forward_offset_fallback
	)


func _get_melee_wave_direction(
	spawn_position: Vector3
) -> Vector3:
	if (
		player != null
		and is_instance_valid(
			player
		)
	):
		var to_player := (
			player.global_position
			- spawn_position
		)

		to_player.y = 0.0

		if to_player.length_squared() > 0.0001:
			return to_player.normalized()

	var forward := global_transform.basis.z
	forward.y = 0.0

	if forward.length_squared() <= 0.0001:
		forward = Vector3.BACK

	return forward.normalized()


func _apply_melee_fallback_damage(
	attack_range: float,
	attack_damage: int
) -> void:
	if player == null or not player_visible:
		return

	var to_player := (
		player.global_position
		- global_position
	)

	to_player.y = 0.0

	var distance := to_player.length()

	if (
		distance > attack_range
		or distance <= 0.001
	):
		return

	var forward := global_transform.basis.z
	forward.y = 0.0

	if forward.length_squared() <= 0.0001:
		return

	forward = forward.normalized()

	var direction := to_player.normalized()
	var facing_dot := forward.dot(
		direction
	)

	if facing_dot < melee_cone_dot:
		return

	if player.has_method(
		"take_damage"
	):
		player.take_damage(
			attack_damage
		)


func _object_has_property(
	object: Object,
	property_name: StringName
) -> bool:
	if object == null:
		return false

	for property_info: Dictionary in (
		object.get_property_list()
	):
		var name_value: Variant = property_info.get(
			"name",
			""
		)

		if StringName(
			String(name_value)
		) == property_name:
			return true

	return false


# ============================================================
# SEARCH PLAYER
# ============================================================

func _start_search_player() -> void:
	if state == State.SEARCH_PLAYER:
		return

	search_timer = search_duration
	_set_state(State.SEARCH_PLAYER)


func _process_search_player(delta: float) -> void:
	_stop_horizontal_motion()

	if player_visible:
		_set_state(State.MOVE_TO_PLAYER)
		return

	search_timer -= delta
	rotation.y += search_rotation_speed * delta

	_play_animation(
		ANIM_IDLE,
		0.15,
		1.0
	)

	if search_timer > 0.0:
		return

	player_memory_timer = 0.0
	_set_state(State.IDLE)


# ============================================================
# RESUME
# ============================================================

func _get_post_attack_idle_min() -> float:
	match combat_phase:
		1:
			return phase_1_post_attack_idle_min
		2:
			return phase_2_post_attack_idle_min
		3:
			return phase_3_post_attack_idle_min

	return 0.0


func _get_post_attack_idle_max() -> float:
	match combat_phase:
		1:
			return phase_1_post_attack_idle_max
		2:
			return phase_2_post_attack_idle_max
		3:
			return phase_3_post_attack_idle_max

	return 0.0


func _start_post_attack_idle_pause() -> void:
	if state == State.DEAD:
		return

	var idle_min := maxf(
		_get_post_attack_idle_min(),
		0.0
	)

	var idle_max := maxf(
		_get_post_attack_idle_max(),
		idle_min
	)

	if idle_max <= 0.0:
		_resume_after_action()
		return

	post_attack_idle_timer = rng.randf_range(
		idle_min,
		idle_max
	)

	state = State.IDLE
	_stop_horizontal_motion()

	_play_animation(
		_get_combat_idle_animation(),
		0.12,
		1.0
	)


func _resume_after_idle_pause() -> void:
	if state == State.DEAD:
		return

	if not has_racket:
		if (
			racket_pickup_position != null
			and is_instance_valid(racket_pickup_position)
		):
			_set_state(State.SEEK_RACKET)
			return

	if player_visible or player_memory_timer > 0.0:
		_set_state(State.MOVE_TO_PLAYER)
		return

	if has_racket:
		_start_search_player()
		return

	_set_state(State.IDLE)


func _resume_after_action() -> void:
	if state == State.DEAD:
		return

	if not has_racket:
		if (
			racket_pickup_position != null
			and is_instance_valid(racket_pickup_position)
		):
			_set_state(State.SEEK_RACKET)
			return

	if player_visible:
		_set_state(State.MOVE_TO_PLAYER)
		return

	if player_memory_timer > 0.0:
		_set_state(State.MOVE_TO_PLAYER)
		return

	if has_racket:
		_start_search_player()
		return

	_set_state(State.IDLE)


# ============================================================
# PHASE PARAMETERS
# ============================================================

func _get_walk_speed() -> float:
	match combat_phase:
		1:
			return phase_1_walk_speed
		2:
			return phase_2_walk_speed
		3:
			return phase_3_walk_speed

	return phase_1_walk_speed


func _get_normal_ball_flight_time() -> float:
	match combat_phase:
		1:
			return phase_1_ball_flight_time
		2:
			return phase_2_ball_flight_time
		3:
			return phase_3_ball_flight_time

	return phase_1_ball_flight_time


func _get_explosive_ball_flight_time() -> float:
	match combat_phase:
		1:
			return phase_1_explosive_flight_time
		2:
			return phase_2_explosive_flight_time
		3:
			return phase_3_explosive_flight_time

	return phase_1_explosive_flight_time


func _get_cast_animation_speed() -> float:
	match combat_phase:
		1:
			return phase_1_cast_speed
		2:
			return phase_2_cast_speed
		3:
			return phase_3_cast_speed

	return 1.0


func _get_explosive_ball_chance() -> float:
	match combat_phase:
		1:
			return phase_1_explosive_ball_chance
		2:
			return phase_2_explosive_ball_chance
		3:
			return phase_3_explosive_ball_chance

	return phase_1_explosive_ball_chance


func _get_ball_cooldown_min() -> float:
	match combat_phase:
		1:
			return phase_1_ball_cooldown_min
		2:
			return phase_2_ball_cooldown_min
		3:
			return phase_3_ball_cooldown_min

	return phase_1_ball_cooldown_min


func _get_ball_cooldown_max() -> float:
	match combat_phase:
		1:
			return phase_1_ball_cooldown_max
		2:
			return phase_2_ball_cooldown_max
		3:
			return phase_3_ball_cooldown_max

	return phase_1_ball_cooldown_max


func _get_melee_animation_speed() -> float:
	match combat_phase:
		1:
			return phase_1_melee_animation_speed
		2:
			return phase_2_melee_animation_speed
		3:
			return phase_3_melee_animation_speed

	return 1.0


func _get_melee_cooldown_min() -> float:
	match combat_phase:
		1:
			return phase_1_melee_cooldown_min
		2:
			return phase_2_melee_cooldown_min
		3:
			return phase_3_melee_cooldown_min

	return phase_1_melee_cooldown_min


func _get_melee_cooldown_max() -> float:
	match combat_phase:
		1:
			return phase_1_melee_cooldown_max
		2:
			return phase_2_melee_cooldown_max
		3:
			return phase_3_melee_cooldown_max

	return phase_1_melee_cooldown_max


# ============================================================
# RACKET
# ============================================================

func set_has_racket(value: bool) -> void:
	has_racket = value
	_sync_racket_visual()


func _sync_racket_visual() -> void:
	if racket_visual == null:
		return

	racket_visual.visible = has_racket


func _get_combat_idle_animation() -> StringName:
	if has_racket:
		return ANIM_RACKET_IDLE

	return ANIM_IDLE


# ============================================================
# STATE
# ============================================================

func _set_state(new_state: State) -> void:
	if state == new_state:
		return

	var previous_state := state
	state = new_state

	if boss_movement_debug:
		print(
			"[BOSS MOVE DEBUG] STATE ",
			_boss_state_name(previous_state),
			" -> ",
			_boss_state_name(state),
			" | pos=", global_position,
			" vel=", velocity,
			" player_visible=", player_visible,
			" has_racket=", has_racket
		)

	if (
		state == State.MOVE_TO_PLAYER
		or state == State.SEEK_RACKET
	):
		_invalidate_navigation_target()

	match state:
		State.IDLE:
			_stop_horizontal_motion()

			_play_animation(
				_get_combat_idle_animation(),
				0.15,
				1.0
			)
		State.MOVE_TO_PLAYER:
			pass
		State.SEEK_RACKET:
			pass
		State.PICKUP_RACKET:
			pass
		State.BALL_ATTACK:
			pass
		State.MELEE_ATTACK:
			pass
		State.SEARCH_PLAYER:
			_stop_horizontal_motion()
		State.DOWN:
			_stop_horizontal_motion()
		State.GETTING_UP:
			_stop_horizontal_motion()
		State.DEAD:
			_stop_horizontal_motion()


# ============================================================
# ROTATION
# ============================================================

func _rotate_toward(direction: Vector3, delta: float) -> void:
	if direction.length_squared() <= 0.0001:
		return

	var target_yaw := atan2(
		direction.x,
		direction.z
	)

	rotation.y = lerp_angle(
		rotation.y,
		target_yaw,
		rotation_speed * delta
	)


func _face_player(delta: float) -> void:
	if player == null:
		return

	var direction := player.global_position - global_position
	direction.y = 0.0

	if direction.length_squared() <= 0.0001:
		return

	_rotate_toward(
		direction.normalized(),
		delta
	)


func _stop_horizontal_motion() -> void:
	velocity.x = 0.0
	velocity.z = 0.0


# ============================================================
# ANIMATION
# ============================================================

func _play_animation(
	animation_name: StringName,
	blend_time: float = 0.15,
	playback_speed: float = 1.0
) -> void:
	if animation_player == null:
		return

	if not animation_player.has_animation(animation_name):
		push_warning(
			"BrunoBuozzi: animazione non trovata: "
			+ String(animation_name)
		)
		return

	animation_player.speed_scale = playback_speed

	if (
		animation_player.current_animation == animation_name
		and animation_player.is_playing()
	):
		return

	animation_player.play(
		animation_name,
		blend_time
	)


func _on_animation_finished(animation_name: StringName) -> void:
	if hit_reaction_active:
		if animation_name == current_hit_reaction_animation:
			hit_reaction_active = false
			current_hit_reaction_animation = &""
			_set_action_shield(false)

			hit_reaction_cooldown = maxf(
				hit_reaction_cooldown_time,
				0.0
			)

			# La hit reaction non introduce una pausa idle:
			# Bruno torna subito alla sua AI. I colpi ricevuti
			# durante il cooldown fanno comunque danno, ma non
			# possono riavviare immediatamente un'altra reaction.
			_resume_after_action()
			return

	if state == State.DEAD:
		if (
			animation_name == ANIM_DEATH_FRONT
			or animation_name == ANIM_DEATH_BACK
		):
			_settle_dead_visual()
		return

	if state == State.DOWN:
		if animation_name != ANIM_FALLING_DOWN:
			return

		# Nessuna pausa: appena termina caduta parte subito rialzati.
		_start_getting_up()
		return

	if state == State.GETTING_UP:
		if animation_name != ANIM_STAND_UP:
			return

		_set_model_visual_y(
			cinematic_model_base_position.y
		)

		_finish_phase_transition()
		return

	if state == State.PICKUP_RACKET:
		if animation_name != ANIM_RACKET_PICKUP:
			return

		if not racket_pickup_done:
			_complete_racket_pickup()

		_set_action_shield(false)
		_resume_after_action()
		return

	if state == State.BALL_ATTACK:
		if animation_name != current_ball_animation:
			return

		ball_released = false
		cast_elapsed = 0.0
		current_ball_animation = &""

		if burst_remaining > 0 and player_visible:
			_start_next_ball_in_burst()
			return

		_finish_ball_burst()
		return

	if state == State.MELEE_ATTACK:
		if (
			animation_name != ANIM_LEFT_SLASH
			and animation_name != ANIM_CHARGED_SLASH
		):
			return

		melee_hit_done = false
		current_melee_animation = &""
		_set_action_shield(false)

		melee_cooldown = rng.randf_range(
			_get_melee_cooldown_min(),
			_get_melee_cooldown_max()
		)

		_start_post_attack_idle_pause()


# ============================================================
# BOSS BAR
# ============================================================

func _create_boss_bar() -> void:
	boss_bar_layer = CanvasLayer.new()
	boss_bar_layer.name = "BrunoBossBar"
	boss_bar_layer.layer = 100
	add_child(boss_bar_layer)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_bar_layer.add_child(root)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_TOP_WIDE)
	center.offset_top = 8.0
	center.offset_bottom = 82.0
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560.0, 64.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(panel)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.015, 0.015, 0.92)
	panel_style.border_color = Color(0.65, 0.05, 0.03, 1.0)
	panel_style.set_border_width_all(2)
	panel_style.corner_radius_top_left = 7
	panel_style.corner_radius_top_right = 7
	panel_style.corner_radius_bottom_left = 7
	panel_style.corner_radius_bottom_right = 7
	panel.add_theme_stylebox_override("panel", panel_style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_bottom", 5)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	margin.add_child(column)

	var title := Label.new()
	title.text = boss_name
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	column.add_child(title)

	var segments := HBoxContainer.new()
	segments.add_theme_constant_override("separation", 5)
	column.add_child(segments)

	boss_segment_1 = _create_boss_segment()
	boss_segment_2 = _create_boss_segment()
	boss_segment_3 = _create_boss_segment()

	segments.add_child(boss_segment_1)
	segments.add_child(boss_segment_2)
	segments.add_child(boss_segment_3)

	boss_hp_label = Label.new()
	boss_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_hp_label.add_theme_font_size_override("font_size", 11)
	column.add_child(boss_hp_label)

	boss_phase_label = Label.new()
	boss_phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_phase_label.add_theme_font_size_override("font_size", 10)
	column.add_child(boss_phase_label)


func _create_boss_segment() -> ProgressBar:
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(170.0, 12.0)

	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.10, 0.03, 0.03, 1.0)
	background.corner_radius_top_left = 3
	background.corner_radius_top_right = 3
	background.corner_radius_bottom_left = 3
	background.corner_radius_bottom_right = 3
	bar.add_theme_stylebox_override("background", background)

	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.82, 0.04, 0.025, 1.0)
	fill.corner_radius_top_left = 3
	fill.corner_radius_top_right = 3
	fill.corner_radius_bottom_left = 3
	fill.corner_radius_bottom_right = 3
	bar.add_theme_stylebox_override("fill", fill)

	return bar


func _update_boss_bar() -> void:
	if boss_bar_layer == null:
		return

	var segment := _get_segment_health()

	var segment_1_value := clampi(
		health,
		0,
		segment
	)

	var segment_2_value := clampi(
		health - segment,
		0,
		segment
	)

	var segment_3_value := clampi(
		health - segment * 2,
		0,
		segment
	)

	if boss_segment_1 != null:
		boss_segment_1.max_value = segment
		boss_segment_1.value = segment_1_value

	if boss_segment_2 != null:
		boss_segment_2.max_value = segment
		boss_segment_2.value = segment_2_value

	if boss_segment_3 != null:
		boss_segment_3.max_value = segment
		boss_segment_3.value = segment_3_value

	if boss_hp_label != null:
		boss_hp_label.text = "%d / %d" % [health, max_health]

	if boss_phase_label != null:
		boss_phase_label.text = "FASE %d" % combat_phase
