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


# ============================================================
# RACKET PICKUP
# ============================================================

@export_category("Racket Pickup")

@export var racket_pickup_distance: float = 0.25

# Verificato visivamente.
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


# ============================================================
# NODES
# ============================================================

@onready var animation_player: AnimationPlayer = (
	$Meshy_AI_Mutated_Tennis_Player_All_Animations/AnimationPlayer
)

@onready var tennis_ball_spawn: Marker3D = (
	$Meshy_AI_Mutated_Tennis_Player_All_Animations/target_character/GeneralSkeleton/BoneAttachment3D/TennisBallSpawn
)

@onready var racket_visual: Node3D = (
	$Meshy_AI_Mutated_Tennis_Player_All_Animations/target_character/GeneralSkeleton/BoneAttachment3D/Racket_Wilson_Blade
)

@onready var racket_ball_spawn: Marker3D = get_node_or_null(
	"Meshy_AI_Mutated_Tennis_Player_All_Animations/target_character/GeneralSkeleton/BoneAttachment3D/Racket_Wilson_Blade/RacketBallSpawn"
) as Marker3D


# ============================================================
# GENERAL STATE
# ============================================================

var player: CharacterBody3D = null

var racket_target: Node3D = null
var racket_pickup_position: Marker3D = null

var state: State = State.IDLE

var rng := RandomNumberGenerator.new()


# ============================================================
# HEALTH STATE
# ============================================================

var health: int = 0

# 1, 2, 3.
# Indipendente da has_racket.
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
var burst_remaining: int = 0

var melee_cooldown: float = 0.0
var melee_hit_done: bool = false
var current_melee_animation: StringName = &""

var racket_pickup_done: bool = false


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

const ANIM_IDLE: StringName = &"Idle_8"
const ANIM_WALK: StringName = &"Casual_Walk"
const ANIM_RACKET_WALK: StringName = &"Spear_Walk"
const ANIM_RUN: StringName = &"Running"

const ANIM_BALL_CAST: StringName = &"mage_soell_cast_4"

const ANIM_LEFT_SLASH: StringName = &"Left_Slash"
const ANIM_CHARGED_SLASH: StringName = &"Charged_Slash"

const ANIM_RACKET_PICKUP: StringName = &"Male_Bend_Over_Pick_Up"

const ANIM_FALLING_DOWN: StringName = &"falling_down"
const ANIM_STAND_UP: StringName = &"Stand_Up7"

const ANIM_DEATH_FRONT: StringName = &"Shot_and_Fall_Backward"
const ANIM_DEATH_BACK: StringName = &"Shot_in_the_Back_and_Fall"


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	rng.randomize()

	health = max_health
	combat_phase = 1
	pending_combat_phase = 1

	player = (
		get_tree()
		.get_first_node_in_group("player")
		as CharacterBody3D
	)

	if animation_player == null:
		push_error(
			"BrunoBuozzi: AnimationPlayer non trovato."
		)
		return

	if tennis_ball_spawn == null:
		push_error(
			"BrunoBuozzi: TennisBallSpawn non trovato."
		)
		return

	if racket_visual == null:
		push_error(
			"BrunoBuozzi: racchetta in mano non trovata."
		)
		return

	animation_player.animation_finished.connect(
		_on_animation_finished
	)

	_sync_racket_visual()

	if not has_racket:
		_find_racket_target()

	if player != null:
		last_known_player_position = (
			player.global_position
		)

	_update_player_visibility()

	if show_boss_bar:
		_create_boss_bar()
		_update_boss_bar()

	_set_state(
		State.IDLE
	)

	if test_mode:
		_start_test_after_delay()


# ============================================================
# PHYSICS
# ============================================================

