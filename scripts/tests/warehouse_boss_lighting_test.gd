extends SceneTree

var failures := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void: run.call_deferred()

func run() -> void:
	if "--map" in OS.get_cmdline_user_args():
		await map_checks()
	else:
		await serialization_checks()
		await fixture_checks()
	print("WAREHOUSE_BOSS_LIGHTING_TEST failures=", failures)
	quit(failures)

func fixture_checks() -> void:
	var world := Node3D.new()
	root.add_child(world)
	current_scene = world
	var power = load("res://scripts/interactables/connesi_power.gd").new()
	power.name = "Power"
	world.add_child(power)
	var lights := Node.new()
	lights.name = "Circuit"
	var light := OmniLight3D.new()
	light.light_color = Color(1, 0.8, 0.6)
	light.light_energy = 0.6
	lights.add_child(light)
	world.add_child(lights)
	var visual := MeshInstance3D.new()
	visual.name = "FixtureLamp"
	visual.mesh = BoxMesh.new()
	var original := StandardMaterial3D.new()
	original.emission_enabled = true
	original.emission = Color(0.8, 0.9, 1)
	var original_image := Image.create(2, 2, false, Image.FORMAT_RGB8)
	original_image.fill(Color(0.1, 0.1, 0.1))
	original_image.set_pixel(0, 0, Color(0.9, 0.9, 0.9))
	original.albedo_texture = ImageTexture.create_from_image(original_image)
	visual.mesh.material = original
	world.add_child(visual)
	var light_switch = MeshInstance3D.new()
	light_switch.set_script(load("res://scripts/interactables/zone_light_switch.gd"))
	light_switch.name = "Switch"
	light_switch.mesh = BoxMesh.new()
	light_switch.power_system = power
	light_switch.lights_root = lights
	light_switch.emissive_visual_roots.append(NodePath("../FixtureLamp"))
	world.add_child(light_switch)
	var tint = load("res://scripts/tests/fixtures/warehouse_tint_fixture.gd").new()
	tint.boss_light_root_paths.append(NodePath("../Circuit"))
	tint.boss_light_switch_paths.append(NodePath("../Switch"))
	world.add_child(tint)
	var unrelated := OmniLight3D.new()
	world.add_child(unrelated)
	var color := light.light_color
	tint._apply_map_lighting()
	check(light.light_color.is_equal_approx(tint.boss_light_violet_color) and not light.visible, "Tinta accende circuito spento o non diventa viola")
	check(unrelated.light_color == Color.WHITE, "Luci estranee modificate")
	check(original.emission == Color(0.8, 0.9, 1), "Materiale originale modificato")
	power.turn_on()
	light_switch.try_toggle_lights()
	check(light.visible and light_switch.emissive_materials[0].emission_enabled, "Interruttore non funziona durante tinta")
	check(light_switch.emissive_materials[0].emission.is_equal_approx(tint.boss_light_violet_color), "Superficie non viola")
	tint._apply_map_lighting()
	power.turn_off()
	check(not light.visible, "Blackout non spegne durante tinta")
	tint._restore_map_lighting()
	check(light.light_color == color and is_equal_approx(light.light_energy, 0.6) and not light.visible, "Ripristino cambia energia/stato o colore")
	check(light_switch.emissive_materials[0].emission == original.emission, "Emissione originale non ripristinata")
	var actor := CharacterBody3D.new()
	actor.name = "Player"
	world.add_child(actor)
	actor.position = Vector3(0, 0.9, 0)
	var neon = load("res://scripts/environment/proximity_neon.gd").new()
	neon.position = Vector3(0, 2, 0)
	neon.visual = visual
	neon.light = unrelated
	neon.player = actor
	neon.power_system = power
	neon.activation_radius = 1.0
	neon.release_margin = 0.4
	neon.off_delay = 0.1
	neon.check_interval = 0.05
	world.add_child(neon)
	var source_image := original.albedo_texture.get_image()
	check(source_image.get_width() == 2 and source_image.get_pixel(0,0).r > 0.89, "Creazione maschera modifica texture sorgente")
	await create_timer(0.15).timeout
	check(not neon.is_lit, "Neon acceso senza corrente")
	power.turn_on()
	await create_timer(0.15).timeout
	check(neon.is_lit and unrelated.visible and neon.materials[0].emission_enabled, "Presenza non accende luce e superficie")
	actor.position.x = 1.2
	await create_timer(0.2).timeout
	check(neon.is_lit, "Isteresi ignorata")
	actor.position.x = 2.0
	await create_timer(0.25).timeout
	check(not neon.is_lit and not unrelated.visible, "Allontanamento non spegne")
	actor.position = Vector3(0, 6, 0)
	await create_timer(0.15).timeout
	check(not neon.is_lit, "Sensore rileva piano superiore")
	actor.position = Vector3(0.8, 0.9, 0)
	var wall := StaticBody3D.new()
	wall.position = Vector3(0.4, 1.5, 0)
	var collision := CollisionShape3D.new()
	collision.shape = BoxShape3D.new()
	collision.shape.size = Vector3(0.1, 3, 2)
	wall.add_child(collision)
	world.add_child(wall)
	await create_timer(0.2).timeout
	check(not neon.is_lit, "Sensore vede attraverso muro")
	wall.queue_free()
	await create_timer(0.2).timeout
	check(neon.is_lit, "Sensore non riprende a varco libero")
	power.turn_off()
	check(not neon.is_lit and not unrelated.visible, "Blackout neon non immediato")
	world.queue_free()
	await process_frame

