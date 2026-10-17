extends SceneTree

const CIRCUITS := {
	"Interruttore Luce Corridoio Magazzino": 12,
	"Interruttore Luce Lampadario Magazzino": 2,
	"Interruttore Luce Ingresso Magazzino": 2,
	"Interruttore Luce Bagno DX": 1,
	"Interruttore Luce Bagno SX": 1
}
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func check_circuits(selected: String) -> void:
	for name: String in CIRCUITS:
		var switch = current_scene.get_node(name)
		for material: BaseMaterial3D in switch.emissive_materials:
			check(material.emission_enabled == (name == selected), "Emissione non sincronizzata: " + name)

func check_visual(node: Node, emission_override: Texture2D = null) -> void:
	if node is MeshInstance3D:
		for surface in node.mesh.get_surface_count():
			var original := node.mesh.surface_get_material(surface) as BaseMaterial3D
			if original == null or not original.emission_enabled:
				continue
			var local := node.get_active_material(surface) as BaseMaterial3D
			check(local != original and original.emission_enabled, "Materiale importato condiviso modificato")
			check(local.emission == original.emission and local.emission_energy_multiplier == original.emission_energy_multiplier, "Colore/intensita emissione modificati")
			for texture in [BaseMaterial3D.TEXTURE_ALBEDO, BaseMaterial3D.TEXTURE_NORMAL, BaseMaterial3D.TEXTURE_EMISSION]:
				var expected: Texture2D = emission_override if texture == BaseMaterial3D.TEXTURE_EMISSION and emission_override != null else original.get_texture(texture)
				check(local.get_texture(texture) == expected, "Texture inattesa")
			print("EMISSION_BOUND ",node.get_path()," private=",local != original)
	for child in node.get_children():check_visual(child,emission_override)

func run() -> void:
	change_scene_to_file("res://scenes/maps/map_test.tscn")
	await process_frame
	await process_frame
	await physics_frame
	current_scene.get_node("AngelastriEncounter").set_process(false)
	var player = current_scene.get_node("Player")
	player.set_physics_process(false)
	player.global_position = Vector3(100,5,100)
	var power = current_scene.get_node("ConnesiPower")
	check_circuits("")
	for name: String in CIRCUITS:
		var switch = current_scene.get_node(name)
		check(switch.emissive_materials.size() == CIRCUITS[name], "Numero materiali errato: " + name)
		for path: NodePath in switch.emissive_visual_roots:
			check_visual(switch.get_node(path),switch.emission_texture_override)
	var entrance = current_scene.get_node("Interruttore Luce Ingresso Magazzino")
	var chandelier = current_scene.get_node("Interruttore Luce Lampadario Magazzino")
	check(entrance.persistent_id != chandelier.persistent_id and entrance.lights_root != chandelier.lights_root,"Ingresso condivide circuito/ID lampadari")
	check(root.get_node("SaveManager").participants.get(entrance.persistent_id) == entrance,"Interruttore ingresso non persistente")
	var mask: Image = chandelier.emission_texture_override.get_image()
	if mask.is_compressed():mask.decompress()
	check(mask.get_pixel(200,180).r > 0.9 and mask.get_pixel(500,600).r < 0.01,"Maschera lampadina non valida")
	power.turn_on()
	for name: String in CIRCUITS:
		var switch = current_scene.get_node(name)
		switch.interact(null)
		check_circuits(name)
		switch.interact(null)
		check_circuits("")
		switch.switch_audio.stop()
		switch.apply_persistent_state({"lights_on":true})
		check_circuits(name)
		check(not switch.switch_audio.playing, "Restore riproduce audio")
		switch.apply_persistent_state({"lights_on":false})
		check_circuits("")
	for name: String in CIRCUITS:current_scene.get_node(name).interact(null)
	power.turn_off()
	check_circuits("")
	power.turn_on()
	check_circuits("")
	var door = current_scene.get_node("WarehouseStairs038")
	check(door.open_angle == -90.0 and door.opening_normal == Vector3.RIGHT, "Porta038 verso errato")
	var frames: Dictionary = {}
	var frame_root := current_scene.get_node("connesi_building_test2/Porta Magazzino 01_003")
	for child in frame_root.get_children():
		if child is Node3D:frames[child] = child.global_transform
	door.interact(player)
	await create_timer(2.1).timeout
	check(door.is_open and not door.blocks_saving(), "Porta038 non apre")
	check(door.door_body.global_position.x >= door.closed_center.x, "Porta038 apre sugli scaffali")
	for side in [1.0,-1.0]:
		var params := PhysicsTestMotionParameters3D.new()
		params.from = player.global_transform
		params.from.origin = door.closed_center + door.opening_normal * side * 0.5
		params.from.origin.y = door.global_position.y + 0.91
		params.motion = door.opening_normal * side * -1.0
		params.recovery_as_collision = true
		check(not PhysicsServer3D.body_test_motion(player.get_rid(),params), "Porta038 aperta non attraversabile")
	for child: Node3D in frames:check(child.global_transform == frames[child], "Telaio038 spostato")
	door.close_door()
	await create_timer(2.1).timeout
	check(not door.is_open and not door.blocks_saving(), "Porta038 non chiude")
	print("WAREHOUSE_EMISSION_MAP_TEST failures=",failures)
	quit(failures)
