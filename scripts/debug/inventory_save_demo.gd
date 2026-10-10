extends Node3D

const PLAYER := preload("res://scenes/player/player.tscn")
const HUD := preload("res://scenes/ui/hud.tscn")
const BRUNO := preload("res://scenes/enemies/bruno_buozzi.tscn")
const DOOR := preload("res://scripts/interactables/sliding_door.gd")
const PC := preload("res://scripts/interactables/save_pc_station.gd")
const PERSISTENT := preload("res://scripts/systems/persistent_object.gd")
const LOOT := preload("res://scripts/systems/boss_loot_drop.gd")
const METEORITE := preload("res://scripts/audio/meteorite_audio_trigger.gd")

var player: CharacterBody3D
var bruno: CharacterBody3D
var door: Node3D
var pc: Node3D
var event: Area3D

func _ready() -> void:
	SaveManager.select_scene_slot(scene_file_path)
	_build_environment()
	add_child(HUD.instantiate())
	player = PLAYER.instantiate() as CharacterBody3D
	player.name = "Player"
	player.position = Vector3(0, 0.85, 5)
	add_child(player)
	door = DOOR.new()
	door.name = "SlidingDoor"
	door.persistent_id = &"demo.door"
	door.position = Vector3(3, 0, -2)
	add_child(door)
	pc = PC.new()
	pc.name = "SavePC"
	pc.persistent_id = &"demo.pc"
	pc.position = Vector3(-2, 0, 3)
	add_child(pc)
	bruno = BRUNO.instantiate() as CharacterBody3D
	bruno.name = "Bruno"
	bruno.position = Vector3(-4, 0, -3)
	bruno.set("start_active", false)
	bruno.set("max_health", 30)
	bruno.set("show_boss_bar", true)
	bruno.set("boss_audio_debug", false)
	var loot := LOOT.new()
	loot.name = "Loot"
	loot.persistent_id = &"demo.bruno"
	loot.loot_id = &"demo.bruno_key"
	loot.boss = bruno
	bruno.add_child(loot)
	add_child(bruno)
	_add_pickup("res://scenes/pickups/pistol_pickup.tscn", Vector3(-1, 0.9, 1), &"demo.pistol")
	_add_pickup("res://scenes/pickups/smg_pickup.tscn", Vector3(0, 0.9, 1), &"demo.smg")
	_add_pickup("res://scenes/pickups/flashlight_pickup.tscn", Vector3(1, 0.9, 1), &"demo.flashlight")
	_add_pickup("res://scenes/pickups/ammo_pickup.tscn", Vector3(-1, 0.9, 0), &"demo.ammo")
	_add_pickup("res://scenes/pickups/SMG_ammo_pickup.tscn", Vector3(0, 0.9, 0), &"demo.smg_ammo")
	_add_pickup("res://scenes/pickups/battery_pickup.tscn", Vector3(1, 0.9, 0), &"demo.battery")
	_build_event()
	var hint := Label.new()
	hint.text = "PROVA INVENTARIO / SALVATAGGIO\nE: PC e oggetti  ·  I: inventario\nF7: avvia Bruno  ·  F8: morte\nDa morto: C carica  ·  N ricomincia\nPC: SALVA PARTITA  ·  Esc: CARICA SALVATAGGIO\nSlot di prova separato dalla mappa."
	hint.position = Vector2(24, 20)
	hint.add_theme_font_size_override("font_size", 20)
	var layer := CanvasLayer.new()
	layer.layer = 3
	add_child(layer)
	layer.add_child(hint)
	if not SaveManager.restoring:
		SaveManager.start_new_game(scene_file_path)
		# start_new_game clears old registrations; this scene is already constructed.
		for node: Node in [door, pc, loot]:
			SaveManager.register_object(node.get("persistent_id"), node)
		for node: Node in find_children("*", "Node", true, false):
			if node.get_script() == PERSISTENT:
				SaveManager.register_object(node.get("persistent_id"), node)

func _unhandled_input(input: InputEvent) -> void:
	if input is InputEventKey and input.pressed and not input.echo:
		if input.keycode == KEY_F7 and not bool(bruno.get("ai_active")) and int(bruno.get("health")) > 0:
			bruno.call("start_boss_fight")
		if input.keycode == KEY_F8 and not bool(player.get("is_dead")):
			player.call("take_damage", 10000)

func _add_pickup(path: String, at: Vector3, id: StringName) -> void:
	var pickup := (load(path) as PackedScene).instantiate() as Node3D
	pickup.position = at
	var persistence := PERSISTENT.new()
	persistence.name = "Persistence"
	persistence.persistent_id = id
	persistence.kind = 1
	persistence.target = pickup
	pickup.add_child(persistence)
	add_child(pickup)

func _build_event() -> void:
	event = METEORITE.new()
	event.name = "OneShotEvent"
	event.position = Vector3(0, 0, -1)
	event.cinematic_enabled = false
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2, 3, 1)
	shape.shape = box
	event.add_child(shape)
	var persistence := PERSISTENT.new()
	persistence.name = "Persistence"
	persistence.persistent_id = &"demo.building_event"
	persistence.kind = 3
	persistence.target = event
	event.add_child(persistence)
	add_child(event)

func _build_environment() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.06, 0.09, 0.13)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.8, 0.9, 1)
	environment.ambient_light_energy = 0.7
	world.environment = environment
	add_child(world)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -25, 0)
	add_child(light)
	var floor_body := StaticBody3D.new()
	floor_body.collision_layer = 3
	floor_body.add_to_group("surface_tile")
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(20, 0.2, 20)
	collider.shape = shape
	floor_body.position.y = -0.1
	floor_body.add_child(collider)
	var visual := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = shape.size
	visual.mesh = mesh
	floor_body.add_child(visual)
	add_child(floor_body)
	var region := NavigationRegion3D.new()
	var navigation := NavigationMesh.new()
	navigation.vertices = PackedVector3Array([Vector3(-10, 0, -10), Vector3(-10, 0, 10), Vector3(10, 0, 10), Vector3(10, 0, -10)])
	navigation.add_polygon(PackedInt32Array([0, 1, 2, 3]))
	region.navigation_mesh = navigation
	add_child(region)
