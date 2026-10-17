extends SceneTree

var failures := 0
var pictures := false

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, message: String) -> void:
	if value: return
	failures += 1
	push_error("ANGELASTRI_ENCOUNTER_TEST " + message)

func photo(name: String) -> void:
	if not pictures: return
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/angelastri_encounter_" + name + ".png")

func run() -> void:
	pictures = DisplayServer.get_name() != "headless"
	if pictures:
		root.mode = Window.MODE_WINDOWED
		root.size = Vector2i(1280, 720)
	root.get_node("SaveManager").save_path = "res://.godot/angelastri_encounter_fixture.cfg"
	change_scene_to_file("res://scenes/maps/map_test.tscn")
	await process_frame
	await process_frame
	var encounter: Node = current_scene.get_node("AngelastriEncounter")
	while not encounter.configured: await process_frame
	var player: CharacterBody3D = encounter.player
	var debug: Node = encounter.preview
	player.set_physics_process(false)
	var pose := player.global_transform
	var tower: Node = encounter.tower
	var old_target: Node = tower.target
	var old_light_pose: Transform3D = tower.global_transform
	check(not debug.enabled, "Debug hotkeys remain enabled")
	for code in [KEY_F10, KEY_F11, KEY_F12]:
		var key := InputEventKey.new()
		key.keycode = code
		key.pressed = true
		debug._unhandled_input(key)
	check(debug.presentation == null or not debug.presentation.visible, "Disabled keys revealed actor")
	var network: Node = encounter.network
	network.integration.loot.apply_persistent_state({"defeated": true, "has_racket": false})
	# Restore an old post-Bruno checkpoint without an Angelastri object.
	encounter.apply_persistent_state({})
	encounter._restore_finished()
	await encounter._prewarm_performance()
	check(encounter.event.stage == "dormant", "Old checkpoint armed event without cable")
	encounter.first_blackout_min = 0.05
	encounter.first_blackout_max = 0.05
	encounter.next_blackout_delay = 0.05
	var inside_point: Vector3 = encounter.doorway_center - encounter.outward * 0.7
	var outside_point: Vector3 = encounter.doorway_center + encounter.outward * 0.7
	inside_point.y = pose.origin.y
	outside_point.y = pose.origin.y
	player.global_position = inside_point
	encounter._seed_boundary()
	encounter.power.turn_on()
	network.state.pc_link = true
	network.state.changed.emit()
	check(encounter.event.armed, "First Fritz cable did not arm event")
	for count in [1, 2, 3]:
		encounter._process(0.1)
		check(encounter.event.blackout_count == count and not encounter.power.is_power_on(), "Blackout count/power wrong")
		check(encounter.doors[0].is_open and encounter.doors[1].is_open, "Meter doors did not open")
		player.global_position = outside_point
		encounter._sample_boundary()
		if count < 3:
			check(debug.presentation != null and not debug.presentation.visible, "Actor appeared before third exit")
			encounter.power.turn_on()
			encounter._process(10.0)
			check(encounter.event.blackout_count == count, "Blackout while still outside")
			player.global_position = inside_point
			encounter._sample_boundary()
			check(encounter.event.stage == "countdown", "Returning inside did not rearm")
	var start := Time.get_ticks_msec()
	while (encounter.starting or not encounter.cinematic) and Time.get_ticks_msec() - start < 30000:
		await process_frame
	check(encounter.cinematic and encounter.camera.current, "Third outward crossing did not start cinematic")
	var virtual_facing := Basis(Vector3.UP, encounter.intro_yaw).z
	check(debug.presentation.global_basis.z.dot(virtual_facing) > 0.99, "First performance faces player rather than virtual camera")
	check(not player.is_physics_processing() and not player.is_processing_unhandled_input(), "Player input not locked")
	check(not current_scene.get_node("HUD").visible, "HUD not hidden")
	check(tower.target == debug.presentation.model and tower.spotlight.visible, "Spotlight did not acquire actor")
	var lamp_ray := PhysicsRayQueryParameters3D.create(tower.global_position, debug.presentation.model.global_position + Vector3.UP * 1.1, 1)
	lamp_ray.exclude = [player.get_rid(), debug.presentation.model.get_rid()]
	check(current_scene.get_world_3d().direct_space_state.intersect_ray(lamp_ray).is_empty(), "Building blocks spotlight")
	check(not root.get_node("SaveManager").can_save(), "Saving allowed during cinematic")
	var menu_music: AudioStreamPlayer = root.get_node("AudioManager").music_player
	check((not menu_music.playing or menu_music.stream_paused) and current_scene.get_node("BackgroundMusic").stream_paused, "Music overlap")
	encounter.set_process(false)
	debug.presentation.set_process(false)
	for i in range(90): encounter._director(1.0 / 30.0)
	await photo("intro")
	debug.presentation.advance_presentation()
	debug.presentation.sequence = false
	var camera_range := AABB(encounter.camera.global_position, Vector3.ZERO)
	var blocked := 0
	var colliding := 0
	for i in range(1, 601):
		var time: float = (debug.presentation.dance_start_delay + debug.presentation.dance_duration()) * i / 600.0
		debug.presentation.music.seek(time)
		debug.presentation.sync_sequence(time)
		encounter._director(0.186, time)
		tower._track_target(0.186)
		camera_range = camera_range.expand(encounter.camera.global_position)
		var target: Vector3 = debug.presentation.model.global_position + Vector3.UP * 1.1
		var ray := PhysicsRayQueryParameters3D.create(encounter.camera.global_position, target, 1)
		ray.exclude = [player.get_rid(), debug.presentation.model.get_rid()]
		if not current_scene.get_world_3d().direct_space_state.intersect_ray(ray).is_empty(): blocked += 1
		var shape := CapsuleShape3D.new()
		shape.radius = 0.4
		shape.height = 1.8
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = shape
		query.collision_mask = 1
		query.exclude = [player.get_rid(), debug.presentation.model.get_rid()]
		query.transform.origin = debug.presentation.model.global_position + Vector3.UP
		var contacts: Array = current_scene.get_world_3d().direct_space_state.intersect_shape(query)
		if not contacts.is_empty():
			colliding += 1
			if colliding < 5: print("ANGELASTRI_ROUTE_OBSTACLE t=", time, " collider=", contacts[0].collider.get_path())
		if i in [120, 300, 500]: await photo("dance_" + str(i))
	check(camera_range.size.length() > 3.0, "Camera did not move with performance")
	check(blocked == 0, "Camera line of sight occluded")
	check(colliding == 0, "Dance trajectory intersects obstacles from marker")
	encounter._begin_return()
	for i in range(50): encounter._director(1.0 / 30.0)
	check(encounter.event.stage == "waiting" and encounter.player_camera.current, "Control not returned after dance")
	check(player.is_processing_unhandled_input() and current_scene.get_node("HUD").visible, "Input/HUD not restored")
	var patrol_actor: Node3D = debug.presentation.model if is_instance_valid(debug.presentation) else null
	check(is_instance_valid(patrol_actor) and patrol_actor.visible, "Angelastri disappeared after dance return")
	if is_instance_valid(patrol_actor):
		var patrol_start := patrol_actor.global_position
		encounter.patrol_wait = 0.0
		encounter.patrol_looking = false
		encounter.patrol_target = patrol_start + Vector3(0.8, 0.0, 0.0)
		for i in range(90): encounter._patrol(1.0 / 30.0)
		check(patrol_actor.global_position.distance_to(patrol_start) > 0.1, "Angelastri did not patrol after dance")
	check(tower.target == old_target, "Bruno spotlight state not restored")
	check(tower.global_transform.is_equal_approx(old_light_pose), "Spotlight rig transform not restored")
	var saved: Dictionary = encounter.get_persistent_state()
	var saved_position: Vector3 = debug.presentation.model.global_position
	encounter.apply_persistent_state(saved)
	await encounter._restore_actor()
	encounter.recreate_actor = false
	check(debug.presentation.model.global_position.distance_to(saved_position) < 0.01, "Waiting pose restore changed position")
	check(encounter.event.blackout_count == 3 and encounter.event.stage == "waiting", "Restore replayed event")
	# Player detection must reject real scenery before starting the second dialogue.
	var actor: Node3D = debug.presentation.model
	player.global_position = actor.global_position + actor.global_basis.z * 2.0 + Vector3.UP
	var obstruction := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var wall := BoxShape3D.new()
	wall.size = Vector3(4, 4, 0.3)
	collider.shape = wall
	obstruction.add_child(collider)
	current_scene.add_child(obstruction)
	obstruction.global_transform = Transform3D(actor.global_basis, actor.global_position + actor.global_basis.z + Vector3.UP)
	await physics_frame
	check(not encounter._sees_player(), "Detection ignored wall")
	obstruction.queue_free()
	await physics_frame
	await physics_frame
	check(encounter._sees_player(), "Clear player not detected")
	player.set_physics_process(true)
	encounter.detection_grace = 0.0
	encounter._process(0.01)
	while encounter.starting: await process_frame
	check(encounter.event.stage == "dialogue" and debug.presentation.voice.playing, "Second dialogue not started")
	debug.presentation.advance_presentation()
	debug.presentation.presentation_stage = "combat_ready"
	encounter._begin_return()
	for i in range(50): encounter._director(1.0 / 30.0)
	check(encounter.event.stage == "combat" and player.is_physics_processing() and is_instance_valid(encounter.combat), "Fight handoff failed")
	check(tower.target == encounter.combat and tower.tracking_active and tower.spotlight.visible and tower.is_processing(), "Combat spotlight did not acquire moving boss")
	check(not tower.auto_activate_from_bruno_state, "Bruno automatic tracking remained enabled during Angelastri combat")
	encounter.combat.set_physics_process(false)
	var combat_pose: Transform3D = encounter.combat.global_transform
	var rig_position: Vector3 = tower.global_position
	for offset in [Vector3(2, 0, 0), Vector3(-2, 0, 2)]:
		encounter.combat.global_position = combat_pose.origin + offset
		for i in range(60): tower._process(1.0 / 60.0)
		var direction: Vector3 = (encounter.combat.global_position + Vector3.UP * tower.target_height - tower.global_position).normalized()
		check((-tower.global_basis.z).dot(direction) > 0.999, "Spotlight failed to follow moving combat body")
		check(tower.global_position.is_equal_approx(rig_position), "Tracking moved spotlight rig instead of aiming")
	encounter.combat.global_transform = combat_pose
	encounter.combat.state = "chase"
	encounter.combat.take_damage(100)
	encounter.configured = true
	encounter._process(0.0)
	check(tower.target == old_target and tower.global_transform.is_equal_approx(old_light_pose), "Defeat did not restore Bruno spotlight")
	await encounter._test_combat()
	check(tower.target == encounter.combat and tower.spotlight.visible, "F11 shortcut did not acquire spotlight")
	player.is_dead = true
	encounter._process(0.0)
	check(tower.target == old_target and encounter.light_state.is_empty(), "Player death did not release combat spotlight")
	player.is_dead = false
	encounter._abort()
	check(tower.target == old_target and tower.global_transform.is_equal_approx(old_light_pose), "Combat cleanup did not restore spotlight")
	await process_frame
	print("ANGELASTRI_ENCOUNTER_MAP_TEST failures=", failures, " camera_travel=", camera_range.size, " occluded=", blocked, " dance_collisions=", colliding)
	quit(0 if failures == 0 else 1)
