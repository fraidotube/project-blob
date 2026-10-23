extends SceneTree

var failures := 0
var barrier: Node

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void: run.call_deferred()

func run() -> void:
	if "--map" in OS.get_cmdline_user_args():
		await map_test()
	else:
		await fixture_test()
		if DisplayServer.get_name() != "headless": await gpu_hit_test()
	print("LOADING_READINESS_TEST failures=", failures)
	quit(failures)

func fixture_test() -> void:
	var world := Node3D.new()
	root.add_child(world)
	current_scene = world
	var sound := AudioStreamPlayer.new()
	world.add_child(sound)
	var area := Area3D.new()
	area.set_script(load("res://scripts/player/indoor.gd"))
	area.exterior_ambience = sound
	var zone_shape := CollisionShape3D.new()
	zone_shape.shape = BoxShape3D.new()
	zone_shape.shape.size = Vector3(6, 4, 6)
	area.add_child(zone_shape)
	world.add_child(area)
	var player := CharacterBody3D.new()
	player.add_to_group("player")
	var capsule := CollisionShape3D.new()
	capsule.name = "CollisionShape3D"
	capsule.shape = CapsuleShape3D.new()
	player.add_child(capsule)
	world.add_child(player)
	await physics_frame
	await physics_frame
	paused = true
	area.synchronize_player(player)
	check(sound.volume_db == area.inside_volume_db, "Audio checkpoint interno non pronto in pausa")
	player.position.x = 10
	area.synchronize_player(player)
	check(sound.volume_db == area.outside_volume_db, "Audio checkpoint esterno errato")
	paused = false
	var manager = load("res://scripts/effects/impact_manager.gd").new()
	world.add_child(manager)
	var texture_count: int = manager._textures.size()
	var collider := Node.new()
	collider.set_meta("surface_type", "metal")
	world.add_child(collider)
	manager.spawn_impact(collider, Vector3.ZERO, Vector3.UP)
	check(texture_count > 20 and manager._textures.size() == texture_count, "Primo impatto carica texture nuove")
	var feedback = load("res://scripts/effects/melee_feedback.gd")
	feedback.prepare_resources()
	var first: CPUParticles3D = feedback.create_blood_spray()
	var second: CPUParticles3D = feedback.create_blood_spray()
	check(first.mesh == second.mesh and first.color_ramp == second.color_ramp, "Sangue ricostruisce mesh/materiale a ogni colpo")
	first.free()
	second.free()
	await manager.prepare_rendering()
	await barrier_test(world)
	world.queue_free()
	await process_frame

func barrier_test(world: Node3D) -> void:
	var preparation = load("res://scripts/systems/map_loading_preparation.gd").new()
	world.add_child(preparation)
	var bus := AudioServer.get_bus_index("Ambience")
	check(is_equal_approx(AudioServer.get_bus_volume_db(bus), -8.0), "Mix ambientale non ridotto")
	var transition = root.get_node("SceneTransition")
	var original_mute := AudioServer.is_bus_mute(0)
	var packed: PackedScene = await transition.load_scene("res://scenes/levels/inventory_save_test.tscn", "TEST")
	check(packed != null and AudioServer.is_bus_mute(0), "Audio udibile sotto caricamento")
	await transition.wait_scene_initialization()
	await transition.prepare_scene_for_reveal()
	check(preparation.prepared and transition.visible, "Preparazione non attesa sotto overlay")
	await transition.reveal(0.01)
	check(AudioServer.is_bus_mute(0) == original_mute, "Mute originale non ripristinato")
	# Nondefault tuning must survive the scene roundtrip.
	preparation.ambience_bus_volume_db = -12.0
	var packed_config := PackedScene.new()
	check(packed_config.pack(preparation) == OK, "Preparazione non serializzabile")
	var copy = packed_config.instantiate()
	check(is_equal_approx(copy.ambience_bus_volume_db, -12.0), "Tuning mix non serializzato")
	copy.free()

