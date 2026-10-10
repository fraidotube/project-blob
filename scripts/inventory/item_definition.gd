extends Resource
class_name InventoryItemDefinition

@export var item_id: StringName
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export_range(1, 999, 1) var max_quantity: int = 1
