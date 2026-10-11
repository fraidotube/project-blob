extends Node

signal fight_ready
const EVENT_STATE := preload("res://scripts/systems/angelastri_event_state.gd")
const ID := &"main.angelastri.encounter"
const COMBAT := preload("res://scripts/enemies/angelastri_combat.gd")
var combat: Node
@export var first_blackout_min := 14.0
@export var first_blackout_max := 22.0
@export var next_blackout_delay := 12.0
@export var dialogue_distance := 8.0
var event = EVENT_STATE.new()
var scene: Node3D
var player: CharacterBody3D
var preview: Node
var network: Node
var power: Node
var doors: Array[Node] = []
var doorway_center := Vector3.ZERO
var outward := Vector3.FORWARD
var doorway_tangent := Vector3.RIGHT
var doorway_half_width := 1.0
var inside := true
var last_position := Vector3.ZERO
var configured := false
var cinematic := false
var starting := false
var returning := false
var camera: Camera3D
var player_camera: Camera3D
var original_camera := Transform3D.IDENTITY
var original_fov := 75.0
var camera_exit_from := Transform3D.IDENTITY
var camera_exit_to := Transform3D.IDENTITY
var lock_state: Dictionary = {}
var light_state: Dictionary = {}
var tower: Node3D
var director_time := 0.0
var return_time := 0.0
var return_from := Transform3D.IDENTITY
var orbit_base := 0.0
var dance_yaw := 0.0
var intro_yaw := 0.0
var prewarmed_dance_yaw := 0.0
var prewarmed_dance_scale := 0.85
var dance_plan_ready := false
var laugh: AudioStreamPlayer3D
var meter_click: AudioStreamPlayer3D
var patrol_origin := Vector3.ZERO
var patrol_target := Vector3.ZERO
var patrol_wait := 2.0
var patrol_looking := false
var detection_grace := 3.0
var saved_actor_pose := Transform3D.IDENTITY
var last_actor_pose := Transform3D.IDENTITY
var visual_blocks: Array[Dictionary] = []
var recreate_actor := false
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	process_priority = 20
	rng.randomize()
	call_deferred("_setup")

func _unhandled_input(input: InputEvent) -> void:
	if input is InputEventKey and input.pressed and not input.echo and input.keycode == KEY_F11:
		if configured and not starting and not cinematic and not player.is_dead and event.stage != "combat":
			_test_combat()
			get_viewport().set_input_as_handled()
	if input is InputEventKey and input.pressed and not input.echo and input.keycode == KEY_F7:
		if configured and not starting and not cinematic and not player.is_dead and event.stage != "combat":
			_test_patrol()
			get_viewport().set_input_as_handled()

func _test_combat() -> void:
	await _test_patrol()
	if not is_instance_valid(preview.presentation): return
	event.stage = "combat"
	combat = COMBAT.new()
	add_child(combat)
	combat.configure(self, preview.presentation)
	GameplayUI.clear_notice()

func _test_patrol() -> void:
	starting = true
	if is_instance_valid(combat):
		combat.release_player()
		preview.clear_preview()
		combat.queue_free()
		combat = null
	await preview.spawn_preview(false, false, false)
	while is_inside_tree() and preview.busy: await get_tree().process_frame
	starting = false
	if not is_instance_valid(preview.presentation): return
	preview.presentation.sequence = false
	preview.presentation.presentation_stage = "rest"
	preview.presentation.visible = true
	preview._release_background_music()
	event.armed = true
	event.blackout_count = 3
	event.stage = "waiting"
	patrol_origin = preview.presentation.model.global_position
	patrol_target = patrol_origin
	patrol_wait = 0.1
	patrol_looking = true
	detection_grace = 8.0
	for clip in [&"mie/walking", &"mie/idle_new"]:
		preview.presentation.animation.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
	preview.presentation.animation.get_animation(&"mie/looking").loop_mode = Animation.LOOP_NONE
	preview.presentation.animation.play(&"mie/idle_new", 0.4)
	GameplayUI.notify("Test F7: Angelastri passeggia. Avvicinati per il secondo incontro.")

