extends Resource
class_name InventoryItemDefinition

@export_group("Identita oggetto")
## ID stabile usato da inventario, pickup, serrature e Starting Inventory. Non rinominare con salvataggi esistenti.
@export var item_id: StringName
## Nome leggibile mostrato nell'inventario.
@export var display_name: String = ""
## Descrizione nel pannello inventario.
@export_multiline var description: String = ""
## Icona dell'oggetto; se vuota InventoryManager tenta l'icona prevista per questo ID.
@export var icon: Texture2D
## Quantita massima trasportabile di questo oggetto; vale anche per la dotazione iniziale.
@export_range(1, 999, 1) var max_quantity: int = 1
