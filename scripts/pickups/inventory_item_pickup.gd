extends "res://scripts/interactables/persistent_interactable.gd"
class_name InventoryItemPickup

@export_group("Oggetto raccolto")
## ID gia registrato nell'InventoryManager; non crea automaticamente una nuova definizione.
@export var item_id: StringName = &"bruno_key"
## Quantita assegnata se l'inventario ha capienza sufficiente.
@export_range(1, 999, 1) var quantity := 1
@export_group("Targhetta chiave")
## Colora soltanto il materiale KeyTag del modello originale; metallo e anello restano invariati.
@export var tint_key_tag := false
## Tinta moltiplicata alla texture della targhetta, copiata solo in memoria.
@export var key_tag_color := Color(0.2, 0.65, 1.0)
var collected := false
const KEY_MODEL := preload("res://assets/models/edificio/key_with_tag/scene.gltf")

func _init() -> void:
	# Default prima della deserializzazione: i valori scelti nella scena devono prevalere.
	interaction_name = "CHIAVE DI BRUNO"
	interaction_color = Color(1.0, 0.8, 0.3)

func _ready() -> void:
	var model := KEY_MODEL.instantiate() as Node3D
	model.name = "KeyWithTag"
	add_child(model)
	if tint_key_tag:
		for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
			for surface in mesh.mesh.get_surface_count():
				var original := mesh.get_active_material(surface) as BaseMaterial3D
				if original != null and original.resource_name == "KeyTag":
					var material := original.duplicate() as BaseMaterial3D
					material.albedo_color = key_tag_color
					mesh.set_surface_override_material(surface, material)
	var box := AABB()
	var first := true
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		var local_box := global_transform.affine_inverse() * mesh.global_transform * mesh.get_aabb()
		box = local_box if first else box.merge(local_box)
		first = false
	var factor := 0.34 / maxf(box.size.x, maxf(box.size.y, box.size.z))
	model.scale *= factor
	model.position = Vector3(-box.get_center().x, -box.position.y, -box.get_center().z) * factor + Vector3.UP * 0.025
	_interaction_box(Vector3(0.35, 0.25, 0.45), Vector3(0, 0.1, 0))
	super._ready()

func get_interaction_action() -> String:
	return "RACCOGLI"

func interact(player: Node) -> void:
	if collected or bool(player.get("is_dead")):
		return
	if not InventoryManager.add_item(item_id, quantity):
		GameplayUI.notify("Oggetto già presente o inventario non disponibile.")
		return
	collected = true
	SaveManager.set_object_state(persistent_id, {"collected": true})
	set_interaction_focus(false)
	get_tree().call_group("player_face", "react", "pickup_major")
	GameplayUI.notify(interaction_name, item_id)
	queue_free()

func get_persistent_state() -> Dictionary:
	return {"collected": collected, "transform": global_transform}

func apply_persistent_state(state: Dictionary) -> void:
	if bool(state.get("collected", false)):
		collected = true
		queue_free()
	elif state.get("transform") is Transform3D:
		global_transform = state.transform