func _setup() -> void:
	scene = get_parent() as Node3D
	while is_inside_tree() and get_tree().get_first_node_in_group("regia_network") == null:
		await get_tree().process_frame
	if not is_inside_tree(): return
	network = get_tree().get_first_node_in_group("regia_network")
	player = scene.get_node("Player")
	player_camera = player.get_node("Head/Camera3D")
	preview = scene.get_node("AngelastriMapPreview")
	preview.enabled = false
	power = scene.get_node("ConnesiPower")
	var building := scene.get_node("connesi_building_test2")
	var door: Node3D = building.get_node("Porta Lab Esterna ")
	var shape: CollisionShape3D = door.get_node("DoorBody/CollisionShape3D")
	var box := shape.shape as BoxShape3D
	var closed := Transform3D(door.get_parent_node_3d().global_basis, door.global_position)
	doorway_center = closed * (door.door_body_rest_transform * shape.position)
	var normal := Vector3.RIGHT if box.size.x < box.size.z else Vector3.BACK
	outward = (closed.basis * normal).normalized()
	var marker: Node3D = scene.get_node("Angelastri")
	var ambience := scene.get_node_or_null("BackgroundMusic") as AudioStreamPlayer
	if ambience != null: ambience.volume_db = -10.0
	if (marker.global_position - doorway_center).dot(outward) < 0.0: outward = -outward
	doorway_tangent = Vector3.UP.cross(outward).normalized()
	doorway_half_width = maxf(box.size.x, box.size.z) * 0.5 + 0.3
	doors.assign([building.get_node("ContatoriSx/Contatori_Sx_SportelloDx"), building.get_node("ContatoriSx/Contatori_Sx_SportelloSx")])
	tower = scene.get_node("OcchioDiBue")
	# Truck colliders leave the cargo interior open; the camera must also avoid their visual hulls.
	for name in ["Camion", "Camion Shell"]:
		var vehicle: Node3D = building.get_node(name)
		var frame := Transform3D(vehicle.global_basis.orthonormalized(), vehicle.global_position)
		visual_blocks.append({"bounds": network.integration._bounds(vehicle, frame), "frame": frame})
	laugh = AudioStreamPlayer3D.new()
	laugh.name = "AngelastriDistantLaugh"
	laugh.stream = load("res://assets/models/enemies/Angelastri/risata_vampire.mp3")
	laugh.bus = &"SFX"
	laugh.volume_db = 6.0
	laugh.unit_size = 25.0
	laugh.max_distance = 80.0
	scene.add_child(laugh)
	laugh.global_position = marker.global_position
	var meters := building.get_node("ContatoriSx")
	var switch_sound := meters.get("switch_sound") as AudioStream
	if switch_sound != null:
		meter_click = AudioStreamPlayer3D.new()
		meter_click.name = "AngelastriNearbyMeterClick"
		meter_click.stream = switch_sound
		meter_click.bus = &"SFX"
		meter_click.volume_db = 2.0
		meter_click.unit_size = 2.0
		meter_click.max_distance = 12.0
		scene.add_child(meter_click)
	power.power_changed.connect(_power_changed)
	network.state.changed.connect(_network_changed)
	SaveManager.restore_completed.connect(_restore_finished)
	SaveManager.register_object(ID, self)
	_seed_boundary()
	configured = true
	call_deferred("_prewarm_performance")
	print("ANGELASTRI_ENCOUNTER_READY threshold=", doorway_center, " outward=", outward)
	if not SaveManager.restoring: _network_changed()

func _prewarm_performance() -> void:
	if not configured or not is_instance_valid(preview): return
	preview.warmup_presentation()
	while is_inside_tree() and preview.busy:
		await get_tree().process_frame
	if not is_inside_tree() or not is_instance_valid(preview.presentation): return
	# The marker and the stage geometry are static.  The former route search made
	# thousands of physics queries at the exact moment the player crossed the door.
	# Prepare the known clear diagonal while the map is idle instead.
	prewarmed_dance_yaw = preview.presentation.rotation.y
	prewarmed_dance_scale = 0.85
	dance_plan_ready = true
	print("ANGELASTRI_PERFORMANCE_PREWARMED yaw=", prewarmed_dance_yaw, " scale=", prewarmed_dance_scale)