func map_test() -> void:
	var saves = root.get_node("SaveManager")
	var scene_path := "res://scenes/maps/map_test.tscn"
	saves.start_new_game(scene_path)
	check(await saves._load_scene(scene_path, {}), "Nuova partita mappa fallita")
	var preparation = current_scene.get_node("MapLoadingPreparation")
	check(preparation.prepared and preparation.broccolo_combat.ready_for_test, "Mappa rivelata prima di pool/grafo")
	check(not root.get_node("SceneTransition").visible and not paused, "Caricamento non terminato")
	var player = current_scene.get_node("Player")
	player.set_physics_process(false)
	var weapon = player.weapon
	var state: Dictionary = player.get_save_state()
	state.health = 73
	state.transform.origin = Vector3(2.5, 0.9, -3.7)
	state.weapon.owns_pistol = true
	state.weapon.equipped = weapon.WEAPON_PISTOL
	state.weapon.pistol_magazine = 3
	state.weapon.pistol_reserve = 7
	saves.capture_world()
	# Make both bosses completed: this checkpoint must not replay their intros.
	var world_states: Dictionary = saves.world_states.duplicate(true)
	world_states["main.angelastri.encounter"] = {"stage":"defeated", "armed":true, "blackout_count":3, "actor_pose":Transform3D(Basis.IDENTITY, Vector3(-8, 0.4, 16))}
	world_states["main.broccolo.combat"] = {"defeated":true}
	var data := {"scene":scene_path, "player":state, "inventory":{}, "world":world_states}
	var began := Time.get_ticks_msec()
	check(await saves._load_scene(scene_path, data), "Ripristino mappa fallito")
	preparation = current_scene.get_node("MapLoadingPreparation")
	player = current_scene.get_node("Player")
	weapon = player.weapon
	check(preparation.prepared and preparation.broccolo_combat.defeated, "Reveal prima del restore boss")
	check(player.health == 73 and weapon.magazine_ammo == 3 and weapon.reserve_ammo == 7, "Checkpoint sovrascritto da dotazione iniziale")
	check(player.is_physics_processing() and weapon.visible and weapon.pistol_model.visible, "Player/arma ancora bloccati o nascosti al reveal")
	check(current_scene.get_node("ExteriorAmbience").volume_db <= -79, "Audio esterno udibile al checkpoint interno")
	check(preparation.angelastri_encounter.event.stage == "defeated" and not preparation.angelastri_encounter.preview.busy, "Angelastri ancora in preparazione al reveal")
	var graph_size: int = preparation.broccolo_combat.graph.get_point_count()
	await create_timer(0.3).timeout
	check(preparation.broccolo_combat.graph.get_point_count() == graph_size, "Grafo ancora in costruzione dopo reveal")
	print("LOADING_MAP_READY elapsed_ms=",Time.get_ticks_msec()-began," points=",graph_size)

func gpu_hit_test() -> void:
	var world = load("res://scenes/levels/broccolo_combat_test.tscn").instantiate()
	world.auto_combat = false
	world.start_in_fps = false
	root.add_child(world)
	current_scene = world
	while not world.ready_for_test: await process_frame
	check(world.pool_ready and world.reserve.size() == 3, "Pool GPU non pronto")
	var times := []
	for actor in world.reserve:
		actor.reset_for_spawn(Vector3(0, 0.02, 1))
		actor.autonomous = false
		actor.set_physics_process(false)
		var began := Time.get_ticks_usec()
		actor.take_bullet_hit(1, actor.global_position + Vector3.UP * 0.15)
		times.append((Time.get_ticks_usec()-began)/1000.0)
		check(actor.health == 1 and actor.state == "hurt", "Preparazione altera danno/reazione minion")
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		world.retire_actor(actor)
	print("GPU_FIRST_MINION_HIT_CPU_MS ", times)
	world.queue_free()
	await process_frame