func _physics_process(delta: float) -> void:
	# Anche morto / a terra deve continuare a subire la gravità.
	if not is_on_floor():
		velocity += (
			get_gravity()
			* delta
		)

	if state == State.DEAD:
		_stop_horizontal_motion()
		move_and_slide()
		return

	if (
		state == State.DOWN
		or state == State.GETTING_UP
	):
		_stop_horizontal_motion()
		move_and_slide()
		return

	if player == null or not is_instance_valid(player):
		player = (
			get_tree()
			.get_first_node_in_group("player")
			as CharacterBody3D
		)

	if (
		not has_racket
		and (
			racket_target == null
			or not is_instance_valid(racket_target)
		)
	):
		_find_racket_target()

	_update_perception(
		delta
	)

	if ball_cooldown > 0.0:
		ball_cooldown -= delta

	if melee_cooldown > 0.0:
		melee_cooldown -= delta

	match state:
		State.IDLE:
			_process_idle()

		State.MOVE_TO_PLAYER:
			_process_move_to_player(
				delta
			)

		State.SEEK_RACKET:
			_process_seek_racket(
				delta
			)

		State.PICKUP_RACKET:
			_process_pickup_racket()

		State.BALL_ATTACK:
			_process_ball_attack(
				delta
			)

		State.MELEE_ATTACK:
			_process_melee_attack(
				delta
			)

		State.SEARCH_PLAYER:
			_process_search_player(
				delta
			)

		State.DOWN:
			pass

		State.GETTING_UP:
			pass

		State.DEAD:
			pass

	move_and_slide()


# ============================================================
# TEST START
# ============================================================

func _start_test_after_delay() -> void:
	await get_tree().create_timer(
		test_start_delay
	).timeout

	if not is_inside_tree():
		return

	if state == State.DEAD:
		return

	if (
		not has_racket
		and racket_pickup_position != null
		and is_instance_valid(racket_pickup_position)
	):
		_set_state(
			State.SEEK_RACKET
		)
		return

	if player_visible:
		_set_state(
			State.MOVE_TO_PLAYER
		)


# ============================================================
# HEALTH / DAMAGE
# ============================================================

func take_bullet_hit(
	base_damage: int,
	hit_point: Vector3
) -> void:
	if state == State.DEAD:
		return

	if invulnerable:
		return

	var is_headshot := (
		hit_point.y
		>= global_position.y
		+ headshot_height
	)

	var final_damage := (
		base_damage
	)

	if is_headshot:
		final_damage = maxi(
			1,
			roundi(
				float(base_damage)
				* headshot_multiplier
			)
		)

	_apply_damage(
		final_damage
	)


func take_damage(
	amount: int
) -> void:
	_apply_damage(
		amount
	)


func _apply_damage(
	amount: int
) -> void:
	if state == State.DEAD:
		return

	if invulnerable:
		return

	if amount <= 0:
		return

	health -= amount
	health = maxi(
		health,
		0
	)

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

	var segment_health := (
		_get_segment_health()
	)

	if (
		combat_phase == 1
		and health <= segment_health * 2
	):
		_start_phase_transition(
			2
		)
		return

	if (
		combat_phase == 2
		and health <= segment_health
	):
		_start_phase_transition(
			3
		)
		return


func _get_segment_health() -> int:
	return maxi(
		1,
		ceili(
			float(max_health)
			/ 3.0
		)
	)


func _start_phase_transition(
	new_phase: int
) -> void:
	if phase_transition_active:
		return

	if state == State.DEAD:
		return

	phase_transition_active = true
	invulnerable = true

	pending_combat_phase = clampi(
		new_phase,
		1,
		3
	)

	state = State.DOWN

	_stop_horizontal_motion()

	burst_remaining = 0
	ball_released = false
	cast_elapsed = 0.0

	melee_hit_done = false
	current_melee_animation = &""

	_play_animation(
		ANIM_FALLING_DOWN,
		0.08,
		1.0
	)


func _start_getting_up() -> void:
	state = State.GETTING_UP

	_stop_horizontal_motion()

	_play_animation(
		ANIM_STAND_UP,
		0.08,
		1.0
	)


func _finish_phase_transition() -> void:
	combat_phase = (
		pending_combat_phase
	)

	phase_transition_active = false
	invulnerable = false

	_update_boss_bar()

	_resume_after_action()


func _die() -> void:
	if state == State.DEAD:
		return

	state = State.DEAD
	invulnerable = true
	phase_transition_active = false

	health = 0

	_stop_horizontal_motion()

	burst_remaining = 0
	ball_released = false
	melee_hit_done = true

	_update_boss_bar()

	var death_animation := (
		ANIM_DEATH_FRONT
	)

	if _player_is_behind_bruno():
		death_animation = (
			ANIM_DEATH_BACK
		)

	_play_animation(
		death_animation,
		0.08,
		1.0
	)