func _seed_boundary() -> void:
	last_position = player.global_position
	inside = (last_position - doorway_center).dot(outward) < 0.0

func _network_changed() -> void:
	if not configured or SaveManager.restoring: return
	if network.state.pc_link or network.state.switch_link:
		event.arm(rng.randf_range(first_blackout_min, first_blackout_max))

func _power_changed(on: bool) -> void:
	if SaveManager.restoring: return
	event.power_changed(on)

func _process(delta: float) -> void:
	if not configured or SaveManager.restoring: return
	if bool(player.get("is_dead")):
		if cinematic or starting: _abort()
		return
	if recreate_actor and not starting:
		recreate_actor = false
		_restore_actor()
	if cinematic:
		_director(delta)
		if cinematic and not returning and is_instance_valid(preview.presentation):
			var stage: String = preview.presentation.presentation_stage
			if stage == "rest" or stage == "combat_ready": _begin_return()
		return
	if starting: return
	_sample_boundary()
	if event.tick(delta, inside, power.is_power_on()):
		_trigger_blackout()
		print("ANGELASTRI_BLACKOUT ", event.blackout_count)
	if event.stage == "waiting" and is_instance_valid(preview.presentation):
		detection_grace = maxf(0.0, detection_grace - delta)
		_patrol(delta)
		if detection_grace == 0.0 and _sees_player(): _start_cinematic(true)

func _sample_boundary() -> void:
	var point := player.global_position
	if point.distance_to(last_position) > 3.0:
		_seed_boundary()
		return
	var signed_distance := (point - doorway_center).dot(outward)
	var new_inside := inside
	if signed_distance < -0.25: new_inside = true
	elif signed_distance > 0.25: new_inside = false
	if new_inside != inside:
		var near_door := absf((point - doorway_center).dot(doorway_tangent)) < doorway_half_width and absf(point.y - doorway_center.y) < 2.2
		if near_door and absf(signed_distance) < 2.0:
			if event.crossed(not new_inside, next_blackout_delay): _start_cinematic(false)
		inside = new_inside
	last_position = point

func _trigger_blackout() -> void:
	for door in doors: door.open_door()
	if is_instance_valid(meter_click):
		meter_click.global_position = player.global_position
		meter_click.play()
	power.turn_off()
	GameplayUI.notify("forse è saltata la luce...")
	if is_instance_valid(laugh):
		laugh.play()
	# Restore can clear the initial warm-up. Starting it at the blackout gives the
	# map the whole reset/re-entry interval to load the performer before exit.
	call_deferred("_prewarm_performance")

func _start_cinematic(main_dialogue: bool) -> void:
	if starting or cinematic: return
	starting = true
	laugh.stop()
	_lock_player()
	await preview.spawn_preview(main_dialogue, false, main_dialogue)
	while is_instance_valid(preview.presentation) and preview.busy:
		await get_tree().process_frame
	if not is_inside_tree(): return
	starting = false
	if not is_instance_valid(preview.presentation) or bool(player.get("is_dead")):
		_abort()
		return
	event.stage = "dialogue" if main_dialogue else "performance"
	var actor: Node3D = preview.presentation.model
	intro_yaw = preview.presentation.rotation.y
	dance_yaw = intro_yaw
	if not main_dialogue:
		# Keep the approved three-quarter stage direction: it opens toward the
		# player-side of the piazzale without making Angelastri face the player.
		var player_direction := player.global_position - actor.global_position
		player_direction.y = 0.0
		if player_direction.length_squared() > 0.01:
			var player_yaw := atan2(player_direction.x, player_direction.z)
			dance_yaw = lerp_angle(intro_yaw, player_yaw, 0.65)
		elif dance_plan_ready:
			dance_yaw = prewarmed_dance_yaw
		preview.presentation.world_motion_scale = prewarmed_dance_scale
		# The imaginary TikTok camera faces the clear performance lane, independently of the player.
		intro_yaw = dance_yaw
		preview.presentation.rotation.y = intro_yaw
	var facing := player.global_position - actor.global_position
	orbit_base = atan2(facing.x, facing.z) if main_dialogue else intro_yaw
	camera = Camera3D.new()
	camera.name = "AngelastriCinematicCamera"
	scene.add_child(camera)
	camera.global_transform = player_camera.global_transform
	camera.fov = player_camera.fov
	camera.near = 0.08
	camera.far = player_camera.far
	camera.make_current()
	original_camera = player_camera.global_transform
	original_fov = player_camera.fov
	camera_exit_from = original_camera
	var exit_position := _choose_camera_exit_point(original_camera.origin)
	var exit_target := actor.global_position + Vector3.UP * 1.35
	camera_exit_to = Transform3D(Basis.looking_at(exit_target - exit_position, Vector3.UP), exit_position)
	director_time = 0.0
	returning = false
	cinematic = true
	_take_spotlight(actor)
	preview.presentation.start_presentation()
	print("ANGELASTRI_CINEMATIC main=", main_dialogue)

