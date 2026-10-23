extends SceneTree

var failures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func run() -> void:
	change_scene_to_file("res://scenes/maps/map_test.tscn")
	await process_frame
	await process_frame
	var combat = current_scene.get_node("BroccoloEncounter/BroccoloMinionSpawner")
	while not combat.ready_for_test: await process_frame
	var player = current_scene.get_node("Player")
	player.set_physics_process(false)
	player.get_node("InteractionSystem").set_process(false)
	player.global_position = Vector3(100,5,100)
	current_scene.get_node("AngelastriEncounter").set_process(false)
	var inventory = root.get_node("InventoryManager")
	var saves = root.get_node("SaveManager")
	inventory.clear()
	var integration = current_scene.get_node("WarehouseDoors")
	check(integration.doors.size() == 14 and integration._get_configuration_warnings().is_empty(), "Configurazioni porte mancanti/non valide")
	var secret = current_scene.get_node("WarehouseSecretDoor")
	var rear = current_scene.get_node("RearRightDoor")
	var assistance = current_scene.get_node("AssistanceMainDoor")
	check(secret.opening_normal.is_equal_approx(Vector3.BACK) and secret.required_key.is_empty(), "Segreta non libera/verso avvicinamento errato")
	check(rear.required_key == &"rear_key" and not rear.unlocked, "Retro non chiuso con chiave dedicata")
	check(assistance.required_key == &"assistance_key", "ID storico assistenza cambiato")
	var config = integration.get_node("PortaRetroDX")
	check(config.panel_parts.size() == 6 and rear.leaf_width > 1.0 and rear.panel_box.shape.size.y > 2.0, "Collider retro non copre anta intera")
	var poses := {}
	for mesh in rear.outlined_meshes: poses[mesh] = mesh.global_transform
	rear.interact(player)
	check(not rear.is_open, "Retro aperto senza chiave")
	inventory.add_item(&"assistance_key")
	rear.interact(player)
	check(not rear.is_open, "Chiave assistenza apre retro")
	inventory.remove_item(&"assistance_key")
	inventory.add_item(&"rear_key")
	rear.interact(player)
	secret.interact(player)
	await create_timer(2.2).timeout
	check(secret.is_open and rear.is_open and not rear.blocks_saving(), "Nuove porte non aprono")
	check(rear.outlined_meshes.size() == 12, "Vetro/maniglie retro non inclusi")
	rear.apply_persistent_state({})
	secret.apply_persistent_state({})
	for mesh in poses: check(mesh.global_transform.is_equal_approx(poses[mesh]), "Posa chiusa pezzo retro alterata")
	inventory.remove_item(&"rear_key")
	var pickup_id: StringName = combat.victory_pickup_id
	check(not saves.participants.has(pickup_id), "Chiave compare prima della vittoria")
	combat.boss.reset_for_spawn(Vector3(2.5,0.02,-3.7))
	combat.boss.autonomous = false
	combat.boss.state = "show"
	combat.boss.recovery = 0
	combat.boss.health = 1
	combat.boss.take_damage(1)
	check(combat.defeated and combat.blocks_saving(), "Morte non segnala drop in preparazione")
	await process_frame
	await process_frame
	var key: Node3D = saves.participants.get(pickup_id)
	check(is_instance_valid(key) and key.item_id == &"assistance_key", "Broccolo non lascia chiave assistenza")
	if not is_instance_valid(key): quit(1); return
	check(not inventory.has_item(&"assistance_key"), "Chiave assegnata senza raccolta")
	check(key.global_position.distance_to(Vector3(2.5,0.03,-3.7)) < 0.15, "Drop lontano dal punto morte/pavimento")
	for mesh: MeshInstance3D in key.get_node("KeyWithTag").find_children("*","MeshInstance3D",true,false):
		var original := mesh.mesh.surface_get_material(0) as BaseMaterial3D
		var active := mesh.get_active_material(0) as BaseMaterial3D
		if original.resource_name == "KeyTag":
			check(active != original and active.albedo_color == key.key_tag_color and original.albedo_color == Color.WHITE, "Targhetta non blu privata/originale modificato")
		else: check(active == original, "Metallo/anello ricolorati")
	saves.capture_world()
	var snapshot: Dictionary = combat.get_persistent_state()
	var at := key.global_transform
	await combat.apply_persistent_state(snapshot)
	await process_frame
	key = saves.participants.get(pickup_id)
	check(is_instance_valid(key) and key.global_transform.is_equal_approx(at), "Chiave non raccolta persa/spostata al restore")
	combat._spawn_victory_pickup()
	check(saves.participants.get(pickup_id) == key, "Drop duplicato")
	key.interact(player)
	await process_frame
	check(inventory.has_item(&"assistance_key") and bool(saves.object_state(pickup_id).get("collected",false)), "Raccolta non persistente")
	assistance.interact(player)
	check(assistance.is_open and assistance.unlocked, "Chiave Broccolo non apre Assistenza00")
	await combat.apply_persistent_state(snapshot)
	await process_frame
	check(not saves.participants.has(pickup_id), "Chiave raccolta ricompare al restore")
	inventory.clear()
	saves.world_states.erase(String(pickup_id))
	await combat.apply_persistent_state({"defeated":true})
	await process_frame
	check(saves.participants.has(pickup_id), "Vecchio checkpoint boss sconfitto senza chiave non recuperabile")
	await combat.apply_persistent_state({})
	await process_frame
	check(not saves.participants.has(pickup_id), "Checkpoint precedente lascia drop futuro")
	print("NEXT_ZONE_UNLOCK_TEST failures=",failures)
	quit(failures)
