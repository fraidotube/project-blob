extends "res://scripts/interactables/persistent_interactable.gd"
class_name InventoryItemPickup

@export var item_id: StringName = &"bruno_key"
@export var quantity := 1
var collected := false

func _ready() -> void:
	interaction_name = "CHIAVE DI BRUNO"
	interaction_color = Color(1.0, 0.8, 0.3)
	_box(self, Vector3(0.06, 0.025, 0.24), Vector3(0, 0.05, 0), Color(0.9, 0.7, 0.15))
	_box(self, Vector3(0.15, 0.025, 0.1), Vector3(0, 0.05, -0.15), Color(0.9, 0.7, 0.15))
	_box(self, Vector3(0.1, 0.025, 0.025), Vector3(0.025, 0.05, 0.07), Color(0.9, 0.7, 0.15))
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
