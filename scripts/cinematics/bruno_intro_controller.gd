extends Node

@export_category("References")
@export var bruno: Node
@export var point_1: Marker3D
@export var player: CharacterBody3D

@export_category("Timing")
@export var delay_after_remote: float = 1.0
@export var delay_after_stand: float = 0.25
@export var wait_after_arrival: float = 0.75

@export_category("Test Sequence")
@export var lock_player_during_test: bool = false
@export var auto_release_player_after_test: bool = true
@export var point_1_walk_animation: StringName = &"Casual_Walk"
@export var point_1_idle_animation: StringName = &"Idle_3"

@export_category("Intro Collision Blockers")
@export var intro_blocker_group: StringName = &"bruno_intro_blocker"

var intro_started: bool = false

# SAFE: salviamo lo stato originale di ogni CollisionShape3D,
# così a fine intro ripristiniamo esattamente com'era.
var intro_blocker_collision_states: Dictionary = {}
var intro_blockers_disabled: bool = false


func _ready() -> void:
	if player == null:
		player = (
			get_tree()
			.get_first_node_in_group("player")
			as CharacterBody3D
		)


func start_intro() -> void:
	if intro_started:
		return

	if bruno == null:
		push_error(
			"BrunoIntroController: riferimento Bruno mancante."
		)
		return

	if point_1 == null:
		push_error(
			"BrunoIntroController: Point 1 mancante."
		)
		return

	intro_started = true

	_disable_intro_blockers()

	_run_intro_test()


func _run_intro_test() -> void:
	if lock_player_during_test:
		_lock_player()

	if bruno.has_method(
		"cinematic_lock"
	):
		bruno.call(
			"cinematic_lock"
		)

	if delay_after_remote > 0.0:
		await get_tree().create_timer(
			delay_after_remote
		).timeout

	if not is_inside_tree():
		return

	if bruno.has_method(
		"cinematic_play_animation_and_wait"
	):
		await bruno.call(
			"cinematic_play_animation_and_wait",
			&"Sit_to_Stand_Transition_M",
			0.15,
			1.0
		)

	if delay_after_stand > 0.0:
		await get_tree().create_timer(
			delay_after_stand
		).timeout

	if not is_inside_tree():
		return

	if bruno.has_method(
		"cinematic_move_to"
	):
		bruno.call(
			"cinematic_move_to",
			point_1.global_position,
			point_1_walk_animation
		)

	while (
		is_inside_tree()
		and bruno != null
		and bruno.has_method(
			"cinematic_is_moving"
		)
		and bool(
			bruno.call(
				"cinematic_is_moving"
			)
		)
	):
		await get_tree().process_frame

	if not is_inside_tree():
		return

	if (
		bruno != null
		and bruno.has_method(
			"cinematic_stop_move"
		)
	):
		bruno.call(
			"cinematic_stop_move",
			point_1_idle_animation
		)

	if wait_after_arrival > 0.0:
		await get_tree().create_timer(
			wait_after_arrival
		).timeout

	if (
		lock_player_during_test
		and auto_release_player_after_test
	):
		_unlock_player()


# ============================================================
# INTRO COLLISION BLOCKERS
# ============================================================

func _disable_intro_blockers() -> void:
	if intro_blockers_disabled:
		return

	intro_blocker_collision_states.clear()

	var blocker_roots: Array[Node] = (
		get_tree()
		.get_nodes_in_group(
			intro_blocker_group
		)
	)

	for blocker_root: Node in blocker_roots:
		_collect_and_disable_collision_shapes(
			blocker_root
		)

	intro_blockers_disabled = true

	print(
		"[BrunoIntro] Collisioni intro disabilitate: ",
		intro_blocker_collision_states.size()
	)


func _collect_and_disable_collision_shapes(
	node: Node
) -> void:
	if node is CollisionShape3D:
		var collision_shape := (
			node as CollisionShape3D
		)

		if not intro_blocker_collision_states.has(
			collision_shape
		):
			intro_blocker_collision_states[
				collision_shape
			] = collision_shape.disabled

			collision_shape.set_deferred(
				"disabled",
				true
			)

	for child: Node in node.get_children():
		_collect_and_disable_collision_shapes(
			child
		)


func restore_intro_blockers() -> void:
	if not intro_blockers_disabled:
		return

	for collision_shape_value: Variant in (
		intro_blocker_collision_states.keys()
	):
		if not collision_shape_value is CollisionShape3D:
			continue

		var collision_shape := (
			collision_shape_value
			as CollisionShape3D
		)

		if not is_instance_valid(
			collision_shape
		):
			continue

		var original_disabled_value: Variant = (
			intro_blocker_collision_states.get(
				collision_shape,
				false
			)
		)

		collision_shape.set_deferred(
			"disabled",
			bool(original_disabled_value)
		)

	intro_blocker_collision_states.clear()
	intro_blockers_disabled = false

	print(
		"[BrunoIntro] Collisioni intro ripristinate."
	)


func start_boss_fight() -> void:
	restore_intro_blockers()

	if (
		bruno != null
		and bruno.has_method(
			"start_boss_fight"
		)
	):
		bruno.call(
			"start_boss_fight"
		)


# ============================================================
# PLAYER LOCK
# ============================================================

func _lock_player() -> void:
	if player == null:
		return

	player.velocity = Vector3.ZERO
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)


func _unlock_player() -> void:
	if player == null:
		return

	player.set_physics_process(true)
	player.set_process_unhandled_input(true)