func _plan_dance() -> float:
	var yaw := intro_yaw
	for scale in [1.0, 0.85, 0.7, 0.55, 0.4]:
		preview.presentation.world_motion_scale = scale
		yaw = _plan_dance_scale(scale)
		if _route_contacts(yaw, scale) == 0: return yaw
	return yaw

func _route_contacts(yaw: float, scale: float) -> int:
	var actor: Node3D = preview.presentation.model
	var space := scene.get_world_3d().direct_space_state
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.55
	capsule.height = 1.9
	var contacts := 0
	for sample in range(641):
		var time: float = preview.presentation.dance_start_delay + preview.presentation.dance_duration() * sample / 640.0
		var point: Vector3 = preview.presentation.global_position + Basis(Vector3.UP, yaw) * preview.presentation.world_motion_offset(time) * scale
		var ground := PhysicsRayQueryParameters3D.create(point + Vector3.UP * 2.0, point - Vector3.UP * 3.0, 1)
		ground.exclude = [player.get_rid()]
		var floor_hit := space.intersect_ray(ground)
		if floor_hit.is_empty() or floor_hit.normal.y < 0.7:
			contacts += 1
			continue
		point.y = floor_hit.position.y
		var visual_collision := false
		for block in visual_blocks:
			var bounds: AABB = block.bounds
			var frame: Transform3D = block.frame
			if bounds.grow(0.6).has_point(frame.affine_inverse() * (point + Vector3.UP)): visual_collision = true
		if visual_collision:
			contacts += 1
			continue
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = capsule
		query.collision_mask = 1
		query.exclude = [player.get_rid()]
		query.transform.origin = point + Vector3.UP * 1.05
		if not space.intersect_shape(query).is_empty(): contacts += 1
	return contacts

func _plan_dance_scale(scale: float) -> float:
	var best := intro_yaw
	var best_contacts := 100000
	for step in range(17):
		var side := 1.0 if step % 2 == 1 else -1.0
		var yaw := intro_yaw + side * ceilf(step / 2.0) * PI / 8.0
		var contacts := _route_contacts(yaw, scale)
		if contacts < best_contacts:
			best = yaw
			best_contacts = contacts
		if contacts == 0: break
	print("ANGELASTRI_DANCE_ROUTE scale=", scale, " yaw=", best, " contacts=", best_contacts)
	return best

func _lock_player() -> void:
	if not lock_state.is_empty(): return
	GameplayUI.close_immediately()
	var weapon: Node = player.get_node("Head/Camera3D/WeaponHolder")
	var hud: CanvasLayer = scene.get_node("HUD")
	lock_state = {"physics": player.is_physics_processing(), "input": player.is_processing_unhandled_input(),
		"weapon_process": weapon.is_processing(), "weapon_physics": weapon.is_physics_processing(),
		"weapon_input": weapon.is_processing_unhandled_input(), "weapon_visible": weapon.visible, "hud": hud.visible}
	player.velocity = Vector3.ZERO
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	weapon.set_process(false)
	weapon.set_physics_process(false)
	weapon.set_process_unhandled_input(false)
	weapon.hide()
	hud.hide()

