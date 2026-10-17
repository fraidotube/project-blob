extends SceneTree
var failures := 0
var world: Node3D
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func frames(count: int) -> void:
	for index in count: await physics_frame
func capture(name: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/" + name + ".png")
func sphere(at: Vector3, heading: Vector3) -> Node3D:
	var projectile = load("res://scripts/enemies/broccolo_lab_energy.gd").new()
	projectile.target = world.player
	projectile.burn_status = world.burn_status
	projectile.visual_scene = world.energy_visual_scene
	projectile.position = at
	projectile.direction = heading
	world.add_child(projectile)
	return projectile
func run() -> void:
	if DisplayServer.get_name() != "headless": root.size = Vector2i(1280, 720)
	world = load("res://scenes/levels/broccolo_combat_test.tscn").instantiate()
	world.auto_combat = false
	world.start_in_fps = false
	root.add_child(world)
	current_scene = world
	while not world.ready_for_test: await process_frame
	world.set_process(false)
	world.boss.set_physics_process(false)
	world.player.set_physics_process(false)
	world.player.global_position = Vector3(0, 0.9, 4)
	var burn = world.burn_status
	var shot = sphere(Vector3(0, 0.9, 1.5), Vector3.BACK)
	shot.set_paused(true)
	check(shot.energy_visual != null and shot.energy_visual.aura.visible, "Nuova sfera senza aura")
	world.study_camera.position = Vector3(0.55, 1.18, 2.2)
	world.study_camera.look_at(shot.global_position)
	await capture("broccolo_energy_sphere")
	shot.set_paused(false)
	var before: int = world.player.health
	var deadline := Time.get_ticks_msec() + 4000
	while burn.remaining <= 0 and Time.get_ticks_msec() < deadline: await physics_frame
	check(burn.remaining > 0 and world.player.health == before - 7, "Sweep diretto non incendia o duplica danno iniziale")
	check(burn.flames.visible, "Fiamme corpo assenti")
	world.set_overview(false)
	world.player.set_physics_process(false)
	await frames(30)
	check(burn.overlay.visible, "Feedback FPS assente")
	check(not burn.flames.visible, "Guscio del corpo copre la visuale FPS")
	await capture("broccolo_player_burning_fps")
	burn.set_paused(true)
	var remaining: float = burn.remaining
	var health: int = world.player.health
	await frames(20)
	check(is_equal_approx(burn.remaining, remaining) and world.player.health == health, "Bruciatura continua durante pausa")
	burn.set_paused(false)
	await frames(190)
	check(burn.remaining == 0 and not burn.overlay.visible and not burn.flames.visible, "Bruciatura non termina")
	check(world.player.health == before - 7 - 12, "Danno periodico non e4tick da3")
	# Rinnovare non azzera il tick gia in corso e non crea una seconda condizione.
	burn.ignite()
	await frames(30)
	var tick_left: float = burn.tick_left
	burn.ignite()
	check(burn.remaining <= 3.0 and is_equal_approx(burn.tick_left, tick_left), "Incendi si sommano o rinviano continuamente il tick")
	await frames(20)
	check(world.player.health == before - 7 - 15, "Refresh raddoppia o evita danno")
	burn.stop()
	# Parete vera del laboratorio: nessun danno e nessuna bruciatura attraverso.
	world.player.global_position = Vector3(2.5, 0.9, 0)
	before = world.player.health
	shot = sphere(Vector3(1.4, 0.9, 0), Vector3.RIGHT)
	await frames(35)
	check(world.player.health == before and burn.remaining == 0, "Sfera incendia attraverso parete")
	# Esplosione vicina senza impatto diretto: danno area esistente, nessun incendio.
	world.player.global_position = Vector3(0, 0.9, 4)
	before = world.player.health
	shot = sphere(Vector3(0, 0.9, 3.2), Vector3.LEFT)
	shot.detonate()
	check(world.player.health == before - 7 and burn.remaining == 0, "Esplosione vicina trattata come impatto diretto")
	# Stop laboratorio ripulisce la condizione e i controlli del player restano normali.
	burn.ignite()
	world.stop_combat()
	check(burn.remaining == 0 and not burn.overlay.visible, "Stop AI lascia bruciatura attiva")
	var settings = load("res://scenes/effects/broccolo_burn_status.tscn").instantiate()
	settings.duration_seconds = 1.0
	settings.tick_damage = 2
	settings.tick_seconds = 0.25
	var packed_settings := PackedScene.new()
	check(packed_settings.pack(settings) == OK, "Bruciatura non serializzabile")
	settings.free()
	var custom = packed_settings.instantiate()
	custom.target = world.player
	world.player.add_child(custom)
	custom.position.y = -0.9
	before = world.player.health
	custom.ignite()
	await frames(65)
	check(custom.remaining == 0 and world.player.health == before - 8, "Parametri Inspector bruciatura ignorati")
	custom.queue_free()
	# Morte: il componente non mantiene tick o fiamme sulla schermata morte.
	world.player.health = 1
	burn.ignite()
	await frames(50)
	check(world.player.is_dead and burn.remaining == 0 and not burn.overlay.visible, "Morte non spegne incendio")
	print("BROCCOLO_ENERGY_BURN failures=", failures)
	await frames(70)
	world.queue_free()
	await frames(3)
	quit(0 if failures == 0 else 1)
