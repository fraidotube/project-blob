extends Node

signal inventory_changed

const KEY := preload("res://resources/items/bruno_key.tres")
var definitions: Dictionary = {}
var items: Dictionary = {}

func _ready() -> void:
	register_item(KEY)

func register_item(definition: Resource) -> void:
	if definition != null and not String(definition.item_id).is_empty():
		definitions[String(definition.item_id)] = definition

func add_item(item_id: StringName, quantity: int = 1) -> bool:
	var id := String(item_id)
	if quantity <= 0 or not definitions.has(id):
		return false
	var total := int(items.get(id, 0)) + quantity
	if total > int(definitions[id].max_quantity):
		return false
	items[id] = total
	inventory_changed.emit()
	return true

func has_item(item_id: StringName, quantity: int = 1) -> bool:
	return quantity > 0 and int(items.get(String(item_id), 0)) >= quantity

func remove_item(item_id: StringName, quantity: int = 1) -> bool:
	if not has_item(item_id, quantity):
		return false
	var id := String(item_id)
	items[id] = int(items[id]) - quantity
	if int(items[id]) == 0:
		items.erase(id)
	inventory_changed.emit()
	return true

func get_snapshot() -> Dictionary:
	return items.duplicate(true)

func restore_snapshot(snapshot: Dictionary) -> void:
	items.clear()
	for id: String in snapshot:
		if definitions.has(id) and int(snapshot[id]) > 0:
			items[id] = mini(int(snapshot[id]), int(definitions[id].max_quantity))
	inventory_changed.emit()

func clear() -> void:
	items.clear()
	inventory_changed.emit()