func _unlock_player() -> void:
	if lock_state.is_empty() or not is_instance_valid(player): return
	var weapon: Node = player.get_node("Head/Camera3D/WeaponHolder")
	player.set_physics_process(lock_state.physics)
	player.set_process_unhandled_input(lock_state.input)
	weapon.set_process(lock_state.weapon_process)
	weapon.set_physics_process(lock_state.weapon_physics)
	weapon.set_process_unhandled_input(lock_state.weapon_input)
	weapon.visible = lock_state.weapon_visible
	scene.get_node("HUD").visible = lock_state.hud
	lock_state.clear()

func _take_spotlight(actor: Node3D) -> void:
	light_state = {"target": tower.target, "active": tower.tracking_active, "automatic": tower.auto_activate_from_bruno_state,
		"visible": tower.spotlight.visible, "transform": tower.global_transform, "process": tower.is_processing(), "speed": tower.tracking_speed}
	var target := actor.global_position + Vector3.UP * 1.1
	var ray := PhysicsRayQueryParameters3D.create(tower.global_position, target, 1)
	ray.exclude = [player.get_rid()]
	var hit := scene.get_world_3d().direct_space_state.intersect_ray(ray)
	if not hit.is_empty():
		# The original tower position can be shadowed by the building near the meters.
		# Move the temporary rig over the exterior stage, retaining its original height.
		tower.global_position = Vector3(target.x + 3.0, tower.global_position.y, target.z + 4.0)
		print("ANGELASTRI_SPOTLIGHT_REPOSITION occluder=", hit.collider.get_path())
	tower.target = actor
	tower.auto_activate_from_bruno_state = false
	tower.tracking_speed = 8.0
	tower.set_process(true)
	tower.activate_spotlight()

func _release_spotlight() -> void:
	if light_state.is_empty() or not is_instance_valid(tower): return
	tower.target = light_state.target
	tower.tracking_active = light_state.active
	tower.auto_activate_from_bruno_state = light_state.automatic
	tower.spotlight.visible = light_state.visible
	tower.global_transform = light_state.transform
	tower.tracking_speed = light_state.speed
	tower.set_process(light_state.process)
	light_state.clear()

func _camera_point(target: Vector3, angle: float, distance: float, height: float) -> Vector3:
	var space := scene.get_world_3d().direct_space_state
	var best := target + Vector3.UP * 3.0
	var best_distance := 0.0
	for offset in [0.0, 0.45, -0.45, 0.9, -0.9, 1.5, -1.5, PI]:
		if event.stage == "dialogue" and absf(float(offset)) > 0.9: continue
		var point := target + Vector3(sin(angle + offset) * distance, height, cos(angle + offset) * distance)
		var query := PhysicsRayQueryParameters3D.create(target, point, 1)
		query.exclude = [player.get_rid()]
		var hit := space.intersect_ray(query)
		var clearance: float = target.distance_to(point) if hit.is_empty() else maxf(0.0, target.distance_to(hit.position) - 0.4)
		for block in visual_blocks:
			var bounds: AABB = block.bounds
			var frame: Transform3D = block.frame
			var contact: Variant = bounds.grow(0.25).intersects_segment(frame.affine_inverse() * target, frame.affine_inverse() * point)
			if contact != null: clearance = minf(clearance, maxf(0.0, target.distance_to(frame * contact) - 0.4))
		if clearance > best_distance:
			best_distance = clearance
			best = target + (point - target).normalized() * clearance
		if clearance >= target.distance_to(point) - 0.01: break
	return best

func _choose_camera_exit_point(start: Vector3) -> Vector3:
	var space := scene.get_world_3d().direct_space_state
	for distance in [1.8, 1.4, 1.0]:
		var candidate: Vector3 = start + outward * float(distance)
		var query := PhysicsRayQueryParameters3D.create(start, candidate, 1)
		query.exclude = [player.get_rid()]
		if space.intersect_ray(query).is_empty(): return candidate
	# The final fallback still moves the shot toward the open doorway, rather than
	# cutting toward the stage through the arch wall.
	return start + outward * 0.75

