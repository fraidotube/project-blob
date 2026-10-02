extends CharacterBody3D

enum State {
	IDLE,
	WALK_TO_PLAYER,
	BALL_ATTACK
}

enum TestAction {
	BALL_ATTACK,
	WALK_TO_PLAYER
}


@export_category("Test")
@export var test_mode: bool = false
@export var test_start_delay: float = 2.0
@export var test_action: TestAction = TestAction.WALK_TO_PLAYER


@export_category("Movement")
@export var walk_speed: float = 1.60
@export var rotation_speed: float = 7.0
@export var walk_stop_distance: float = 2.80


@export_category("Tennis Ball Attack")
@export var tennis_ball_projectile_scene: PackedScene = preload(
	"res://scenes/enemies/tennis_ball_projectile.tscn"
)

@export var ball_damage: int = 15
@export var ball_explosive: bool = false
@export var ball_release_time: float = 0.57
@export var ball_flight_time: float = 0.90
@export var ball_target_height: float = 0.80


@onready var animation_player: AnimationPlayer = (
	$Meshy_AI_Mutated_Tennis_Player_All_Animations/AnimationPlayer
)

@onready var tennis_ball_spawn: Marker3D = (
	$Meshy_AI_Mutated_Tennis_Player_All_Animations/target_character/GeneralSkeleton/BoneAttachment3D/TennisBallSpawn
)


var player: CharacterBody3D = null

var state: State = State.IDLE

var ball_released: bool = false
var cast_elapsed: float = 0.0


const ANIM_IDLE: StringName = &"Idle_8"
const ANIM_WALK: StringName = &"Casual_Walk"

# Nome reale presente nell'asset importato.
const ANIM_BALL_CAST: StringName = &"mage_soell_cast_4"


func _ready() -> void:
	player = (
		get_tree()
		.get_first_node_in_group("player")
		as CharacterBody3D
	)

	if player == null:
		push_warning(
			"BrunoBuozzi: Player non trovato all'avvio."
		)

	if animation_player == null:
		push_error(
			"BrunoBuozzi: AnimationPlayer non trovato."
		)
		return

	animation_player.animation_finished.connect(
		_on_animation_finished
	)

	if tennis_ball_spawn == null:
		push_error(
			"BrunoBuozzi: TennisBallSpawn non trovato."
		)
		return

	_set_state(State.IDLE)

	if test_mode:
		_start_test_after_delay()


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		player = (
			get_tree()
			.get_first_node_in_group("player")
			as CharacterBody3D
		)

	if not is_on_floor():
		velocity += get_gravity() * delta

	match state:
		State.IDLE:
			_process_idle()

		State.WALK_TO_PLAYER:
			_process_walk_to_player(delta)

		State.BALL_ATTACK:
			_process_ball_attack(delta)

	move_and_slide()


func _start_test_after_delay() -> void:
	await get_tree().create_timer(
		test_start_delay
	).timeout

	if not is_inside_tree():
		return

	match test_action:
		TestAction.BALL_ATTACK:
			start_ball_attack()

		TestAction.WALK_TO_PLAYER:
			_set_state(State.WALK_TO_PLAYER)


func _process_idle() -> void:
	_stop_horizontal_motion()


func _process_walk_to_player(
	delta: float
) -> void:
	if player == null:
		_set_state(State.IDLE)
		return

	var direction := (
		player.global_position
		- global_position
	)

	direction.y = 0.0

	var distance := direction.length()

	if distance <= walk_stop_distance:
		_stop_horizontal_motion()
		_face_player(delta)
		_set_state(State.IDLE)
		return

	if direction.length_squared() <= 0.0001:
		_stop_horizontal_motion()
		return

	direction = direction.normalized()

	velocity.x = direction.x * walk_speed
	velocity.z = direction.z * walk_speed

	_rotate_toward(
		direction,
		delta
	)

	_play_animation(
		ANIM_WALK,
		0.15
	)


func start_ball_attack() -> void:
	if state == State.BALL_ATTACK:
		return

	if player == null or not is_instance_valid(player):
		player = (
			get_tree()
			.get_first_node_in_group("player")
			as CharacterBody3D
		)

	if player == null:
		push_warning(
			"BrunoBuozzi: Player non trovato."
		)
		return

	if animation_player == null:
		return

	if not animation_player.has_animation(
		ANIM_BALL_CAST
	):
		push_error(
			"BrunoBuozzi: animazione non trovata: "
			+ String(ANIM_BALL_CAST)
		)
		return

	_set_state(State.BALL_ATTACK)


func _process_ball_attack(
	delta: float
) -> void:
	_stop_horizontal_motion()

	_face_player(delta)

	cast_elapsed += delta

	if (
		not ball_released
		and cast_elapsed >= ball_release_time
	):
		ball_released = true
		_release_tennis_ball()


func _release_tennis_ball() -> void:
	if tennis_ball_projectile_scene == null:
		push_error(
			"BrunoBuozzi: scena TennisBallProjectile non disponibile."
		)
		return

	if tennis_ball_spawn == null:
		push_error(
			"BrunoBuozzi: TennisBallSpawn non trovato."
		)
		return

	if player == null or not is_instance_valid(player):
		return

	var projectile := (
		tennis_ball_projectile_scene
		.instantiate()
	)

	get_tree().current_scene.add_child(
		projectile
	)

	var start_position := (
		tennis_ball_spawn.global_position
	)

	var target_position := (
		player.global_position
		+ Vector3.UP * ball_target_height
	)

	if projectile.has_method("launch"):
		projectile.launch(
			start_position,
			target_position,
			ball_damage,
			ball_explosive,
			self,
			ball_flight_time
		)
	else:
		push_error(
			"BrunoBuozzi: il proiettile non possiede launch()."
		)

		projectile.queue_free()


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
				0.15
			)

		State.WALK_TO_PLAYER:
			pass

		State.BALL_ATTACK:
			_stop_horizontal_motion()

			ball_released = false
			cast_elapsed = 0.0

			if player != null:
				_face_player(1.0)

			_play_animation(
				ANIM_BALL_CAST,
				0.10
			)


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
		rotation_speed * delta
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


func _play_animation(
	animation_name: StringName,
	blend_time: float = 0.15
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

	animation_player.speed_scale = 1.0

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
	if state != State.BALL_ATTACK:
		return

	if animation_name != ANIM_BALL_CAST:
		return

	ball_released = false
	cast_elapsed = 0.0

	_set_state(State.IDLE)
