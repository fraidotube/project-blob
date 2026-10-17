extends SceneTree

const FIXTURE := "res://.godot/player_inspector_spawn.tscn"
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		push_error(message)

func _run() -> void:
	var saves := root.get_node("SaveManager")
	var inventory := root.get_node("InventoryManager")
	saves.save_path = "res://.godot/player_inspector_slot.cfg"
	var packed: PackedScene = load("res://scenes/player/player.tscn")
	var defaults: Node = packed.instantiate()
	root.add_child(defaults)
	defaults.process_mode = Node.PROCESS_MODE_DISABLED
	await process_frame
	var default_weapon: Node = defaults.get_node("Head/Camera3D/WeaponHolder")
	check(defaults.health == 100 and defaults.WALK_SPEED == 5.0, "Default salute e movimento conservati")
	check(not default_weapon.owns_pistol and not default_weapon.owns_smg and not default_weapon.owns_flashlight, "Default nessuna arma posseduta")
	check(default_weapon.magazine_ammo == 9 and default_weapon.reserve_ammo == 36 and default_weapon.smg_magazine_ammo == 30 and default_weapon.smg_reserve_ammo == 120, "Default munizioni conservate")
	check(default_weapon.flashlight_charge == 100.0 and default_weapon.spare_batteries == 0, "Default batterie conservate")
	defaults.queue_free()
	await process_frame

	var world := Node3D.new()
	world.name = "InspectorFixture"
	var player: Node = packed.instantiate()
	player.name = "Player"
	world.add_child(player)
	player.owner = world
	world.set_editable_instance(player, true)
	player.max_health = 180
	player.starting_health = 75
	player.WALK_SPEED = 6.2
	player.FOOTSTEP_WALK_INTERVAL = 0.7
	player.starting_inventory.assign({&"switch_key": 1})
	var weapon: Node = player.get_node("Head/Camera3D/WeaponHolder")
	weapon.starting_owns_pistol = true
	weapon.starting_owns_flashlight = true
	weapon.starting_owns_smg = true
	weapon.starting_equipped_weapon = 3
	weapon.pistol_magazine_size = 11
	weapon.pistol_starting_magazine_ammo = 4
	weapon.starting_reserve_ammo = 27
	weapon.smg_magazine_size = 25
	weapon.smg_starting_magazine_ammo = 8
	weapon.smg_starting_reserve_ammo = 55
	weapon.starting_flashlight_charge = 43.0
	weapon.max_spare_batteries = 2
	weapon.starting_spare_batteries = 9
	var camera: Camera3D = player.get_node("Head/Camera3D")
	camera.use_saved_fov = false
	camera.fov = 82.0
	var serialized := PackedScene.new()
	check(serialized.pack(world) == OK and ResourceSaver.save(serialized, FIXTURE) == OK, "Configurazione serializzata")
	world.free()

	# Percorso reale Nuova partita, con setup/caricamento e segnali SaveManager.
	saves.start_new_game(FIXTURE)
	check(await saves._load_scene(FIXTURE, {}), "Nuova partita da configurazione")
	player = current_scene.get_node("Player")
	player.process_mode = Node.PROCESS_MODE_DISABLED
	weapon = player.get_node("Head/Camera3D/WeaponHolder")
	await process_frame
	check(player.health == 75 and player.max_health == 180 and is_equal_approx(player.WALK_SPEED, 6.2), "Salute e movimento personalizzati applicati")
	check(is_equal_approx(player.get_node("Head/Camera3D").fov, 82.0), "FOV scena conservato se preferenza salvata disabilitata")
	check(is_equal_approx(player._get_footstep_interval(false), 0.7), "Ritmo passi personalizzato applicato")
	check(inventory.has_item(&"switch_key"), "Oggetti iniziali presenti dopo caricamento nuova partita")
	check(weapon.owns_pistol and weapon.owns_smg and weapon.owns_flashlight and weapon.equipped_weapon == 3 and weapon.smg_model.visible, "Possesso e arma equipaggiata applicati")
	check(weapon.magazine_ammo == 4 and weapon.reserve_ammo == 27 and weapon.smg_magazine_ammo == 8 and weapon.smg_reserve_ammo == 55, "Munizioni personalizzate applicate")
	check(weapon.flashlight_charge == 43.0 and weapon.spare_batteries == 2, "Carica e limite batterie applicati")
	weapon.equipped_weapon = 2
	weapon.flashlight_on = true
	weapon.flashlight_drain_per_second = 3.0
	weapon._update_flashlight_battery(2.0)
	check(weapon.flashlight_charge == 37.0, "Consumo torcia usa valore configurato")
	weapon.spare_batteries = 1
	weapon.reload_flashlight_battery()
	check(weapon.flashlight_charge == 100.0 and weapon.spare_batteries == 0, "Ricarica torcia conserva semantica percentuale")
	player.take_damage(15)
	check(player.health == 60, "Danno applicato alla salute personalizzata")
	inventory.remove_item(&"switch_key")
	var state: Dictionary = player.get_save_state()
	state.weapon.owns_smg = false
	state.weapon.equipped = 0
	state.weapon.pistol_magazine = 2
	state.weapon.charge = 17.0
	var checkpoint := {"scene": FIXTURE, "player": state, "inventory": {}, "world": {}}
	check(await saves._load_scene(FIXTURE, checkpoint), "Caricamento checkpoint con configurazione diversa")
	player = current_scene.get_node("Player")
	player.process_mode = Node.PROCESS_MODE_DISABLED
	weapon = player.get_node("Head/Camera3D/WeaponHolder")
	await process_frame
	check(player.health == 60 and weapon.magazine_ammo == 2 and weapon.flashlight_charge == 17.0 and not weapon.owns_smg and weapon.equipped_weapon == 0, "Checkpoint prevale su salute armi e munizioni iniziali")
	check(not inventory.has_item(&"switch_key"), "Checkpoint non riaggiunge oggetti gia consumati")
	player.apply_starting_inventory()
	check(not inventory.has_item(&"switch_key"), "Dotazione iniziale idempotente dopo restore")
	# F6/setup differito: l'inventario viene pulito dal setup dopo il ready del player.
	saves.start_new_game(FIXTURE)
	scene_changed.connect(func() -> void: saves.call_deferred("start_new_game", FIXTURE), CONNECT_ONE_SHOT)
	check(change_scene_to_file(FIXTURE) == OK, "Avvio diretto scena")
	await process_frame
	await process_frame
	player = current_scene.get_node("Player")
	player.process_mode = Node.PROCESS_MODE_DISABLED
	check(inventory.has_item(&"switch_key"), "Avvio diretto assegna dotazione dopo setup")
	# Un valore esposto deve sopravvivere anche al ready dei pickup derivati.
	var pickup: Node3D = load("res://scripts/pickups/inventory_item_pickup.gd").new()
	pickup.persistent_id = &"inspector.fixture.pickup"
	pickup.interaction_name = "CHIAVE PERSONALIZZATA"
	pickup.interaction_color = Color.CYAN
	current_scene.add_child(pickup)
	check(pickup.get_interaction_name() == "CHIAVE PERSONALIZZATA" and pickup.get_interaction_color() == Color.CYAN, "Pickup non sovrascrive nome e colore Inspector al ready")
	pickup.queue_free()
	await process_frame
	print("PLAYER_INSPECTOR_CONFIGURATION_", "PASS" if failures.is_empty() else "FAIL", " failures=", failures.size())
	quit(0 if failures.is_empty() else 1)