func _player_is_behind_bruno() -> bool:
	if player == null:
		return false

	var to_player := (
		player.global_position
		- global_position
	)

	to_player.y = 0.0

	if to_player.length_squared() <= 0.0001:
		return false

	to_player = (
		to_player.normalized()
	)

	# Bruno guarda lungo +Z.
	var forward := (
		global_transform.basis.z
	)

	forward.y = 0.0

	if forward.length_squared() <= 0.0001:
		return false

	forward = (
		forward.normalized()
	)

	return (
		forward.dot(
			to_player
		)
		< 0.0
	)


# ============================================================
# RACKET TARGET
# ============================================================

func _find_racket_target() -> void:
	var node := (
		get_tree()
		.get_first_node_in_group(
			RACKET_TARGET_GROUP
		)
	)

	if not node is Node3D:
		racket_target = null
		racket_pickup_position = null
		return

	racket_target = (
		node as Node3D
	)

	var marker := (
		racket_target
		.get_node_or_null(
			"PickupPosition"
		)
	)

	if marker is Marker3D:
		racket_pickup_position = (
			marker as Marker3D
		)
	else:
		racket_pickup_position = null

		push_error(
			"BrunoBuozzi: PickupPosition non trovato dentro BrunoRacketPickup."
		)


# ============================================================
# PERCEPTION
# ============================================================

func _update_perception(
	delta: float
) -> void:
	if player == null:
		player_visible = false
		return

	_update_player_visibility()

	if player_visible:
		last_known_player_position = (
			player.global_position
		)

		player_memory_timer = (
			player_memory_time
		)
	else:
		if player_memory_timer > 0.0:
			player_memory_timer -= delta


func _update_player_visibility() -> void:
	player_visible = (
		_has_line_of_sight_to_player()
	)


func _has_line_of_sight_to_player() -> bool:
	if player == null:
		return false

	var distance := (
		global_position
		.distance_to(
			player.global_position
		)
	)

	if distance > detection_distance:
		return false

	var from_position := (
		global_position
		+ Vector3.UP
		* eye_height
	)

	var to_position := (
		player.global_position
		+ Vector3.UP
		* player_target_height
	)

	var query := (
		PhysicsRayQueryParameters3D.create(
			from_position,
			to_position
		)
	)

	query.exclude = [
		get_rid()
	]

	query.collide_with_areas = false
	query.collide_with_bodies = true

	var result := (
		get_world_3d()
		.direct_space_state
		.intersect_ray(
			query
		)
	)

	if result.is_empty():
		return true

	var collider = (
		result.get(
			"collider"
		)
	)

	if collider == player:
		return true

	if (
		collider is Node
		and collider.is_in_group(
			"player"
		)
	):
		return true

	return false


# ============================================================
# IDLE
# ============================================================

func _process_idle() -> void:
	_stop_horizontal_motion()

	_play_animation(
		ANIM_IDLE,
		0.15,
		1.0
	)

	if not has_racket:
		if (
			racket_pickup_position != null
			and is_instance_valid(
				racket_pickup_position
			)
		):
			_set_state(
				State.SEEK_RACKET
			)
			return

		if player_visible:
			_set_state(
				State.MOVE_TO_PLAYER
			)

		return

	if player_visible:
		_set_state(
			State.MOVE_TO_PLAYER
		)
		return

	if player_memory_timer > 0.0:
		_set_state(
			State.MOVE_TO_PLAYER
		)


# ============================================================
# SEEK RACKET
# ============================================================

func _process_seek_racket(
	delta: float
) -> void:
	if has_racket:
		_resume_after_action()
		return

	if (
		racket_pickup_position == null
		or not is_instance_valid(
			racket_pickup_position
		)
	):
		_find_racket_target()

	if racket_pickup_position == null:
		_set_state(
			State.IDLE
		)
		return

	if player_visible:
		var player_distance := (
			global_position
			.distance_to(
				player.global_position
			)
		)

		if (
			ball_cooldown <= 0.0
			and player_distance >= minimum_ball_distance
			and player_distance <= maximum_ball_distance
		):
			start_ball_attack()
			return

	var target_position := (
		racket_pickup_position
		.global_position
	)

	var direction := (
		target_position
		- global_position
	)

	direction.y = 0.0

	var distance := (
		direction.length()
	)

	if distance <= racket_pickup_distance:
		_start_racket_pickup()
		return

	if direction.length_squared() <= 0.0001:
		_stop_horizontal_motion()
		return

	direction = (
		direction.normalized()
	)

	if (
		combat_phase == 3
		and distance > phase_3_run_distance
	):
		velocity.x = (
			direction.x
			* phase_3_run_speed
		)

		velocity.z = (
			direction.z
			* phase_3_run_speed
		)

		_rotate_toward(
			direction,
			delta
		)

		_play_animation(
			ANIM_RUN,
			0.12,
			1.0
		)

		return

	var speed := (
		_get_walk_speed()
	)

	velocity.x = (
		direction.x
		* speed
	)

	velocity.z = (
		direction.z
		* speed
	)

	_rotate_toward(
		direction,
		delta
	)

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
		or not is_instance_valid(
			racket_pickup_position
		)
	):
		return

	state = State.PICKUP_RACKET

	_stop_horizontal_motion()

	var snap_position := (
		racket_pickup_position
		.global_position
	)

	global_position.x = (
		snap_position.x
	)

	global_position.z = (
		snap_position.z
	)

	rotation.y = (
		racket_pickup_position
		.global_rotation.y
	)

	racket_pickup_done = false

	_play_animation(
		ANIM_RACKET_PICKUP,
		0.10,
		racket_pickup_animation_speed
	)


