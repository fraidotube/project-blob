extends "res://scripts/interactables/door.gd"
## Battente della nuova zona; i controller storici restano invariati.

var persistent_id: StringName
var required_key: StringName
var fingerprint_locked := false
var fingerprint_unlock_seconds := 10.0
var unlocked := false
var fingerprint_remaining := 0.0
var closed_center := Vector3.ZERO
var opening_normal := Vector3.RIGHT
var leaf_width := 0.8
var panel_box: CollisionShape3D
var retreating := false
var _player: CharacterBody3D
var _restore_physics := false
var _retreat_target := Vector3.ZERO
## Abilitato dalla configurazione della sola porta autorizzata ai Broccolo.
@export var enemy_jump_open_enabled := false

func request_enemy_open(actor: CharacterBody3D) -> bool:
	if not enemy_jump_open_enabled or not is_instance_valid(actor) or not actor.is_in_group("broccolo_lab_actors"): return false
	if actor.get("state") not in ["gate", "chase"]: return false
	if fingerprint_locked or not unlocked or retreating: return false
	var offset := actor.global_position - closed_center
	if Vector2(offset.x, offset.z).length() > leaf_width + 0.9 or absf(offset.y) > 2.0: return false
	# Same physical opening and audio, without moving/locking the player remotely.
	# The existing panel sweep still stops if the player occupies the swing.
	_begin_open()
	return is_open

func _ready() -> void:
	unlocked = required_key.is_empty() and not fingerprint_locked
	super._ready()
	SaveManager.register_object(persistent_id, self)

func _exit_tree() -> void:
	_finish_retreat(false)
	if door_audio != null:
		door_audio.stop()
	SaveManager.unregister_object(persistent_id, self)

func get_interaction_action() -> String:
	if retreating or blocks_saving():
		return "IN MOVIMENTO"
	if is_open:
		return "CHIUDI"
	if fingerprint_locked and fingerprint_remaining <= 0.0:
		return "SERVE IL FINGERPRINT"
	if not unlocked and not required_key.is_empty():
		return "SBLOCCA" if InventoryManager.has_item(required_key) else "SERVE LA CHIAVE"
	return "APRI"

func interact(_actor: Node) -> void:
	if retreating or blocks_saving():
		return
	if is_open:
		close_door()
		return
	if fingerprint_locked and fingerprint_remaining <= 0.0:
		GameplayUI.notify("Usa il lettore fingerprint accanto alla porta.")
		return
	if not unlocked and not required_key.is_empty():
		if not InventoryManager.has_item(required_key):
			var definition: Resource = InventoryManager.definitions.get(String(required_key))
			GameplayUI.notify("Serve " + definition.display_name.to_lower() + "." if definition != null else "Serve la chiave corretta.")
			return
		unlocked = true
	open_door()

func authorize_fingerprint() -> void:
	if fingerprint_locked:
		fingerprint_remaining = fingerprint_unlock_seconds

func open_door() -> void:
	if is_open or retreating:
		return
	if fingerprint_locked and fingerprint_remaining <= 0.0:
		return
	if not fingerprint_locked and not unlocked:
		return
	var actor := get_tree().get_first_node_in_group("player") as CharacterBody3D
	# Sposta dolcemente il giocatore fuori dal settore del battente, solo
	# se il percorso reale è libero (anche per il CED che apre verso di lui).
	if actor != null:
		var capsule := actor.get_node_or_null("CollisionShape3D") as CollisionShape3D
		var radius := 0.35
		if capsule != null and capsule.shape is CapsuleShape3D:
			radius = capsule.shape.radius
		var offset := actor.global_position - closed_center
		var distance := offset.dot(opening_normal)
		var tangent := opening_normal.cross(Vector3.UP)
		var safe_distance := leaf_width + radius + 0.12
		if absf(offset.y) < 1.5 and distance > -radius and distance < safe_distance and absf(offset.dot(tangent)) < leaf_width * 0.5 + radius:
			# Dal lato opposto la porta si allontana: nessun arretramento.
			if distance > 0.0:
				var motion := opening_normal * (safe_distance - distance)
				var parameters := PhysicsTestMotionParameters3D.new()
				parameters.from = actor.global_transform
				parameters.motion = motion
				if PhysicsServer3D.body_test_motion(actor.get_rid(), parameters):
					GameplayUI.notify("Fai spazio al battente per aprire.")
					return
				_player = actor
				_restore_physics = actor.is_physics_processing()
				_retreat_target = actor.global_position + motion
				actor.velocity = Vector3.ZERO
				actor.set_physics_process(false)
				retreating = true
				return
	_begin_open()

