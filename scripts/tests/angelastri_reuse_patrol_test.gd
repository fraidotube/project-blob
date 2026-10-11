extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var world := Node3D.new()
	root.add_child(world)
	current_scene = world
	var floor_body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(40, 0.2, 40)
	shape.shape = box
	floor_body.add_child(shape)
	world.add_child(floor_body)
	floor_body.position.y = -0.1
	var player: CharacterBody3D = load("res://scenes/player/player.tscn").instantiate()
	player.name = "Player"
	world.add_child(player)
	player.set_physics_process(false)
	player.position = Vector3(0, 0.9, 10)
	var marker := Marker3D.new()
	marker.name = "Angelastri"
	world.add_child(marker)
	var hud := CanvasLayer.new()
	hud.name = "HUD"
	world.add_child(hud)
	var preview: Node = load("res://scripts/debug/angelastri_map_preview.gd").new()
	world.add_child(preview)
	await physics_frame
	await preview.warmup_presentation()
	while preview.busy: await process_frame
	assert(preview.warmed)
	var presentation_id: int = preview.presentation.get_instance_id()
	var actor_id: int = preview.presentation.model.get_instance_id()
	await preview.spawn_preview(false, false, false)
	assert(preview.presentation.get_instance_id() == presentation_id, "First spawn destroyed prewarmed presentation")
	assert(preview.presentation.model.get_instance_id() == actor_id)
	var encounter: Node = load("res://scripts/tests/angelastri_encounter_fixture.gd").new()
	world.add_child(encounter)
	encounter.scene = world
	encounter.player = player
	encounter.player_camera = player.get_node("Head/Camera3D")
	encounter.preview = preview
	encounter.event.stage = "performance"
	encounter.camera = Camera3D.new()
	world.add_child(encounter.camera)
	encounter._finish_return()
	assert(encounter.event.stage == "waiting")
	var start: Vector3 = preview.presentation.model.global_position
	encounter.patrol_wait = 0.01
	encounter.patrol_looking = true
	encounter.rng.seed = 42
	var saw_walking := false
	for i in range(120):
		encounter._patrol(1.0 / 30.0)
		saw_walking = saw_walking or preview.presentation.animation.assigned_animation == &"mie/walking"
	assert(preview.presentation.model.global_position.distance_to(start) > 0.2, "Patrol did not translate actor")
	assert(saw_walking, "Patrol walking animation missing")
	var actor: Node3D = preview.presentation.model
	var facing: Vector3 = actor.global_basis.z.normalized()
	player.global_position = actor.global_position + facing * 6.0 + Vector3.UP * 0.9
	encounter.player_camera.look_at(actor.global_position + Vector3.UP * 1.6)
	await physics_frame
	assert(encounter._sees_player(), "Facing player not detected at six metres")
	actor.rotate_y(PI)
	assert(not encounter._sees_player(), "Second encounter triggered behind actor")
	actor.rotate_y(-PI)
	var position: Vector3 = preview.presentation.model.global_position
	await preview.spawn_preview(true, false, true)
	assert(preview.presentation.get_instance_id() == presentation_id, "Second dialogue recreated presentation")
	assert(preview.presentation.model.get_instance_id() == actor_id, "Second dialogue recreated model")
	assert(preview.presentation.model.global_position.distance_to(position) < 0.02, "Dialogue teleported actor")
	await encounter._test_patrol()
	assert(encounter.event.stage == "waiting" and preview.presentation.visible, "F7 test did not set up patrol")
	player.set_physics_process(true)
	encounter.laugh = AudioStreamPlayer3D.new()
	world.add_child(encounter.laugh)
	await encounter._start_cinematic(true)
	assert(preview.presentation.get_instance_id() == presentation_id, "Cinematic startup reloaded model")
	assert(encounter.event.stage == "dialogue" and encounter.cinematic, "Second encounter did not start")
	preview.presentation.voice.stop()
	preview.presentation.advance_presentation()
	assert(preview.presentation.animation.get_animation(&"mie/idle_new").loop_mode == Animation.LOOP_NONE)
	for i in range(150):
		preview.presentation.animation.advance(0.1)
		if preview.presentation.presentation_stage in ["finish_idle", "prepare_combat"]:
			preview.presentation._main_tail(0.1)
	assert(preview.presentation.presentation_stage == "combat_ready", "Natural dialogue tail never completed")
	encounter._begin_return()
	encounter._director(1.5)
	assert(encounter.event.stage == "combat" and is_instance_valid(encounter.combat), "Dialogue did not hand off to combat")
	assert(player.is_physics_processing(), "Combat handoff failed to return player controls")
	encounter._abort()
	await process_frame
	await encounter._test_combat()
	assert(encounter.event.stage == "combat" and is_instance_valid(encounter.combat), "F11 shortcut did not start combat")
	print("ANGELASTRI_REUSE_PATROL_TEST passed: both encounters reuse same model, patrol moves with walking")
	world.queue_free()
	await process_frame
	await process_frame
	quit()