func serialization_checks() -> void:
	var branch := Node3D.new()
	var power = load("res://scripts/interactables/connesi_power.gd").new()
	power.name = "Power"
	var player := Node3D.new()
	player.name = "Player"
	var visual := MeshInstance3D.new()
	visual.name = "Visual"
	visual.mesh = BoxMesh.new()
	visual.mesh.material = StandardMaterial3D.new()
	var light := OmniLight3D.new()
	light.name = "Light"
	var sensor = load("res://scripts/environment/proximity_neon.gd").new()
	sensor.name = "Sensor"
	sensor.power_system = power
	sensor.player = player
	sensor.visual = visual
	sensor.light = light
	sensor.activation_radius = 3.4
	sensor.off_delay = 0.2
	sensor.emission_energy = 2.3
	for child in [power, player, visual, light, sensor]:
		branch.add_child(child)
		child.owner = branch
	var packed := PackedScene.new()
	check(packed.pack(branch) == OK, "Configurazione neon non serializzabile")
	check(ResourceSaver.save(packed, "res://.godot/neon_configuration_fixture.tscn") == OK, "Fixture neon non salvata")
	branch.free()
	packed = load("res://.godot/neon_configuration_fixture.tscn")
	branch = packed.instantiate()
	root.add_child(branch)
	sensor = branch.get_node("Sensor")
	check(is_equal_approx(sensor.activation_radius, 3.4) and is_equal_approx(sensor.off_delay, 0.2), "Tuning sensore perso al caricamento")
	check(is_equal_approx(sensor.materials[0].emission_energy_multiplier, 2.3), "Energia emissiva Inspector non applicata")
	check(sensor.player == branch.get_node("Player") and sensor.visual == branch.get_node("Visual"), "Link Inspector persi al caricamento")
	branch.get_node("Power").turn_on()
	await create_timer(0.25).timeout
	check(sensor.is_lit, "Configurazione ricaricata non funziona")
	branch.queue_free()
	await process_frame

func map_checks() -> void:
	change_scene_to_file("res://scenes/maps/map_test.tscn")
	await process_frame
	await process_frame
	var encounter = current_scene.get_node("BroccoloEncounter")
	var combat = encounter.get_node("BroccoloMinionSpawner")
	while not combat.ready_for_test: await process_frame
	var player = current_scene.get_node("Player")
	player.set_physics_process(false)
	player.get_node("InteractionSystem").set_process(false)
	current_scene.get_node("AngelastriEncounter").set_process(false)
	var colors := {}
	for branch_name in ["Luci Corridoio Magazzino", "Luci Lampadario Magazzino"]:
		for light in current_scene.get_node(branch_name).get_children(): colors[light] = light.light_color
	var power = current_scene.get_node("ConnesiPower")
	power.turn_on()
	var switches: Array = []
	for switch_name in ["Interruttore Luce Corridoio Magazzino", "Interruttore Luce Lampadario Magazzino"]:
		var light_switch = current_scene.get_node(switch_name)
		light_switch.set_lights_on(true)
		switches.append(light_switch)
	await combat.configure(encounter, encounter.spawn.global_position)
	check(combat.saved_map_light_colors.size() == 8, "Tinta non limitata alle 8 luci previste")
	check(combat.saved_emission_colors.size() == 14, "Materiali corridoio/lampadari non tutti tinti")
	for light in colors:
		check(light.light_color.is_equal_approx(combat.boss_light_violet_color), "Luce mappa non viola")
	for light_switch in switches:
		light_switch.set_lights_on(false)
		light_switch.set_lights_on(true)
		for material in light_switch.emissive_materials:
			check(material.emission_enabled and material.emission.is_equal_approx(combat.boss_light_violet_color), "Switch perde tinta o collegamento")
	combat._boss_died()
	for light in colors: check(light.light_color == colors[light] and light.visible, "Fine boss non ripristina colore/stato")
	var sensors := current_scene.get_node("NeonMagazzinoSensors")
	check(sensors.get_child_count() == 3, "Tre neon mancanti")
	for sensor in sensors.get_children():
		check(sensor.visual != null and sensor.materials.size() > 0, "Mesh/materiale neon non collegato")
		player.global_position = sensor.global_position - Vector3.UP * 1.2
		await create_timer(0.25).timeout
		check(sensor.is_lit and sensor.light.visible, "Neon reale non rileva player sottostante")
		var mask: Image = sensor.materials[0].emission_texture.get_image()
		var bright := 0
		for y in mask.get_height():
			for x in mask.get_width():
				if mask.get_pixel(x,y).r > 0.1: bright += 1
		check(bright > 0 and bright < mask.get_width() * mask.get_height(), "Maschera tubo vuota o uniforme")
		print("NEON_MAP_MASK ", sensor.name, " bright=", bright)
	player.global_position = Vector3(100, 1, 100)
	await create_timer(1.0).timeout
	for sensor in sensors.get_children(): check(not sensor.is_lit, "Neon reale non spegne")
	power.turn_off()
