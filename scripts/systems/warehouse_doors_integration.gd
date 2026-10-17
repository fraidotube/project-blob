@tool
extends Node
## Costruisce le porte dalle configurazioni figlie, solo durante il gioco.
## Nell'editor seleziona un figlio per modificare mesh, cardine, serratura e audio.

const DOOR := preload("res://scripts/interactables/warehouse_swing_door.gd")
const SCANNER := preload("res://scripts/interactables/warehouse_fingerprint.gd")
const SETUP := preload("res://scripts/interactables/warehouse_door_setup.gd")

@export_group("Lettore fingerprint")
## Mesh del lettore interattivo (attualmente Plane_019). La porta si sceglie attivando
## Fingerprint Locked su una sola configurazione figlia, indipendentemente dal suo ordine.
@export var fingerprint_visual: MeshInstance3D
## ID del lettore nei salvataggi. Mantenerlo stabile per i checkpoint esistenti.
@export var fingerprint_persistent_id: StringName = &"main.ced.fingerprint"
## ID inventario dell'impronta autorizzata. Non crea o assegna l'oggetto.
@export var fingerprint_item: StringName = &"ced_fingerprint"
## Secondi per aprire manualmente la porta dopo una scansione corretta.
@export_range(0.1, 120.0, 0.1) var fingerprint_unlock_seconds := 10.0
## Durata del feedback rosso dopo una scansione errata.
@export_range(0.1, 10.0, 0.1) var fingerprint_error_seconds := 1.5
## Colore del LED a riposo e dopo la scadenza del feedback.
@export var fingerprint_idle_color := Color("168bff")
## Colore del LED dopo una scansione rifiutata.
@export var fingerprint_rejected_color := Color("ff2323")
## Colore del LED dopo una scansione autorizzata.
@export var fingerprint_accepted_color := Color("25ed65")

var doors: Array[Node3D] = []
var scanner: Node3D

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_setup.call_deferred()

func get_setups() -> Array[Node]:
	var result: Array[Node] = []
	for child in get_children():
		if child.get_script() == SETUP: result.append(child)
	return result

func _get_configuration_warnings() -> PackedStringArray:
	var errors := PackedStringArray()
	var fingerprint_count := 0
	for node in get_setups():
		var config = node
		for error in config._get_configuration_warnings(): errors.append(String(config.name)+": "+error)
		if config.fingerprint_locked: fingerprint_count += 1
	if get_setups().is_empty(): errors.append("Aggiungi almeno un figlio con warehouse_door_setup.gd.")
	if fingerprint_count > 1: errors.append("Un solo battente puo' essere associato a questo lettore fingerprint.")
	if fingerprint_count > 0 and fingerprint_visual == null: errors.append("Collega Fingerprint Visual alla mesh del lettore.")
	return errors

