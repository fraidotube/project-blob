extends SceneTree
var failures := 0
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
func run() -> void:
	if DisplayServer.get_name() != "headless": root.size = Vector2i(1280, 720)
	var world = load("res://scenes/levels/broccolo_combat_test.tscn").instantiate()
	world.auto_combat = false
	world.start_in_fps = false
	root.add_child(world)
	current_scene = world
	while not world.ready_for_test: await process_frame
	world.set_process(false)
	var boss = world.boss
	var fx = boss.power_fx
	check(fx != null and world.reserve[0].power_fx != null, "Effetti pool mancanti")
	var map_component = load("res://scenes/enemies/broccolo_map_combat.tscn").instantiate()
	check(map_component.get_node("MainBroccolo").preview_vfx_scene == null, "Prova gia applicata in mappa")
	map_component.free()
	world.study_camera.position = Vector3(1.4, 1.05, 2.2)
	world.study_camera.look_at(Vector3(0, 0.65, 0))
	await frames(40)
	check(fx.visible and fx.sparks.emitting, "Trasformazione senza particelle")
	await capture("broccolo_vfx_transform")
	await frames(75)
	check(boss.state == "chase" and fx.remaining > 0, "Aura non continua dopo riduzione")
	world.study_camera.position = Vector3(0.9, 0.55, 1.1)
	world.study_camera.look_at(Vector3(0, 0.2, 0))
	await capture("broccolo_vfx_power_tail")
	var copy = world.emit_copy()
	check(copy != null and copy.state == "emerge", "Nascita non separata dalla corsa")
	check(copy.global_position.is_equal_approx(boss.global_position), "Copia teletrasportata lontano dal corpo")
	check(copy.visual.scale.x < copy.miniature_scale * 0.2, "Copia gia interamente visibile al rilascio")
	check(fx.sparks.emitting and copy.power_fx.sparks.emitting, "Particelle mancanti alla sorgente/copia")
	check(fx.shell.visible and fx.transforming, "Prima copia tronca l'aura dopo riduzione")
	check(copy.power_fx.shell.visible and copy.power_fx.flash_remaining > 0, "Lampo arancione nascita assente")
	check(copy.power_fx.shell_material.get_shader_parameter("tint") == copy.copy_aura_color, "Lampo nascita non arancione")
	check(copy.preview_vfx_scene == boss.preview_vfx_scene, "Profili effetti duplicati")
	var origin: Vector3 = copy.global_position
	await frames(12)
	check(copy.state == "emerge" and copy.global_position.distance_to(origin) < 0.2, "Copia corre prima di emergere")
	await capture("broccolo_vfx_birth")
	await frames(22)
	check(copy.state == "scatter", "Corsa non parte dopo emersione")
	check(not copy.power_fx.shell.visible and fx.transforming, "Lampo dura troppo o interrompe trasformazione")
	check(copy.visual.scale.is_equal_approx(Vector3.ONE * copy.miniature_scale), "Scala finale copia errata")
	copy.preview_clip(&"mie/idle")
	copy.power_fx.stop()
	fx.stop()
	world.study_camera.position = copy.global_position + Vector3(0.5, 0.3, 0.65)
	world.study_camera.look_at(copy.global_position + Vector3.UP * 0.17)
	await frames(3)
	check(float(copy.aura.get_shader_parameter("active")) >= 0.35, "Alone arancione ancora troppo tenue")
	await capture("broccolo_vfx_orange")
	fx.ignite(0.34, 0.8, fx.power_color)
	fx.set_paused(true)
	var remaining: float = fx.remaining
	await frames(6)
	check(is_equal_approx(fx.remaining, remaining) and fx.sparks.speed_scale == 0, "Pausa effetti non rispettata")
	fx.set_paused(false)
	await frames(60)
	check(not fx.visible, "Effetto non si spegne")
	world.retire_actor(copy)
	# Anche durante l'emersione un nuovo ostacolo deve fermare la capsula.
	copy.reset_for_spawn(Vector3(1.6, 0.02, 0))
	copy.autonomous = false
	copy.power_fx.emergence_seconds = 0.7
	copy.begin_emergence(Vector3.RIGHT, 1.0)
	await frames(30)
	check(copy.global_position.x < 1.8 and copy.state == "emerge", "Emersione attraversa muro o ignora durata Inspector")
	world.retire_actor(copy)
	copy = world.emit_copy()
	copy.take_damage(1)
	check(copy.health == 1 and copy.state == "hurt" and not copy.vulnerable(), "Hit durante nascita altera regole copia")
	check(copy.visual.scale.is_equal_approx(Vector3.ONE * copy.miniature_scale), "Hit lascia copia piccolissima")
	world.retire_actor(copy)
	check(not copy.power_fx.visible and copy.state == "pooled", "Pool lascia particelle attive")
	var legacy = world.actor_scene.instantiate()
	legacy.principal = false
	legacy.autonomous = false
	legacy.position = Vector3(6, 0.02, 0)
	world.add_child(legacy)
	await frames(2)
	check(legacy.power_fx == null and is_equal_approx(float(legacy.aura.get_shader_parameter("active")), 0.08), "Versione senza profilo mappa alterata")
	legacy.queue_free()
	var settings = boss.preview_vfx_scene.instantiate()
	settings.get_node("Sparks").initial_velocity_min = 1.1
	var packed_settings := PackedScene.new()
	check(packed_settings.pack(settings) == OK, "Parametri particelle non serializzabili")
	settings.free()
	var custom = packed_settings.instantiate()
	root.add_child(custom)
	custom.ignite(0.5, 0.2, Color.ORANGE)
	check(is_equal_approx(custom.sparks.initial_velocity_min, 0.55), "Velocita nativa Inspector sovrascritta dal profilo")
	custom.queue_free()
	print("BROCCOLO_VFX_LAB failures=", failures, " spawn_ms=", world.spawn_times_ms)
	world.queue_free()
	await frames(3)
	quit(0 if failures == 0 else 1)