func _director(delta: float, music_time_override: float = -1.0) -> void:
	if not cinematic: return
	if not is_instance_valid(camera) or not is_instance_valid(preview.presentation):
		_abort()
		return
	director_time += delta
	if returning:
		return_time += delta
		var weight := smoothstep(0.0, 1.4, return_time)
		camera.global_transform = return_from.interpolate_with(player_camera.global_transform, weight)
		camera.fov = lerpf(camera.fov, original_fov, weight)
		if return_time >= 1.4: _finish_return()
		return
	var actor: Node3D = preview.presentation.model
	last_actor_pose = actor.global_transform
	var target := actor.global_position + Vector3.UP * 1.35
	if director_time < 0.8:
		var exit_weight := smoothstep(0.0, 0.8, director_time)
		camera.global_transform = camera_exit_from.interpolate_with(camera_exit_to, exit_weight)
		camera.fov = lerpf(original_fov, 56.0, exit_weight)
		return
	var shot_time := director_time - 0.8
	var dance: bool = preview.presentation.presentation_stage == "dance"
	var time: float = preview.presentation.music_sequence_position() if dance else shot_time
	if dance and music_time_override >= 0.0: time = music_time_override
	if dance:
		preview.presentation.rotation.y = lerp_angle(intro_yaw, dance_yaw, smoothstep(0.0, preview.presentation.dance_start_delay, time))
		preview.presentation._apply_world_motion(time)
	var angle := orbit_base + (sin(time * 0.027) * 1.2 if dance else sin(time * 0.08) * 0.15)
	var distance := 4.6 + sin(time * 0.07) * 0.8 if dance else 3.1
	# A recurring low point keeps the performer dominant in the frame during the dance.
	var height := -0.45 + sin(time * 0.04) * 0.5 if dance else 0.0
	var desired := _camera_point(target, angle, distance, height)
	var weight := 1.0 - exp(-delta * 2.5)
	var position := camera.global_position.lerp(desired, weight)
	# Recheck the smoothed position so a moving camera does not cut through scenery.
	var ray := PhysicsRayQueryParameters3D.create(target, position, 1)
	ray.exclude = [player.get_rid()]
	var hit := scene.get_world_3d().direct_space_state.intersect_ray(ray)
	if not hit.is_empty(): position = hit.position - (position - target).normalized() * 0.35
	for block in visual_blocks:
		var bounds: AABB = block.bounds
		var frame: Transform3D = block.frame
		var contact: Variant = bounds.grow(0.25).intersects_segment(frame.affine_inverse() * target, frame.affine_inverse() * position)
		if contact != null: position = frame * contact - (position - target).normalized() * 0.35
	var transform := Transform3D(Basis.looking_at(target - position, Vector3.UP), position)
	var entry := smoothstep(0.0, 1.4, shot_time)
	camera.global_transform = camera_exit_to.interpolate_with(transform, entry)
	camera.fov = lerpf(56.0, 50.0 if dance else 45.0, entry)

func _begin_return() -> void:
	if returning: return
	if not is_instance_valid(camera):
		_abort()
		return
	returning = true
	return_time = 0.0
	return_from = camera.global_transform