func _setup() -> void:
	var scene := get_parent() as Node3D
	var errors := _get_configuration_warnings()
	if not errors.is_empty():
		push_error("WarehouseDoors: "+"; ".join(errors))
		return
	var fingerprint_door: Node3D
	for node in get_setups():
		var config = node
		var source: Node3D = config.source_visual
		var panel: MeshInstance3D = config.get_panel()
		var bounds: AABB = panel.global_transform * panel.get_aabb()
		var hinge := bounds.get_center()
		hinge[config.width_axis] = bounds.end[config.width_axis] if config.hinge_at_max else bounds.position[config.width_axis]
		hinge.y = bounds.position.y
		var frame := Transform3D(Basis.IDENTITY, hinge)
		var local_box := AABB(bounds.position - hinge, bounds.size)
		var door := DOOR.new()
		door.name = config.runtime_name
		door.interaction_name = config.interaction_name
		door.persistent_id = config.persistent_id
		door.required_key = config.required_key
		door.fingerprint_locked = config.fingerprint_locked
		door.fingerprint_unlock_seconds = fingerprint_unlock_seconds
		door.open_angle = config.open_angle
		door.open_speed = config.open_speed
		door.auto_close = config.auto_close
		door.enemy_jump_open_enabled = config.enemy_jump_open_enabled
		door.auto_close_delay = config.auto_close_delay
		# Derive the normal from hinge/angle, avoiding a second editable direction.
		var radial := bounds.get_center() - hinge
		radial.y = 0
		var direction := Basis(Vector3.UP, signf(config.open_angle)*PI*0.5)*radial
		direction[config.width_axis] = 0
		door.opening_normal = direction.normalized()
		door.leaf_width = bounds.size[config.width_axis]
		door.closed_center = bounds.get_center()
		door.open_sound = config.open_sound
		door.close_sound = config.close_sound
		door.close_sound_at_start = config.close_sound_at_start
		door.door_audio_volume_db = config.door_audio_volume_db
		door.door_audio_max_distance = config.door_audio_max_distance
		door.interaction_color = config.interaction_color
		door.outline_width = config.outline_width
		door.transform = scene.global_transform.affine_inverse() * frame
		var body := AnimatableBody3D.new()
		body.name = "DoorBody"
		body.collision_layer = 3
		body.collision_mask = 0
		body.sync_to_physics = false
		door.add_child(body)
		door.panel_box = _box(body, local_box)
		var area := Area3D.new()
		area.name = "Area3D"
		area.collision_layer = 0
		area.collision_mask = 1
		_box(area, local_box.grow(0.1))
		door.add_child(area)
		var pose := source.global_transform
		_disable_collisions(source)
		source.get_parent().remove_child(source)
		body.add_child(source)
		source.top_level = false
		source.transform = frame.affine_inverse() * pose
		scene.add_child(door)
		doors.append(door)
		if config.fingerprint_locked: fingerprint_door = door
		print("WAREHOUSE_DOOR_READY ", door.name, " bounds=", bounds, " hinge=", hinge)
	if fingerprint_door != null:
		_setup_scanner(scene, fingerprint_door)

func _disable_collisions(node: Node) -> void:
	if node is CollisionObject3D:
		node.collision_layer = 0
		node.collision_mask = 0
	for child in node.get_children():
		_disable_collisions(child)

func _box(parent: Node3D, bounds: AABB) -> CollisionShape3D:
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(maxf(bounds.size.x, 0.035), maxf(bounds.size.y, 0.035), maxf(bounds.size.z, 0.035))
	collision.shape = shape
	collision.position = bounds.get_center()
	parent.add_child(collision)
	return collision

func _setup_scanner(scene: Node3D, door: Node3D) -> void:
	var source := fingerprint_visual
	var bounds: AABB = source.global_transform * source.get_aabb()
	var frame := Transform3D(Basis.IDENTITY, bounds.get_center())
	scanner = SCANNER.new()
	scanner.name = "CEDFingerprint"
	scanner.persistent_id = fingerprint_persistent_id
	scanner.required_item = fingerprint_item
	scanner.error_feedback_seconds = fingerprint_error_seconds
	scanner.idle_color = fingerprint_idle_color
	scanner.rejected_color = fingerprint_rejected_color
	scanner.accepted_color = fingerprint_accepted_color
	scanner.door = door
	scanner.transform = scene.global_transform.affine_inverse() * frame
	var body := StaticBody3D.new()
	body.collision_layer = 2
	body.collision_mask = 0
	scanner.add_child(body)
	_box(body, AABB(-bounds.size * 0.5, bounds.size).grow(0.01))
	var led := MeshInstance3D.new()
	led.name = "StatusLED"
	var box := BoxMesh.new()
	box.size = Vector3(0.002, 0.004, bounds.size.z * 0.55)
	led.mesh = box
	led.position = Vector3(bounds.size.x * 0.5 + 0.002, bounds.size.y * 0.5 - 0.006, 0)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.emission_enabled = true
	led.material_override = material
	scanner.led = led
	scanner.add_child(led)
	var pose := source.global_transform
	_disable_collisions(source)
	source.get_parent().remove_child(source)
	scanner.add_child(source)
	source.transform = frame.affine_inverse() * pose
	scene.add_child(scanner)