func _process_pickup_racket() -> void:
	_stop_horizontal_motion()

	if racket_pickup_done:
		return

	if animation_player == null:
		return

	var animation_length := (
		animation_player
		.current_animation_length
	)

	if animation_length <= 0.0:
		return

	var normalized_position := (
		animation_player
		.current_animation_position
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
		and is_instance_valid(
			racket_target
		)
	):
		racket_target.remove_from_group(
			RACKET_TARGET_GROUP
		)

		racket_target.visible = false
		racket_target.queue_free()

	racket_target = null
	racket_pickup_position = null

	set_has_racket(
		true
	)


# ============================================================
# MOVE TO PLAYER
# ============================================================

func _process_move_to_player(
	delta: float
) -> void:
	if player == null:
		_set_state(
			State.IDLE
		)
		return

	if (
		not has_racket
		and racket_pickup_position != null
		and is_instance_valid(
			racket_pickup_position
		)
	):
		_set_state(
			State.SEEK_RACKET
		)
		return

	if player_visible:
		var visible_distance := (
			global_position
			.distance_to(
				player.global_position
			)
		)

		if has_racket:
			if _try_racket_attack(
				visible_distance
			):
				return

		else:
			if (
				ball_cooldown <= 0.0
				and visible_distance >= minimum_ball_distance
				and visible_distance <= maximum_ball_distance
			):
				start_ball_attack()
				return

	var target_position := (
		last_known_player_position
	)

	if player_visible:
		target_position = (
			player.global_position
		)

	var direction := (
		target_position
		- global_position
	)

	direction.y = 0.0

	var distance := (
		direction.length()
	)

	if (
		not player_visible
		and distance
		<= last_position_reached_distance
	):
		_stop_horizontal_motion()

		if has_racket:
			_start_search_player()
		else:
			_set_state(
				State.IDLE
			)

		return

	if (
		not player_visible
		and player_memory_timer <= 0.0
	):
		if has_racket:
			_start_search_player()
		else:
			_set_state(
				State.IDLE
			)

		return

	if direction.length_squared() <= 0.0001:
		_stop_horizontal_motion()
		return

	direction = (
		direction.normalized()
	)

	if player_visible:
		if (
			combat_phase == 3
			and distance > phase_3_run_distance
		):
			velocity.x = (
				direction.x
				* phase_3_run_speed
			)

			velocity.z = (
				direction.z
				* phase_3_run_speed
			)

			_rotate_toward(
				direction,
				delta
			)

			_play_animation(
				ANIM_RUN,
				0.12,
				1.0
			)

			return

		if (
			has_racket
			and distance
			<= preferred_melee_distance
		):
			_stop_horizontal_motion()

			_face_player(
				delta
			)

			if melee_cooldown <= 0.0:
				_start_melee_attack()

			return

		if (
			not has_racket
			and distance
			<= preferred_ball_distance
		):
			_stop_horizontal_motion()

			_face_player(
				delta
			)

			return

	var speed := (
		_get_walk_speed()
	)

	velocity.x = (
		direction.x
		* speed
	)

	velocity.z = (
		direction.z
		* speed
	)

	_rotate_toward(
		direction,
		delta
	)

	var movement_animation := (
		ANIM_WALK
	)

	if has_racket:
		movement_animation = (
			ANIM_RACKET_WALK
		)

	_play_animation(
		movement_animation,
		0.15,
		1.0
	)