func _finish_return() -> void:
	var main: bool = event.stage == "dialogue"
	if is_instance_valid(player_camera): player_camera.make_current()
	if is_instance_valid(camera): camera.queue_free()
	camera = null
	_release_spotlight()
	_unlock_player()
	cinematic = false
	returning = false
	if main:
		event.stage = "combat"
		combat = COMBAT.new()
		add_child(combat)
		combat.configure(self, preview.presentation)
		fight_ready.emit()
		print("ANGELASTRI_COMBAT_STARTED")
	else:
		event.stage = "waiting"
		var presentation: Node3D = preview.presentation if is_instance_valid(preview) else null
		var actor: Node3D = presentation.model if is_instance_valid(presentation) else null
		if not is_instance_valid(actor):
			# A transition may be cancelled by restore/death in the same frame. The
			# player is already unlocked above; defer reconstruction instead of
			# dereferencing the released presentation. Keep the last dance pose so
			# the actor cannot be recreated at world origin and disappear.
			saved_actor_pose = last_actor_pose
			recreate_actor = true
			_seed_boundary()
			return
		# World motion already lives on the model node. Keep that local transform
		# intact: moving it into the presentation root was resetting the final
		# dance pose on some map instances and made Angelastri vanish.
		patrol_origin = actor.global_position
		patrol_target = patrol_origin
		patrol_wait = 3.0
		detection_grace = 3.0
		for clip in [&"mie/walking", &"mie/idle_new"]:
			presentation.animation.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
		presentation.animation.get_animation(&"mie/looking").loop_mode = Animation.LOOP_NONE
		presentation.animation.play(&"mie/idle_new", 0.6)
		print("ANGELASTRI_PLAYER_CONTROL_RETURNED")
	_seed_boundary()

func _patrol(delta: float) -> void:
	var actor: Node3D = preview.presentation.model
	var animation: AnimationPlayer = preview.presentation.animation
	if patrol_wait > 0.0:
		patrol_wait -= delta
		if patrol_wait > 0.0: return
		patrol_looking = not patrol_looking
		if patrol_looking:
			animation.play(&"mie/looking", 0.6)
			patrol_wait = animation.get_animation(&"mie/looking").length
			return
		patrol_target = actor.global_position
		for attempt in range(12):
			# Keep the stroll on the exterior side, towards the door/open piazzale,
			# instead of sampling equally into the building facade.
			var to_door := doorway_center - patrol_origin
			to_door.y = 0.0
			var candidate := patrol_origin + to_door.normalized() * rng.randf_range(0.8, 3.0) + outward * rng.randf_range(0.8, 2.0)
			candidate += doorway_tangent * rng.randf_range(-0.8, 0.8)
			if candidate.distance_to(actor.global_position) > 0.6 and _patrol_clear(candidate):
				patrol_target = candidate
				break
	var direction := patrol_target - actor.global_position
	direction.y = 0.0
	if direction.length() < 0.2:
		animation.play(&"mie/idle_new", 0.6)
		patrol_wait = rng.randf_range(2.0, 4.0)
		return
	direction = direction.normalized()
	var position := actor.global_position + direction * delta * 0.7
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.8
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.collision_mask = 1
	query.exclude = [player.get_rid()]
	query.transform.origin = position + Vector3.UP * 1.0
	query.exclude = [player.get_rid(), actor.get_rid()]
	var space := scene.get_world_3d().direct_space_state
	var ground := PhysicsRayQueryParameters3D.create(position + Vector3.UP * 1.0, position - Vector3.UP * 1.0, 1)
	ground.exclude = [player.get_rid()]
	ground.exclude = [player.get_rid(), actor.get_rid()]
	var floor_hit := space.intersect_ray(ground)
	if not space.intersect_shape(query).is_empty() or floor_hit.is_empty() or floor_hit.normal.y < 0.7:
		patrol_target = actor.global_position
		return
	position.y = floor_hit.position.y
	actor.global_position = position
	actor.global_rotation.y = lerp_angle(actor.global_rotation.y, atan2(direction.x, direction.z), minf(delta * 2.0, 1.0))
	if animation.assigned_animation != &"mie/walking" or not animation.is_playing(): animation.play(&"mie/walking", 0.6)

func _patrol_clear(point: Vector3) -> bool:
	var ray := PhysicsRayQueryParameters3D.create(point + Vector3.UP * 2.0, point - Vector3.UP * 3.0, 1)
	ray.exclude = [player.get_rid()]
	ray.exclude = [player.get_rid(), preview.presentation.model.get_rid()]
	var floor_hit := scene.get_world_3d().direct_space_state.intersect_ray(ray)
	if floor_hit.is_empty() or floor_hit.normal.y < 0.7: return false
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.8
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.collision_mask = 1
	query.exclude = [player.get_rid()]
	query.transform.origin = Vector3(point.x, floor_hit.position.y + 1.05, point.z)
	query.exclude = [player.get_rid(), preview.presentation.model.get_rid()]
	return scene.get_world_3d().direct_space_state.intersect_shape(query).is_empty()

