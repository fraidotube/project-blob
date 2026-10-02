extends CharacterBody3D

@export_category("Test")
@export var test_mode: bool = false
@export var test_start_delay: float = 2.0

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

var casting_ball: bool = false
var ball_released: bool = false
var cast_elapsed: float = 0.0

# ATTENZIONE:
# il nome reale dell'animazione nel modello importato è "mage_soell_cast_4"
const ANIM_BALL_CAST: StringName = &"mage_soell_cast_4"


func _ready() -> void:
	print("BRUNO: _ready()")

	player = (
		get_tree()
		.get_first_node_in_group("player")
		as CharacterBody3D
	)

	if player == null:
		push_warning(
			"BrunoBuozzi: Player non trovato all'avvio."
		)
	else:
		print(
			"BRUNO: Player trovato: ",
			player.name
		)

	if animation_player == null:
		push_error(
			"BrunoBuozzi: AnimationPlayer non trovato."
		)
		return

	print(
		"BRUNO: AnimationPlayer trovato."
	)

	if animation_player.has_animation(
		ANIM_BALL_CAST
	):
		print(
			"BRUNO: animazione trovata: ",
			ANIM_BALL_CAST
		)
	else:
		push_error(
			"BrunoBuozzi: animazione NON trovata: "
			+ String(ANIM_BALL_CAST)
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

	print(
		"BRUNO: TennisBallSpawn trovato."
	)

	if test_mode:
		print(
			"BRUNO: Test Mode attivo. Lancio tra ",
			test_start_delay,
			" secondi."
		)

		_start_test_after_delay()


func _physics_process(delta: float) -> void:
	if not casting_ball:
		return

	velocity = Vector3.ZERO

	_face_player()

	cast_elapsed += delta

	if (
		not ball_released
		and cast_elapsed >= ball_release_time
	):
		ball_released = true

		print(
			"BRUNO: rilascio pallina a ",
			cast_elapsed,
			" secondi."
		)

		_release_tennis_ball()


func _start_test_after_delay() -> void:
	await get_tree().create_timer(
		test_start_delay
	).timeout

	if not is_inside_tree():
		return

	print(
		"BRUNO: avvio attacco di test."
	)

	start_ball_attack()


func start_ball_attack() -> void:
	if casting_ball:
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
		push_error(
			"BrunoBuozzi: AnimationPlayer non trovato."
		)
		return

	if not animation_player.has_animation(
		ANIM_BALL_CAST
	):
		push_error(
			"BrunoBuozzi: animazione non trovata: "
			+ String(ANIM_BALL_CAST)
		)
		return

	casting_ball = true
	ball_released = false
	cast_elapsed = 0.0

	velocity = Vector3.ZERO

	_face_player()

	print(
		"BRUNO: play ",
		ANIM_BALL_CAST
	)

	animation_player.speed_scale = 1.0

	animation_player.play(
		ANIM_BALL_CAST,
		0.10
	)


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
		push_warning(
			"BrunoBuozzi: Player perso durante il lancio."
		)
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

	print(
		"BRUNO: spawn pallina ",
		start_position,
		" -> target ",
		target_position
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


func _face_player() -> void:
	if player == null:
		return

	var direction := (
		player.global_position
		- global_position
	)

	direction.y = 0.0

	if direction.length_squared() <= 0.0001:
		return

	rotation.y = atan2(
		direction.x,
		direction.z
	)


func _on_animation_finished(
	animation_name: StringName
) -> void:
	if animation_name != ANIM_BALL_CAST:
		return

	print(
		"BRUNO: animazione lancio terminata."
	)

	casting_ball = false
	ball_released = false
	cast_elapsed = 0.0
	velocity = Vector3.ZERO
