extends SceneTree

class Occupant extends CharacterBody3D:
	var is_dead := false

const SETUP := preload("res://scripts/interactables/warehouse_door_setup.gd")
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func own_branch(node: Node, owner_root: Node) -> void:
	for child in node.get_children():
		child.owner = owner_root
		own_branch(child,owner_root)

func run() -> void:
	# Test an actual packed scene round trip, not only assignments to variables.
	var world := Node3D.new()
	world.name = "InspectorFixture"
	var source := MeshInstance3D.new()
	source.name = "OriginalPanel"
	source.mesh = BoxMesh.new()
	source.mesh.size = Vector3(1,2,0.04)
	source.position = Vector3(5,1,2)
	world.add_child(source)
	var manager = load("res://scripts/systems/warehouse_doors_integration.gd").new()
	manager.name = "WarehouseDoors"
	var setup := SETUP.new()
	setup.name = "EditableDoor"
	setup.source_visual = source
	setup.runtime_name = &"EditableRuntimeDoor"
	setup.persistent_id = &"test.inspector.door"
	setup.interaction_name = "PORTA CONFIGURATA"
	setup.width_axis = 0
	setup.hinge_at_max = false
	setup.open_angle = -60.0
	setup.open_speed = 2.5
	setup.auto_close = true
	setup.auto_close_delay = 8.0
	setup.required_key = &"switch_key"
	setup.door_audio_volume_db = -9.0
	setup.interaction_color = Color.CYAN
	manager.add_child(setup)
	world.add_child(manager)
	own_branch(world,world)
	var packed := PackedScene.new()
	check(packed.pack(world) == OK,"Configurazione non serializzabile")
	check(ResourceSaver.save(packed,"res://.godot/door_inspector_fixture.tscn") == OK,"Fixture non salvata")
	world.free()
	packed = load("res://.godot/door_inspector_fixture.tscn")
	world = packed.instantiate()
	root.add_child(world)
	current_scene = world
	await process_frame
	await process_frame
	manager = world.get_node("WarehouseDoors")
	setup = manager.get_node("EditableDoor")
	var properties:Dictionary={}
	for property in setup.get_property_list():properties[property.name]=property
	for field in ["source_visual","panel_source","runtime_name","persistent_id","open_angle","required_key","open_sound"]:
		check(properties.has(field) and (int(properties[field].usage)&PROPERTY_USAGE_EDITOR)!=0,"Campo non disponibile nell'Inspector: "+field)
	for group in ["Mesh e pannello","Movimento","Serratura","Audio"]:
		check(properties.has(group),"Gruppo Inspector mancante: "+group)
	check(manager._get_configuration_warnings().is_empty(),"Configurazione valida segnalata errata")
	check(manager.doors.size() == 1,"Configurazione non costruisce porta")
	if manager.doors.is_empty():quit(1);return
	var door = manager.doors[0]
	check(door.open_angle == -60.0 and door.open_speed == 2.5 and door.opening_normal.is_equal_approx(Vector3.BACK),"Movimento Inspector ignorato")
	check(door.auto_close and door.auto_close_delay == 8.0,"Chiusura automatica Inspector ignorata")
	check(door.persistent_id == &"test.inspector.door" and door.required_key == &"switch_key","Serratura o ID non conservati")
	check(door.door_audio_volume_db == -9.0 and door.interaction_color == Color.CYAN,"Audio/evidenziamento ignorati")
	check(setup.source_visual.global_position.is_equal_approx(Vector3(5,1,2)),"Pose chiusa cambiata durante migrazione")
	var inventory = root.get_node("InventoryManager")
	door.interact(null)
	check(not door.is_open,"Serratura configurata non funziona")
	inventory.add_item(&"switch_key")
	door.interact(null)
	check(door.is_open,"Chiave configurata non apre")
	# A duplicated configuration must expose a useful warning before building.
	var duplicate := SETUP.new()
	duplicate.name = "DuplicateConfiguration"
	duplicate.source_visual = setup.source_visual
	duplicate.runtime_name = setup.runtime_name
	duplicate.persistent_id = setup.persistent_id
	manager.add_child(duplicate)
	check(not duplicate._get_configuration_warnings().is_empty(),"Duplicati non segnalati")
	duplicate.free()
	# Automatic closing must wait for a player even outside the rotating Area3D.
	door.apply_persistent_state({"unlocked":true,"open":true})
	var occupant:=Occupant.new()
	occupant.name="Player"
	occupant.add_to_group("player")
	var shape:=CollisionShape3D.new()
	shape.name="CollisionShape3D"
	shape.shape=CapsuleShape3D.new()
	shape.shape.radius=0.32
	shape.shape.height=1.8
	occupant.add_child(shape)
	world.add_child(occupant)
	occupant.global_position=door.closed_center+door.opening_normal*0.4
	door.auto_close_timer.start(0.1)
	await create_timer(0.2).timeout
	check(door.is_open,"Chiusura automatica attraversa il giocatore")
	occupant.global_position=Vector3(100,5,100)
	await create_timer(0.4).timeout
	check(not door.is_open,"Chiusura automatica non riprende dopo il passaggio occupato")
	world.queue_free()
	await process_frame
	inventory.remove_item(&"switch_key")
	await fingerprint_configuration()
	print("DOOR_INSPECTOR_CONFIGURATION_TEST failures=",failures)
	quit(failures)

func fingerprint_configuration() -> void:
	var world:=Node3D.new()
	root.add_child(world)
	var manager=load("res://scripts/systems/warehouse_doors_integration.gd").new()
	manager.fingerprint_persistent_id=&"test.inspector.scanner"
	manager.fingerprint_unlock_seconds=0.3
	manager.fingerprint_error_seconds=0.2
	manager.fingerprint_accepted_color=Color("00ff88")
	var visual:=MeshInstance3D.new()
	visual.mesh=BoxMesh.new()
	visual.mesh.size=Vector3(0.01,0.06,0.06)
	world.add_child(visual)
	manager.fingerprint_visual=visual
	for index in 2:
		var panel:=MeshInstance3D.new()
		panel.mesh=BoxMesh.new()
		panel.mesh.size=Vector3(0.04,2,0.8)
		panel.position=Vector3(index*4,1,0)
		world.add_child(panel)
		var config:=SETUP.new()
		config.runtime_name=StringName("ConfigProbe"+str(index))
		config.persistent_id=StringName("test.inspector.order."+str(index))
		config.source_visual=panel
		config.fingerprint_locked=index==0
		manager.add_child(config)
	world.add_child(manager)
	await process_frame
	check(manager.scanner.door==manager.doors[0],"Lettore dipende dall'ordine dei figli")
	manager.scanner.scan(false)
	check(is_equal_approx(manager.scanner._feedback,0.2),"Durata errore Inspector ignorata")
	manager.scanner.scan(true)
	check(is_equal_approx(manager.doors[0].fingerprint_remaining,0.3),"Durata autorizzazione Inspector ignorata")
	check(manager.scanner.led.material_override.albedo_color==Color("00ff88"),"Colore LED Inspector ignorato")
	await create_timer(0.4).timeout
	check(manager.doors[0].fingerprint_remaining==0.0,"Autorizzazione configurata non scade")
	world.queue_free()
	await process_frame
