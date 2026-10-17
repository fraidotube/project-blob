extends SceneTree
var failures := 0
func _initialize() -> void:
	run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func frames(count: int) -> void:
	for index in count: await physics_frame
func run() -> void:
	change_scene_to_file("res://scenes/maps/map_test.tscn")
	await process_frame
	await process_frame
	var encounter = current_scene.get_node("BroccoloEncounter")
	var world = encounter.get_node("BroccoloMinionSpawner")
	while not world.ready_for_test: await process_frame
	var player = current_scene.get_node("Player")
	current_scene.get_node("AngelastriEncounter").set_process(false)
	player.set_physics_process(false)
	player.get_node("InteractionSystem").set_process(false)
	check(world.gates.size() == 3 and world.pool_ready, "Pool/porte non pronti")
	check(world.graph.get_point_count() > 100, "Grafo mappa vuoto")
	var connections := 0
	for id in world.graph.get_point_ids(): connections += world.graph.get_point_connections(id).size()
	print("BROCCOLO_MAP_GRAPH connections=", connections)
	await world.configure(encounter, encounter.spawn.global_position)
	check(world.started and world.combat and world.blocks_saving(), "Handoff combattimento non avviato")
	check(not encounter.presentation.visible and world.boss.visible, "Corpo presentazione non sostituito")
	world.spawning = false
	world.initial_wave = true
	world.max_copies = 0
	world.boss.autonomous = false
	world.boss.global_position = Vector3(10, 0.1, -8)
	var actor = world.reserve[0]
	for door in world.gates:
		for side in [-1.0, 1.0]:
			door.apply_persistent_state({})
			var at: Vector3 = door.closed_center + door.opening_normal * side * 0.65
			at.y = door.global_position.y + 0.02
			actor.reset_for_spawn(at)
			actor.autonomous = false
			player.global_position = door.closed_center - door.opening_normal * side * 1.8
			player.global_position.y = at.y + 0.9
			await frames(8)
			check(world.try_gate(actor), "Salto porta non iniziato " + String(door.name))
			check(actor.state == "gate" and actor.velocity.y > 0, "Salto non animato/fisico")
			await frames(100)
			check(door.is_open and absf(door.rotation.y) > 1.3, "Porta non aperta dal salto " + String(door.name))
			check(not door.retreating, "Apertura nemico prende controllo del player")
			var motion := PhysicsTestMotionParameters3D.new()
			motion.from = actor.global_transform
			motion.from.origin = at
			motion.motion = -door.opening_normal * side * 1.3
			check(not PhysicsServer3D.body_test_motion(actor.get_rid(), motion), "Capsula non passa porta aperta " + String(door.name))
			world.retire_actor(actor)
	for door in current_scene.get_node("WarehouseDoors").doors:
		check(door.enemy_jump_open_enabled == world.gates.has(door), "Permessi nemici estesi ad altra porta")
	var gate = world.gates[0]
	gate.apply_persistent_state({})
	# Corridoio reale: la parete esterna e a circa1,3m dal battente.
	var origin: Vector3 = gate.closed_center - gate.opening_normal * 0.9
	origin.y = gate.global_position.y + 0.02
	actor.reset_for_spawn(origin)
	actor.autonomous = true
	player.global_position = gate.closed_center + gate.opening_normal * 1.8
	player.global_position.y = origin.y + 0.9
	var from_id: int = world.graph.get_closest_point(origin)
	var to_id: int = world.graph.get_closest_point(player.global_position - Vector3.UP * 0.75)
	print("BROCCOLO_MAP_ROUTE from=", world.graph.get_point_position(from_id), " to=", world.graph.get_point_position(to_id), " complete_points=", world.graph.get_point_path(from_id, to_id).size(), " partial_points=", world.graph.get_point_path(from_id, to_id, true).size())
	check(world.graph.get_point_path(from_id, to_id).size() > 1, "Portale porta non collega i due pavimenti")
	check(world.route_direction(origin, player.global_position).length() > 0.5, "Percorso attraverso porta chiusa assente")
	await frames(300)
	check(gate.is_open, "Inseguimento automatico non apre porta")
	check((actor.global_position - gate.closed_center).dot(gate.opening_normal) > 0.1, "Inseguitore non attraversa la porta")
	world.retire_actor(actor)
	world.max_copies = 3
	world.boss.reset_for_spawn(Vector3(0.57, 0.02, -6.2))
	var copy = world.emit_copy()
	check(copy != null, "Emissione mappa fallita")
	if copy != null:
		var identity: int = copy.get_instance_id()
		world.retire_actor(copy)
		var recycled = world.emit_copy()
		check(recycled != null and recycled.get_instance_id() == identity and recycled.health == 2, "Riutilizzo/reset copia fallito")
	world.stop_combat()
	world.defeated = true
	check(world.get_persistent_state().defeated and not world.blocks_saving(), "Vittoria non persistibile")
	await world.apply_persistent_state({"defeated": true})
	check(encounter.second_presentation_started and not world.boss.visible, "Restore vittoria ripete lo scontro")
	await world.apply_persistent_state({})
	check(not world.defeated and not encounter.second_presentation_started, "Restore precedente non riabilita incontro")
	print("BROCCOLO_MAP_COMBAT failures=", failures, " points=", world.graph.get_point_count(), " spawn_ms=", world.spawn_times_ms)
	await frames(100)
	quit(0 if failures == 0 else 1)