func _begin_open() -> void:
	fingerprint_remaining = 0.0
	super.open_door()

func close_door() -> void:
	if _player_in_swing():
		GameplayUI.notify("Passaggio occupato.")
		return
	super.close_door()

func _on_auto_close_timeout() -> void:
	# Una chiusura automatica rimandata dal passaggio occupato va ritentata.
	# Il valore predefinito Auto Close=false mantiene il comportamento esistente.
	if not forced_open and is_open and _player_in_swing():
		auto_close_timer.start(0.25)
		return
	super._on_auto_close_timeout()

func _player_in_swing() -> bool:
	var actor := get_tree().get_first_node_in_group("player") as Node3D
	if actor == null:
		return false
	var offset := actor.global_position - closed_center
	var tangent := opening_normal.cross(Vector3.UP)
	return absf(offset.y) < 1.5 and offset.dot(opening_normal) > -0.4 and offset.dot(opening_normal) < leaf_width + 0.5 and absf(offset.dot(tangent)) < leaf_width * 0.5 + 0.4

func _physics_process(delta: float) -> void:
	fingerprint_remaining = maxf(0.0, fingerprint_remaining - delta)
	if retreating:
		if not is_instance_valid(_player) or _player.is_dead:
			_finish_retreat(false)
			return
		var remaining := _retreat_target - _player.global_position
		var collision := _player.move_and_collide(remaining.limit_length(2.8 * delta))
		if collision != null:
			_finish_retreat(false)
		elif remaining.length() < 0.01:
			_finish_retreat(true)
		return
	if not is_open and blocks_saving() and _player_in_swing():
		# Un giocatore entra nel settore durante la chiusura: riapri.
		super.open_door()
	# Non attraversare il player durante il movimento del pannello.
	var next_angle := lerp_angle(rotation.y, target_rotation_y, open_speed * delta)
	if absf(angle_difference(rotation.y, next_angle)) > 0.00001:
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = panel_box.shape
		query.transform = Transform3D(Basis(Vector3.UP, next_angle), global_position) * door_body_rest_transform * panel_box.transform
		query.collision_mask = 1
		query.exclude = [door_body.get_rid()]
		for hit: Dictionary in get_world_3d().direct_space_state.intersect_shape(query, 32):
			if hit.collider.is_in_group("player"):
				return
	super._physics_process(delta)
	if absf(angle_difference(rotation.y, target_rotation_y)) < 0.001:
		rotation.y = target_rotation_y

func _finish_retreat(open_after: bool) -> void:
	if is_instance_valid(_player):
		_player.velocity = Vector3.ZERO
		if not _player.is_dead:
			_player.set_physics_process(_restore_physics)
	_player = null
	retreating = false
	if open_after:
		_begin_open()

func blocks_saving() -> bool:
	return retreating or absf(angle_difference(rotation.y, target_rotation_y)) > 0.001

func get_persistent_state() -> Dictionary:
	return {"open": is_open, "unlocked": unlocked}

func apply_persistent_state(state: Dictionary) -> void:
	_finish_retreat(false)
	door_audio.stop()
	close_sound_pending = false
	fingerprint_remaining = 0.0
	unlocked = not fingerprint_locked and (required_key.is_empty() or bool(state.get("unlocked", false)))
	is_open = bool(state.get("open", false)) and (unlocked or fingerprint_locked)
	target_rotation_y = deg_to_rad(open_angle) if is_open else 0.0
	rotation.y = target_rotation_y
	door_body.global_transform = global_transform * door_body_rest_transform