# ============================================================
# RACKET ATTACK DECISION
# ============================================================

func _try_racket_attack(
	distance: float
) -> bool:
	if (
		melee_cooldown <= 0.0
		and distance <= maximum_melee_distance
	):
		_start_melee_attack()
		return true

	var ball_available := (
		ball_cooldown <= 0.0
		and distance > maximum_melee_distance
		and distance >= minimum_ball_distance
		and distance <= maximum_ball_distance
	)

	if not ball_available:
		return false

	if (
		rng.randf()
		<= _get_explosive_ball_chance()
	):
		start_ball_attack()
		return true

	return false


# ============================================================
# BALL ATTACK
# ============================================================

func start_ball_attack() -> void:
	if state == State.BALL_ATTACK:
		return

	if not player_visible:
		return

	if player == null:
		return

	if has_racket:
		burst_remaining = 1
	else:
		burst_remaining = (
			_choose_normal_burst_count()
		)

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

	_stop_horizontal_motion()

	ball_released = false
	cast_elapsed = 0.0

	_face_player(
		1.0
	)

	_play_animation(
		ANIM_BALL_CAST,
		0.04,
		_get_cast_animation_speed()
	)


func _process_ball_attack(
	delta: float
) -> void:
	_stop_horizontal_motion()

	if not player_visible:
		burst_remaining = 0
		_finish_ball_burst()
		return

	_face_player(
		delta
	)

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

	if player == null:
		return

	if not player_visible:
		return

	var projectile := (
		tennis_ball_projectile_scene
		.instantiate()
	)

	get_tree().current_scene.add_child(
		projectile
	)

	var start_position := (
		tennis_ball_spawn
		.global_position
	)

	var target_position := (
		player.global_position
		+ Vector3.UP
		* ball_target_height
	)

	var flight_time := (
		_get_normal_ball_flight_time()
	)

	var gravity_override := -1.0

	if has_racket:
		if racket_ball_spawn != null:
			start_position = (
				racket_ball_spawn
				.global_position
			)
		else:
			start_position = (
				racket_visual
				.global_position
			)

		target_position = (
			_get_explosive_ground_target()
		)

		flight_time = (
			_get_explosive_ball_flight_time()
		)

		gravity_override = (
			explosive_ball_gravity
		)

	if projectile.has_method(
		"launch"
	):
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

	var ray_start := (
		player.global_position
		+ Vector3.UP * 2.0
	)

	var ray_end := (
		player.global_position
		+ Vector3.DOWN * 4.0
	)

	var query := (
		PhysicsRayQueryParameters3D.create(
			ray_start,
			ray_end
		)
	)

	query.collide_with_areas = false
	query.collide_with_bodies = true

	if player is CollisionObject3D:
		query.exclude = [
			(
				player
				as CollisionObject3D
			).get_rid()
		]

	var result := (
		get_world_3d()
		.direct_space_state
		.intersect_ray(
			query
		)
	)

	if not result.is_empty():
		return result.get(
			"position",
			player.global_position
		)

	return player.global_position


func _finish_ball_burst() -> void:
	burst_remaining = 0

	ball_cooldown = rng.randf_range(
		_get_ball_cooldown_min(),
		_get_ball_cooldown_max()
	)

	_resume_after_action()


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

	_stop_horizontal_motion()

	_face_player(
		1.0
	)

	melee_hit_done = false

	var charged_chance := 0.25

	match combat_phase:
		2:
			charged_chance = 0.40

		3:
			charged_chance = 0.55

	if rng.randf() <= charged_chance:
		current_melee_animation = (
			ANIM_CHARGED_SLASH
		)
	else:
		current_melee_animation = (
			ANIM_LEFT_SLASH
		)

	_play_animation(
		current_melee_animation,
		0.06,
		_get_melee_animation_speed()
	)


func _process_melee_attack(
	delta: float
) -> void:
	_stop_horizontal_motion()

	if player_visible:
		_face_player(
			delta
		)

	if melee_hit_done:
		return

	if animation_player == null:
		return

	var animation_length := (
		animation_player
		.current_animation_length
	)

	if animation_length <= 0.0:
		return

	var normalized_position := (
		animation_player
		.current_animation_position
		/ animation_length
	)

	var hit_fraction := (
		left_slash_hit_fraction
	)

	if (
		current_melee_animation
		== ANIM_CHARGED_SLASH
	):
		hit_fraction = (
			charged_slash_hit_fraction
		)

	if normalized_position < hit_fraction:
		return

	melee_hit_done = true

	_apply_melee_wind_attack()


