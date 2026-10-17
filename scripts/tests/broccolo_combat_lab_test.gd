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

func capture(filename: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/" + filename + ".png")

func run() -> void:
	if DisplayServer.get_name() != "headless": root.size = Vector2i(1280, 720)
	var packed := load("res://scenes/levels/broccolo_combat_test.tscn") as PackedScene
	var world = packed.instantiate()
	world.auto_combat = false
	world.start_in_fps = false
	root.add_child(world)
	current_scene = world
	while not world.ready_for_test: await process_frame
	var boss = world.boss
	await frames(130)
	check(boss.state == "chase", "Shrink did not complete")
	check(boss.visual.scale.is_equal_approx(Vector3.ONE * boss.miniature_scale), "Final miniature scale")
	check(world.hud.boss_phase_1_texture.resource_path == "res://assets/ui/broccolo.png", "Portrait not connected")
	check(world.player.get_node("Head/Camera3D/WeaponHolder").owns_pistol, "Test weapon override failed")
	check(world.graph.get_point_count() > 500, "Arena graph empty")
	check(boss.miniature_scale > 0.11, "Miniature was not enlarged")
	for name in [&"running", &"idle_to_run", &"running_change_direction", &"running_jump_to_run", &"running_to_stop", &"waving"]:
		check(boss.animation.has_animation(StringName("mie/" + String(name))), "New clip absent: " + String(name))
	check(boss.animation.get_animation(boss.run_clip).loop_mode == Animation.LOOP_LINEAR, "Running loop missing")
	await frames(45)
	await capture("broccolo_lab_protected")
	var protected_health: int = boss.health
	boss.take_damage(10)
	check(boss.health == protected_health, "Boss vulnerable during chase")
	boss.begin_show()
	check(boss.vulnerable(), "Show did not open damage window")
	await frames(3)
	await capture("broccolo_lab_vulnerable")
	boss.take_bullet_hit(2, boss.global_position + Vector3.UP * 0.12)
	check(boss.health == protected_health - 2, "Vulnerable boss did not take damage")
	check(world.hud.boss_health_bar.value == boss.health, "Shared bar not updated")
	boss.take_damage(2)
	check(boss.health == protected_health - 2, "Boss repeated hit during reaction")
	boss.begin_show()
	check(not boss.vulnerable(), "Show bypassed post-hit recovery")
	boss.recovery = 0
	boss.begin_move(boss.get_node("Moves/FlyingKick"))
	check(not boss.vulnerable(), "Boss attack was vulnerable")
	boss.state = "chase"
	var copy = world.emit_copy()
	check(copy != null, "Copy could not emerge")
	check(copy.health == 2 and copy.vulnerable(), "Copy initial HP/vulnerability")
	check(copy.aura.get_shader_parameter("tint") == copy.copy_aura_color and copy.copy_aura_strength < 0.1, "Subtle orange aura missing")
	check(copy.global_position.distance_to(boss.global_position) < 0.4, "Copy did not originate at boss")
	copy.begin_move(copy.get_node("Moves/FlyingKick"))
	copy.locomotion = "run"
	copy.velocity = Vector3.BACK * copy.run_speed
	copy.take_bullet_hit(100, copy.global_position)
	check(copy.health == 1 and not copy.vulnerable(), "Copy should be protected during hit animation")
	check(copy.last_hit_clip == &"mie/running_hit_short" and copy.animation.current_animation_position < 0.01, "Running hit did not start immediately")
	copy.take_damage(1)
	check(copy.health == 1, "Copy damaged during hit protection")
	await frames(int(copy.duration * 60) + 2)
	check(copy.vulnerable(), "Copy did not regain vulnerability after hit")
	copy.take_damage(1)
	check(copy.state == "dead" and copy.health == 0, "Copy did not die on second hit")
	copy.preview_clip(&"mie/idle")
	copy.begin_move(copy.get_node("Moves/FlyingKick"))
	check(copy.state == "dead", "Preview controls revived a dying copy")
	var dead_ref: WeakRef = weakref(copy)
	await frames(5)
	check(dead_ref.get_ref() != null, "Death animation skipped")
	var death_length: float = copy.duration
	await frames(int(death_length * 60) + 5)
	check(dead_ref.get_ref() != null and copy.state == "pooled" and not copy.visible, "Copy not retired after death")
	world.copies.clear()
	# Nondefault serializable Inspector settings survive packing and apply to runtime.
	var config = world.actor_scene.instantiate()
	config.copy_hits = 4
	config.principal = false
	var serialized := PackedScene.new()
	check(serialized.pack(config) == OK, "Inspector config pack failed")
	config.free()
	check(ResourceSaver.save(serialized, "res://.godot/broccolo_lab_config.tscn") == OK, "Inspector config save failed")
	var configured = load("res://.godot/broccolo_lab_config.tscn").instantiate()
	world.add_child(configured)
	check(configured.health == 4, "Custom copy HP not applied")
	configured.queue_free()
	await frames(2)
	# Actual collision path around the tall wall.
	var path: PackedVector3Array = world.graph.get_point_path(world.graph.get_closest_point(Vector3(0, 0, 0)), world.graph.get_closest_point(Vector3(4, 0, 0)))
	var goes_around := false
	for point in path:
		if absf(point.z) > 2.0: goes_around = true
	check(goes_around, "Route crosses tall wall instead of going around")
	# Actual locomotion transitions; inversion must rotate once, not twice.
	boss.locomotion = "idle"
	boss.rotation.y = 0
	boss._update_locomotion(Vector3.BACK, boss.run_speed, 1.0 / 60)
	check(boss.animation.assigned_animation == boss.start_run_clip, "Start clip not selected")
	boss.locomotion_time = boss.locomotion_duration + 0.01
	boss._update_locomotion(Vector3.BACK, boss.run_speed, 1.0 / 60)
	check(boss.animation.assigned_animation == boss.run_clip, "Running clip not selected")
	boss.turn_wait = 0
	boss._update_locomotion(Vector3.FORWARD, boss.run_speed, 1.0 / 60)
	check(boss.locomotion == "turn", "180-degree turn did not select inversion")
	boss.locomotion_time = boss.locomotion_duration * 0.5
	boss._update_locomotion(Vector3.FORWARD, boss.run_speed, 1.0 / 60)
	check(absf(absf(boss.rotation.y) - PI * 0.5) < 0.1, "Turn body did not rotate halfway")
	boss.locomotion_time = boss.locomotion_duration + 0.01
	boss._update_locomotion(Vector3.FORWARD, boss.run_speed, 1.0 / 60)
	boss._update_locomotion(Vector3.ZERO, 0, 1.0 / 60)
	check(boss.animation.assigned_animation == boss.stop_run_clip, "Stopping clip not selected")
	boss.locomotion = "jump"
	boss.jump_left = 0
	await frames(2)
	boss._update_locomotion(Vector3.BACK, boss.run_speed, 1.0 / 60)
	check(boss.animation.assigned_animation == boss.landing_clip, "Landing clip not selected")
	# Runtime pursuit over the 20 cm obstacle, physical body and animation.
	boss.global_position = Vector3(0, 0.02, 1.3)
	boss.velocity = Vector3.ZERO
	boss.state = "chase"
	boss.locomotion = "idle"
	boss.show_timer = 100
	boss.boss_initial_distance = 0.55
	boss.autonomous = true
	world.player.global_position = Vector3(0, 0.9, 4)
	var jumped := false
	var reached := false
	for index in 200:
		await physics_frame
		if boss.animation.assigned_animation == &"mie/running_jump": jumped = true
		if boss.global_position.z > 2.65:
			reached = true
			break
	check(jumped and reached, "Pursuit failed to jump obstacle")
	boss.autonomous = false
	# Attack checks vertical separation and walls; one impact per animation.
	boss.global_position = Vector3(0, 0.02, 0)
	world.player.global_position = Vector3(0, 0.9, 0.5)
	boss.rotation = Vector3.ZERO
	boss.begin_move(boss.get_node("Moves/FlyingKick"))
	var player_health: int = world.player.health
	await frames(int(boss.duration * 60) + 2)
	check(world.player.health == player_health - 5, "Melee did not connect exactly once")
	world.max_copies = 2
	world.regeneration_seconds = 0.5
	world.emission_interval = 0.2
	world.start_combat()
	await frames(50)
	check(world.copies.size() == 2, "Copy cap not filled")
	if world.copies.size() == 2:
		check(world.copies[0].scatter_direction.dot(world.copies[1].scatter_direction) < 0.6, "Copies emitted in same direction")
	check(world.emit_copy() == null, "Copy cap exceeded")
	var victim = world.copies[0]
	victim.take_damage(1)
	await frames(int(victim.duration * 60) + 2)
	victim.take_damage(1)
	await frames(int(victim.duration * 60) + 4)
	await process_frame
	check(world.copies.size() == 1, "Dead copy must free its slot")
	await frames(15)
	check(world.copies.size() == 1, "Regenerated before cooldown")
	await frames(35)
	check(world.copies.size() == 2, "Cooldown did not regenerate copy")
	world.stop_combat()
	# Every supplied clip can be sampled; no source animation loop mutated.
	for clip in boss.animation.get_animation_list():
		if not String(clip).begins_with("mie/"): continue
		boss.preview_clip(clip)
		boss.animation.seek(boss.animation.get_animation(clip).length * 0.5, true)
	check(load("res://assets/models/enemies/broccolo/animation_compatibili/in_place/dying.res").loop_mode == Animation.LOOP_NONE, "Source death changed")
	if DisplayServer.get_name() != "headless":
		world.set_overview(true)
		for actor in world.copies:
			if is_instance_valid(actor): actor.hide()
		boss.rotation.y = 0
		for name in [&"running", &"idle_to_run", &"running_change_direction", &"running_jump_to_run", &"running_to_stop", &"waving"]:
			var clip := StringName("mie/" + String(name))
			boss.preview_clip(clip)
			boss.animation.play(clip, 0)
			boss.animation.seek(boss.animation.get_animation(clip).length * 0.5, true)
			boss.animation.advance(0)
			boss.animation.pause()
			await frames(2)
			await capture("broccolo_run_" + String(name))
		boss.preview_clip(&"mie/idle")
		await frames(20)
		await capture("broccolo_combat_lab")
	boss.recovery = 0
	boss.begin_show()
	boss.take_damage(1000)
	check(not world.combat and not world.spawning and boss.state == "dead", "Principal death did not stop encounter")
	boss.begin_show()
	check(boss.state == "dead", "Show control revived principal")
	print("BROCCOLO_COMBAT_LAB failures=", failures, " graph=", world.graph.get_point_count())
	world.queue_free()
	await frames(3)
	quit(0 if failures == 0 else 1)
