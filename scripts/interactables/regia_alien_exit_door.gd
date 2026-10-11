extends "res://scripts/interactables/door.gd"
var puzzle: Node
var leaf_width := 0.8
var closed_plane_z := 0.0
var closed_center_x := 0.0
var retreating := false
var _retreat_player: CharacterBody3D
var _restore_player_physics := false
var _retreat_target_z := 0.0

func get_interaction_name() -> String:
	return "USCITA REGIA" if puzzle.state.unlocked else "CHIUSURA ALIENA"

func get_interaction_action() -> String:
	return super.get_interaction_action() if puzzle.state.unlocked else "ESAMINA"

func interact(player: Node) -> void:
	if retreating:
		return
	if puzzle.state.unlocked:
		super.interact(player)
	else:
		puzzle.interact_action("alien")

func open_door() -> void:
	if is_open or retreating:
		return
	var player := puzzle.scene.get_node("Player") as CharacterBody3D
	var radius := (player.get_node("CollisionShape3D").shape as CapsuleShape3D).radius
	var safe_z := closed_plane_z + leaf_width + radius + 0.12
	# Retreat only from the regia side and within the leaf's swing sector.
	if player.global_position.z <= closed_plane_z or player.global_position.z >= safe_z or absf(player.global_position.x - closed_center_x) > leaf_width * 0.5 + radius:
		super.open_door()
		return
	var parameters := PhysicsTestMotionParameters3D.new()
	parameters.from = player.global_transform
	parameters.motion = Vector3(0, 0, safe_z - player.global_position.z)
	if PhysicsServer3D.body_test_motion(player.get_rid(), parameters):
		GameplayUI.notify("Non c'è spazio per aprire la porta.")
		return
	_retreat_player = player
	_restore_player_physics = player.is_physics_processing()
	_retreat_target_z = safe_z
	retreating = true
	player.velocity = Vector3.ZERO
	player.set_physics_process(false)

func _physics_process(delta: float) -> void:
	if door_audio != null:
		door_audio.stream_paused = get_tree().paused and GameplayUI.modal.is_empty()
	if get_tree().paused and GameplayUI.modal.is_empty(): return
	if retreating and get_tree().paused:
		return
	super._physics_process(delta)
	if not retreating:
		return
	if not is_instance_valid(_retreat_player) or _retreat_player.is_dead:
		_finish_retreat(false)
		return
	var distance := _retreat_target_z - _retreat_player.global_position.z
	var collision := _retreat_player.move_and_collide(Vector3(0, 0, minf(distance, 2.8 * delta)))
	if collision != null:
		_finish_retreat(false)
		GameplayUI.notify("Non c'è spazio per aprire la porta.")
	elif _retreat_player.global_position.z >= _retreat_target_z - 0.005:
		_finish_retreat(true)

func _finish_retreat(open_after: bool) -> void:
	if is_instance_valid(_retreat_player):
		_retreat_player.velocity = Vector3.ZERO
		if not _retreat_player.is_dead:
			_retreat_player.set_physics_process(_restore_player_physics)
	_retreat_player = null
	retreating = false
	if open_after:
		super.open_door()

func _exit_tree() -> void:
	if retreating:
		_finish_retreat(false)