func _apply_melee_wind_attack() -> void:
	var attack_range := (
		left_slash_range
	)

	var attack_damage := (
		left_slash_damage
	)

	if (
		current_melee_animation
		== ANIM_CHARGED_SLASH
	):
		attack_range = (
			charged_slash_range
		)

		attack_damage = (
			charged_slash_damage
		)

	_create_wind_slash_visual(
		attack_range
	)

	if player == null:
		return

	if not player_visible:
		return

	var to_player := (
		player.global_position
		- global_position
	)

	to_player.y = 0.0

	var distance := (
		to_player.length()
	)

	if distance > attack_range:
		return

	if distance <= 0.001:
		return

	var forward := (
		global_transform.basis.z
	)

	forward.y = 0.0

	forward = (
		forward.normalized()
	)

	var direction := (
		to_player.normalized()
	)

	var facing_dot := (
		forward.dot(
			direction
		)
	)

	if facing_dot < melee_cone_dot:
		return

	if player.has_method(
		"take_damage"
	):
		player.take_damage(
			attack_damage
		)


# ============================================================
# WIND VISUAL
# ============================================================

func _create_wind_slash_visual(
	attack_range: float
) -> void:
	var world := (
		get_tree().current_scene
	)

	if world == null:
		return

	var effect := Node3D.new()

	effect.name = (
		"BrunoWindSlash"
	)

	world.add_child(
		effect
	)

	var forward := (
		global_transform.basis.z
	)

	forward.y = 0.0

	if forward.length_squared() <= 0.0001:
		forward = Vector3.BACK

	forward = (
		forward.normalized()
	)

	effect.global_position = (
		global_position
		+ Vector3.UP * 1.15
		+ forward * 0.90
	)

	effect.global_rotation = (
		global_rotation
	)

	var mesh_instance := (
		MeshInstance3D.new()
	)

	effect.add_child(
		mesh_instance
	)

	var sphere := (
		SphereMesh.new()
	)

	sphere.radius = 0.50
	sphere.height = 1.0
	sphere.radial_segments = 24
	sphere.rings = 12

	mesh_instance.mesh = sphere

	mesh_instance.scale = Vector3(
		1.60,
		0.16,
		0.35
	)

	var material := (
		StandardMaterial3D.new()
	)

	material.transparency = (
		BaseMaterial3D.TRANSPARENCY_ALPHA
	)

	material.shading_mode = (
		BaseMaterial3D.SHADING_MODE_UNSHADED
	)

	material.albedo_color = Color(
		0.72,
		0.90,
		1.0,
		0.30
	)

	material.emission_enabled = true

	material.emission = Color(
		0.55,
		0.82,
		1.0,
		1.0
	)

	material.emission_energy_multiplier = 2.0

	mesh_instance.material_override = (
		material
	)

	var target_position := (
		effect.global_position
		+ forward
		* attack_range
	)

	var tween := (
		effect.create_tween()
	)

	tween.set_parallel(
		true
	)

	tween.set_trans(
		Tween.TRANS_QUAD
	)

	tween.set_ease(
		Tween.EASE_OUT
	)

	tween.tween_property(
		effect,
		"global_position",
		target_position,
		0.24
	)

	tween.tween_property(
		mesh_instance,
		"scale",
		Vector3(
			2.50,
			0.10,
			0.18
		),
		0.24
	)

	tween.tween_property(
		material,
		"albedo_color:a",
		0.0,
		0.24
	)

	tween.chain().tween_callback(
		effect.queue_free
	)


# ============================================================
# SEARCH PLAYER
# ============================================================

func _start_search_player() -> void:
	if state == State.SEARCH_PLAYER:
		return

	search_timer = (
		search_duration
	)

	_set_state(
		State.SEARCH_PLAYER
	)


func _process_search_player(
	delta: float
) -> void:
	_stop_horizontal_motion()

	if player_visible:
		_set_state(
			State.MOVE_TO_PLAYER
		)
		return

	search_timer -= delta

	rotation.y += (
		search_rotation_speed
		* delta
	)

	_play_animation(
		ANIM_IDLE,
		0.15,
		1.0
	)

	if search_timer > 0.0:
		return

	player_memory_timer = 0.0

	_set_state(
		State.IDLE
	)


