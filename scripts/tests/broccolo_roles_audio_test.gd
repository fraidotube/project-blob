extends SceneTree
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func frames(count: int) -> void:
	for index in count: await physics_frame
func run() -> void:
	if DisplayServer.get_name() != "headless": root.size = Vector2i(1280, 720)
	var world = load("res://scenes/levels/broccolo_combat_test.tscn").instantiate()
	world.auto_combat = false
	world.start_in_fps = false
	root.add_child(world)
	current_scene = world
	while not world.ready_for_test: await process_frame
	await frames(130)
	var boss = world.boss
	var player = world.player
	check(boss.miniature_scale == 0.2, "Final scale not applied")
	var before: int = boss.health
	var roles: Array[Node] = []
	for index in 3: roles.append(world.emit_copy())
	check(roles[0].strategy == 0 and roles[1].strategy == 1 and roles[2].strategy == 2, "Distinct role slots missing")
	check(roles[0].run_speed > roles[2].run_speed and roles[2].run_speed > roles[1].run_speed, "Speeds lack variety")
	check(roles[0].show_interval == 0, "Aggressor stops for shows")
	check(roles[1].show_interval == 0, "Throw-only role stops for shows")
	roles[0].locomotion = "run"
	roles[0].velocity = Vector3.RIGHT * roles[0].run_speed
	roles[0].take_damage(1)
	check(roles[0].last_hit_clip == &"mie/running_hit_short", "Runner hit clip not selected")
	check(roles[0].animation.current_animation_position < 0.01, "Hit animation delayed")
	roles[0].take_damage(1)
	check(roles[0].health == 1 and not roles[0].vulnerable(), "Hit invulnerability failed")
	check(boss.health == before and world.hud.boss_health_bar.value == before, "Copy damage decreased boss bar")
	await frames(int(roles[0].duration * 60) + 2)
	check(roles[0].vulnerable(), "Copy remained protected after hit")
	for actor in roles: actor.preview_clip(&"mie/idle")
	# Boss progressively closes in and shortens pauses.
	boss.global_position = Vector3(0, 0.02, -4)
	player.global_position = Vector3(0, 0.9, 0)
	boss.health = boss.max_health
	var far_goal: Vector3 = boss._chase_goal(0)
	boss.health = 1
	var near_goal: Vector3 = boss._chase_goal(0)
	check(Vector2(far_goal.x, far_goal.z).length() > Vector2(near_goal.x, near_goal.z).length() + 2, "Low-health boss does not approach")
	boss.begin_move(boss.get_node("Moves/FlyingKick"))
	boss.elapsed = boss.duration
	boss.applied = true
	boss._physics_process(0)
	var fast_delay: float = boss.cooldown
	boss.health = boss.max_health
	boss.begin_move(boss.get_node("Moves/FlyingKick"))
	boss.elapsed = boss.duration
	boss.applied = true
	boss._physics_process(0)
	check(boss.cooldown > fast_delay + 2, "Boss attack rate does not increase with damage")
	boss.preview_clip(&"mie/idle")
	# Four valid MP3 streams per voice set, no concurrent exclamations.
	check(boss.audio.exclamations.size() == 4 and boss.audio.copy_exclamations.size() == 4, "Exclamations missing")
	for stream in boss.audio.exclamations + boss.audio.copy_exclamations:
		check(stream != null and stream.get_length() > 0.1, "Invalid exclamation stream")
	boss.show_index = 2
	boss.begin_show()
	check(String(boss.move.clip).begins_with("mie/dancing"), "Periodic ballet missing")
	check(boss.audio.voice.playing, "Exclamation did not start")
	check(not world.claim_voice(roles[2]), "Voice overlap allowed")
	check(boss.get_node("MouthPresentation").voice == boss.audio.voice, "Voice not connected to mouth")
	await frames(2)
	boss.audio.set_paused(true)
	await process_frame
	check(boss.audio.voice.stream_paused, "Voice pause not applied")
	boss.audio.set_paused(false)
	boss.audio.stop_voice()
	boss.preview_clip(&"mie/idle")
	# Caster releases a real sphere once, hits the player, never uses melee.
	var caster = roles[1]
	caster.global_position = Vector3(-6, 0.02, 1)
	player.global_position = Vector3(-6, 0.9, 5)
	caster.rotation.y = 0
	caster.state = "chase"
	caster.cooldown = 0
	caster.autonomous = true
	await frames(2)
	check(caster.state == "throw", "Throw state missing")
	caster.autonomous = false
	var initial_health: int = player.health
	var initial_burn_damage: int = world.burn_status.damage_applied
	var release_frames := int(caster.duration * caster.move.impact_fraction * 60) + 3
	await frames(release_frames)
	if DisplayServer.get_name() != "headless":
		world.set_process(false)
		world.selected = caster
		world.study_camera.global_position = caster.global_position + Vector3(2, 1.2, 3)
		world.study_camera.look_at(caster.global_position + Vector3(0, 0.3, 0.8))
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/broccolo_lanciatore.png")
		world.set_process(true)
	await frames(int(caster.duration * 60) + 100 - release_frames)
	check(caster.projectiles_fired == 1, "Throw did not release exactly one sphere")
	check(player.health == initial_health - 7 - (world.burn_status.damage_applied - initial_burn_damage), "Energy sphere impact/burn damage mismatch")
	# Explosion cannot damage through the tall wall.
	player.global_position = Vector3(2.5, 0.9, 0)
	var sphere = load("res://scripts/enemies/broccolo_lab_energy.gd").new()
	sphere.target = player
	sphere.position = Vector3(1.55, 0.9, 0)
	sphere.radius = 2
	world.add_child(sphere)
	initial_health = player.health
	sphere.detonate()
	check(player.health == initial_health, "Explosion damaged through wall")
	# Flanker chooses a lateral waypoint instead of the player's position.
	var flanker = roles[2]
	flanker.global_position = Vector3(-4, 0.02, 3)
	flanker.flank_left = 2
	flanker.scatter_direction = Vector3.RIGHT
	flanker.flank_goal = Vector3.ZERO
	var goal: Vector3 = flanker._chase_goal(0.1)
	check(goal.distance_to(player.global_position) > 2, "Flanker uses direct chase goal")
	# Physical movement yields pitched steps; wall stalls trigger hop then escape.
	var runner = roles[0]
	runner.global_position = Vector3(-5, 0.02, -4)
	runner.state = "chase"
	runner.set_physics_process(false)
	for index in 30:
		await physics_frame
		runner.velocity = Vector3(2, -0.2, 0)
		runner.move_and_slide()
		runner.audio.tick(1.0 / 60)
	check(runner.audio.steps_played > 0 and runner.audio.footsteps.pitch_scale > 1.4, "Pitched footsteps not emitted")
	runner.global_position = Vector3(1.68, 0.02, 0)
	runner.rotation.y = PI * 0.5
	var jumped := false
	var escaped := false
	for index in 140:
		await physics_frame
		runner.velocity = Vector3(3, -0.2, 0)
		runner.navigation_intent = Vector3.RIGHT * 3
		runner.move_and_slide()
		runner._recover_stuck(1.0 / 60)
		if runner.stuck_jumps > 0: jumped = true
		if runner.escape_left > 0: escaped = true
	check(jumped and escaped, "Wall stall did not attempt jump and new direction")
	world.stop_combat()
	await frames(90)
	print("BROCCOLO_ROLES_AUDIO failures=", failures)
	world.queue_free()
	await frames(4)
	quit(0 if failures == 0 else 1)
