extends SceneTree

var failures := 0
var player: CharacterBody3D

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func crossing(door: Node3D, side: float) -> bool:
	var parameters := PhysicsTestMotionParameters3D.new()
	parameters.from = player.global_transform
	parameters.from.origin = door.closed_center + door.opening_normal * side * 0.5
	parameters.from.origin.y = maxf(0.0, door.global_position.y) + 0.91
	parameters.motion = door.opening_normal * side * -1.0
	parameters.recovery_as_collision = true
	var result := PhysicsTestMotionResult3D.new()
	var blocked := PhysicsServer3D.body_test_motion(player.get_rid(), parameters, result)
	if blocked:
		for index in result.get_collision_count():
			var collider = result.get_collider(index)
			print("WAREHOUSE_PASSAGE_HIT ", door.name, " side=", side, " collider=", collider.get_path() if collider is Node else collider, " point=", result.get_collision_point(index))
	return blocked

func run() -> void:
	change_scene_to_file("res://scenes/maps/map_test.tscn")
	await process_frame
	await process_frame
	await physics_frame
	var integration = current_scene.get_node("WarehouseDoors")
	var inventory = root.get_node("InventoryManager")
	var save_manager = root.get_node("SaveManager")
	player = current_scene.get_node("Player")
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	player.global_position = Vector3(100, 5, 100)
	current_scene.get_node("AngelastriEncounter").set_process(false)
	# Exercise the real InteractionSystem and E on the first free door.
	var interaction = player.get_node("InteractionSystem")
	var interact_ray: RayCast3D = player.get_node("Head/Camera3D/InteractRay")
	current_scene.get_node("HUD/Interface").show()
	var first = integration.doors[0]
	interact_ray.global_position = first.closed_center - first.opening_normal * 0.8
	interact_ray.look_at(first.closed_center)
	await physics_frame
	await process_frame
	interaction._update_focus()
	check(interaction.focused_interactable == first and interaction.prompt.visible, "Prompt reale non trova la porta")
	Input.action_press("interact")
	await process_frame
	await process_frame
	Input.action_release("interact")
	check(first.is_open, "E reale non apre la porta")
	first.apply_persistent_state({})
	interaction.set_process(false)
	await physics_frame
	await process_frame
	# Returning the ray prevents it outlining unrelated objects during tests.
	interact_ray.position = Vector3.ZERO
	interact_ray.rotation = Vector3.ZERO
	check(integration.doors.size() == 12, "Dodici porte non create")
	check(integration.get_setups().size() == 12, "Configurazioni Inspector mancanti")
	var legacy_directions := {
		"AnteroomDoor":Vector3.RIGHT, "BathroomRightDoor":Vector3.BACK,
		"BathroomLeftDoor":Vector3.FORWARD, "SwitchRoomDoor":Vector3.RIGHT,
		"AssistanceInternalDoor":Vector3.RIGHT, "AssistanceMainDoor":Vector3.FORWARD,
		"ProductionDoor":Vector3.LEFT, "WarehouseGrid013":Vector3.BACK,
		"WarehouseGrid014":Vector3.BACK, "WarehouseGrid015":Vector3.BACK,
		"WarehouseStairs038":Vector3.RIGHT, "CEDDoor":Vector3.RIGHT
	}
	for door in integration.doors:
		check(door.persistent_id == StringName("main.door.warehouse."+String(door.name)),"ID storico cambiato durante migrazione")
		check(door.opening_normal.is_equal_approx(legacy_directions[String(door.name)]),"Verso storico cambiato durante migrazione")
		check(save_manager.participants.get(door.persistent_id) == door, "Porta non registrata " + String(door.name))
		var ray := PhysicsRayQueryParameters3D.create(door.closed_center + door.opening_normal * 0.4, door.closed_center - door.opening_normal * 0.2, 2)
		var hit: Dictionary = current_scene.get_world_3d().direct_space_state.intersect_ray(ray)
		check(not hit.is_empty() and hit.collider == door.door_body, "Collider interazione mancante " + String(door.name))
		door.set_interaction_focus(true)
		check(not door.outlined_meshes.is_empty() and door.outlined_meshes[0].material_overlay == door.outline_material, "Outline mancante " + String(door.name))
		door.set_interaction_focus(false)
		check(crossing(door, 1.0), "Porta chiusa attraversabile " + String(door.name))
		if not door.required_key.is_empty():
			door.interact(player)
			check(not door.is_open, "Serratura aperta senza chiave")
			var wrong: StringName = &"production_key" if door.required_key != &"production_key" else &"switch_key"
			inventory.add_item(wrong)
			door.interact(player)
			check(not door.is_open, "Serratura aperta con chiave sbagliata")
			inventory.remove_item(wrong)
			inventory.add_item(door.required_key)
		if door.fingerprint_locked:
			integration.scanner.interact(player)
			check(not door.is_open and door.fingerprint_remaining == 0.0, "Impronta errata accettata")
			check(integration.scanner.led.material_override.albedo_color == Color("ff2323"), "LED rosso mancante")
			integration.scanner.scan(true)
			check(not door.is_open and door.fingerprint_remaining > 9.0, "Lettore deve sbloccare senza aprire")
			await create_timer(10.1).timeout
			check(door.fingerprint_remaining == 0.0, "Fingerprint non scade a 10 secondi")
			check(integration.scanner.led.material_override.albedo_color == Color("168bff"), "LED blu non ripristinato")
			inventory.add_item(&"ced_fingerprint")
			integration.scanner.interact(player)
			check(integration.scanner.led.material_override.albedo_color == Color("25ed65"), "LED verde mancante")
		door.interact(player)
		check(door.is_open, "Interazione non apre " + String(door.name))
		await create_timer(2.1).timeout
		check(not door.blocks_saving(), "Porta non termina movimento " + String(door.name))
		for side in [1.0, -1.0]:
			check(not crossing(door, side), "Vano aperto bloccato " + String(door.name) + " side=" + str(side))
		var snapshot: Dictionary = door.get_persistent_state()
		door.apply_persistent_state({})
		check(not door.is_open, "Restore vecchio checkpoint non chiude")
		door.apply_persistent_state(snapshot)
		check(door.is_open and not door.door_audio.playing, "Restore aperto non silenzioso")
		door.close_door()
		await create_timer(2.1).timeout
		check(not door.is_open and not door.blocks_saving(), "Chiusura fallita")
	print("WAREHOUSE_DOORS_TEST failures=", failures)
	quit(failures)