# ============================================================
# RESUME
# ============================================================

func _resume_after_action() -> void:
	if state == State.DEAD:
		return

	if not has_racket:
		if (
			racket_pickup_position != null
			and is_instance_valid(
				racket_pickup_position
			)
		):
			_set_state(
				State.SEEK_RACKET
			)
			return

	if player_visible:
		_set_state(
			State.MOVE_TO_PLAYER
		)
		return

	if player_memory_timer > 0.0:
		_set_state(
			State.MOVE_TO_PLAYER
		)
		return

	if has_racket:
		_start_search_player()
		return

	_set_state(
		State.IDLE
	)


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

func set_has_racket(
	value: bool
) -> void:
	has_racket = value

	_sync_racket_visual()


func _sync_racket_visual() -> void:
	if racket_visual == null:
		return

	racket_visual.visible = (
		has_racket
	)


# ============================================================
# STATE
# ============================================================

func _set_state(
	new_state: State
) -> void:
	if state == new_state:
		return

	state = new_state

	match state:
		State.IDLE:
			_stop_horizontal_motion()

			_play_animation(
				ANIM_IDLE,
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

func _rotate_toward(
	direction: Vector3,
	delta: float
) -> void:
	if direction.length_squared() <= 0.0001:
		return

	var target_yaw := atan2(
		direction.x,
		direction.z
	)

	rotation.y = lerp_angle(
		rotation.y,
		target_yaw,
		rotation_speed
		* delta
	)


func _face_player(
	delta: float
) -> void:
	if player == null:
		return

	var direction := (
		player.global_position
		- global_position
	)

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

	if not animation_player.has_animation(
		animation_name
	):
		push_warning(
			"BrunoBuozzi: animazione non trovata: "
			+ String(animation_name)
		)
		return

	animation_player.speed_scale = (
		playback_speed
	)

	if (
		animation_player.current_animation
		== animation_name
		and animation_player.is_playing()
	):
		return

	animation_player.play(
		animation_name,
		blend_time
	)


func _on_animation_finished(
	animation_name: StringName
) -> void:
	# --------------------------------------------------------
	# CADUTA TRA FASI
	# --------------------------------------------------------

	if state == State.DOWN:
		if animation_name != ANIM_FALLING_DOWN:
			return

		_start_getting_up()
		return


	# --------------------------------------------------------
	# RIALZATA
	# --------------------------------------------------------

	if state == State.GETTING_UP:
		if animation_name != ANIM_STAND_UP:
			return

		_finish_phase_transition()
		return


	# --------------------------------------------------------
	# DEAD
	# --------------------------------------------------------

	if state == State.DEAD:
		return


	# --------------------------------------------------------
	# PICKUP
	# --------------------------------------------------------

	if state == State.PICKUP_RACKET:
		if animation_name != ANIM_RACKET_PICKUP:
			return

		if not racket_pickup_done:
			_complete_racket_pickup()

		_resume_after_action()
		return


	# --------------------------------------------------------
	# BALL
	# --------------------------------------------------------

	if state == State.BALL_ATTACK:
		if animation_name != ANIM_BALL_CAST:
			return

		ball_released = false
		cast_elapsed = 0.0

		if (
			burst_remaining > 0
			and player_visible
		):
			_start_next_ball_in_burst()
			return

		_finish_ball_burst()
		return


	# --------------------------------------------------------
	# MELEE
	# --------------------------------------------------------

	if state == State.MELEE_ATTACK:
		if (
			animation_name != ANIM_LEFT_SLASH
			and animation_name != ANIM_CHARGED_SLASH
		):
			return

		melee_hit_done = false
		current_melee_animation = &""

		melee_cooldown = rng.randf_range(
			_get_melee_cooldown_min(),
			_get_melee_cooldown_max()
		)

		_resume_after_action()


# ============================================================
# BOSS BAR
# ============================================================

func _create_boss_bar() -> void:
	boss_bar_layer = (
		CanvasLayer.new()
	)

	boss_bar_layer.name = (
		"BrunoBossBar"
	)

	boss_bar_layer.layer = 100

	add_child(
		boss_bar_layer
	)

	var root := Control.new()

	root.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	root.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	boss_bar_layer.add_child(
		root
	)

	var center := (
		CenterContainer.new()
	)

	center.set_anchors_preset(
		Control.PRESET_TOP_WIDE
	)

	center.offset_top = 8.0
	center.offset_bottom = 82.0

	center.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	root.add_child(
		center
	)

	var panel := (
		PanelContainer.new()
	)

	panel.custom_minimum_size = Vector2(
		560.0,
		64.0
	)

	panel.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	center.add_child(
		panel
	)

	var panel_style := (
		StyleBoxFlat.new()
	)

	panel_style.bg_color = Color(
		0.025,
		0.015,
		0.015,
		0.92
	)

	panel_style.border_color = Color(
		0.65,
		0.05,
		0.03,
		1.0
	)

	panel_style.set_border_width_all(
		2
	)

	panel_style.corner_radius_top_left = 7
	panel_style.corner_radius_top_right = 7
	panel_style.corner_radius_bottom_left = 7
	panel_style.corner_radius_bottom_right = 7

	panel.add_theme_stylebox_override(
		"panel",
		panel_style
	)

	var margin := (
		MarginContainer.new()
	)

	margin.add_theme_constant_override(
		"margin_left",
		12
	)

	margin.add_theme_constant_override(
		"margin_right",
		12
	)

	margin.add_theme_constant_override(
		"margin_top",
		5
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		5
	)

	panel.add_child(
		margin
	)

	var column := (
		VBoxContainer.new()
	)

	column.add_theme_constant_override(
		"separation",
		3
	)

	margin.add_child(
		column
	)

	var title := (
		Label.new()
	)

	title.text = (
		boss_name
	)

	title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	title.add_theme_font_size_override(
		"font_size",
		18
	)

	column.add_child(
		title
	)

	var segments := (
		HBoxContainer.new()
	)

	segments.add_theme_constant_override(
		"separation",
		5
	)

	column.add_child(
		segments
	)

	boss_segment_1 = (
		_create_boss_segment()
	)

	boss_segment_2 = (
		_create_boss_segment()
	)

	boss_segment_3 = (
		_create_boss_segment()
	)

	segments.add_child(
		boss_segment_1
	)

	segments.add_child(
		boss_segment_2
	)

	segments.add_child(
		boss_segment_3
	)

	boss_hp_label = (
		Label.new()
	)

	boss_hp_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	boss_hp_label.add_theme_font_size_override(
		"font_size",
		11
	)

	column.add_child(
		boss_hp_label
	)

	boss_phase_label = (
		Label.new()
	)

	boss_phase_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	boss_phase_label.add_theme_font_size_override(
		"font_size",
		10
	)

	column.add_child(
		boss_phase_label
	)


func _create_boss_segment() -> ProgressBar:
	var bar := (
		ProgressBar.new()
	)

	bar.show_percentage = false

	bar.custom_minimum_size = Vector2(
		170.0,
		12.0
	)

	var background := (
		StyleBoxFlat.new()
	)

	background.bg_color = Color(
		0.10,
		0.03,
		0.03,
		1.0
	)

	background.corner_radius_top_left = 3
	background.corner_radius_top_right = 3
	background.corner_radius_bottom_left = 3
	background.corner_radius_bottom_right = 3

	bar.add_theme_stylebox_override(
		"background",
		background
	)

	var fill := (
		StyleBoxFlat.new()
	)

	fill.bg_color = Color(
		0.82,
		0.04,
		0.025,
		1.0
	)

	fill.corner_radius_top_left = 3
	fill.corner_radius_top_right = 3
	fill.corner_radius_bottom_left = 3
	fill.corner_radius_bottom_right = 3

	bar.add_theme_stylebox_override(
		"fill",
		fill
	)

	return bar


func _update_boss_bar() -> void:
	if boss_bar_layer == null:
		return

	var segment := (
		_get_segment_health()
	)

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
		boss_segment_1.max_value = (
			segment
		)

		boss_segment_1.value = (
			segment_1_value
		)

	if boss_segment_2 != null:
		boss_segment_2.max_value = (
			segment
		)

		boss_segment_2.value = (
			segment_2_value
		)

	if boss_segment_3 != null:
		boss_segment_3.max_value = (
			segment
		)

		boss_segment_3.value = (
			segment_3_value
		)

	if boss_hp_label != null:
		boss_hp_label.text = (
			"%d / %d"
			% [
				health,
				max_health
			]
		)

	if boss_phase_label != null:
		boss_phase_label.text = (
			"FASE %d"
			% combat_phase
		)