func _sees_player() -> bool:
	var actor: Node3D = preview.presentation.model
	var from := actor.global_position + Vector3.UP * 1.6
	var to := player_camera.global_position
	var direction := to - from
	if direction.length() > dialogue_distance or direction.length() < 0.1: return false
	var horizontal := direction
	horizontal.y = 0.0
	if horizontal.length_squared() < 0.01: return false
	if actor.global_basis.z.normalized().dot(horizontal.normalized()) < 0.65: return false
	if (-player_camera.global_basis.z).dot((-direction).normalized()) < 0.35: return false
	var query := PhysicsRayQueryParameters3D.create(from, to, 1)
	query.exclude = [actor.get_rid()]
	var hit := scene.get_world_3d().direct_space_state.intersect_ray(query)
	return hit.is_empty() or hit.collider == player

func blocks_saving() -> bool:
	if cinematic or starting or event.stage in ["fight_ready", "combat"]: return true
	for door in doors:
		if absf(angle_difference(door.rotation.y, door.target_rotation_y)) > 0.01: return true
	return false

func restore_priority() -> int:
	return 30

func get_persistent_state() -> Dictionary:
	var data: Dictionary = event.snapshot()
	data["meter_doors"] = [doors[0].is_open, doors[1].is_open]
	if is_instance_valid(preview.presentation): data["actor_pose"] = preview.presentation.model.global_transform
	return data

func apply_persistent_state(data: Dictionary) -> void:
	_abort()
	event.restore(data)
	var opened: Array = data.get("meter_doors", [false, false])
	for i in doors.size():
		if i < opened.size() and bool(opened[i]): doors[i].open_door()
		else: doors[i].close_door()
		doors[i].rotation.y = doors[i].target_rotation_y
	saved_actor_pose = data.get("actor_pose", Transform3D.IDENTITY)
	recreate_actor = event.stage in ["waiting", "fight_ready", "defeated"]

func _restore_finished() -> void:
	_seed_boundary()
	# Save restoration clears the temporary preview. Rebuild it once the map has
	# settled so the third exit still has no model-instantiation hitch.
	call_deferred("_prewarm_performance")
	_network_changed()

func _restore_actor() -> void:
	starting = true
	await preview.spawn_preview(false, false)
	while is_instance_valid(preview.presentation) and preview.busy: await get_tree().process_frame
	starting = false
	if not is_instance_valid(preview.presentation): return
	preview.presentation.global_transform = saved_actor_pose
	preview.presentation.model.position = Vector3.ZERO
	for clip in [&"mie/walking", &"mie/idle_new"]:
		preview.presentation.animation.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
	preview.presentation.animation.play(&"mie/idle_new", 0.6)
	if event.stage == "defeated":
		preview.presentation.animation.play(&"mie/death", 0.0)
		preview.presentation.animation.seek(preview.presentation.animation.get_animation(&"mie/death").length, true)
		preview.presentation.animation.pause()
	elif event.stage == "fight_ready":
		event.stage = "combat"
		combat = COMBAT.new()
		add_child(combat)
		combat.configure(self, preview.presentation)
	preview._release_background_music()
	patrol_origin = saved_actor_pose.origin
	patrol_target = patrol_origin
	patrol_wait = 3.0
	detection_grace = 3.0

func _abort() -> void:
	if is_instance_valid(combat):
		combat.release_player()
		combat.queue_free()
	combat = null
	starting = false
	cinematic = false
	returning = false
	if is_instance_valid(camera):
		if is_instance_valid(player_camera): player_camera.make_current()
		camera.queue_free()
	camera = null
	_release_spotlight()
	_unlock_player()
	if is_instance_valid(preview): preview.clear_preview()
	if is_instance_valid(laugh): laugh.stop()

func _exit_tree() -> void:
	_abort()
	if is_instance_valid(laugh): laugh.queue_free()
	if is_instance_valid(meter_click): meter_click.queue_free()
	SaveManager.unregister_object(ID, self)
