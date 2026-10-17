extends "res://scripts/interactables/persistent_interactable.gd"

var door: Node
var led: MeshInstance3D
## Valori ricevuti dalla configurazione Inspector di WarehouseDoors.
var required_item: StringName = &"ced_fingerprint"
var error_feedback_seconds := 1.5
var idle_color := Color("168bff")
var rejected_color := Color("ff2323")
var accepted_color := Color("25ed65")
var _feedback := 0.0
var _accepted := false

func _ready() -> void:
	interaction_name = "LETTORE FINGERPRINT CED"
	super._ready()
	_update_led()

func get_interaction_action() -> String:
	return "USA IMPRONTA" if InventoryManager.has_item(required_item) else "SCANSIONA"

func interact(_player: Node) -> void:
	scan(InventoryManager.has_item(required_item))

## L'enigma futuro può fornire la credenziale senza simulare una vittoria.
func scan(authorized: bool) -> void:
	_accepted = authorized
	_feedback = door.fingerprint_unlock_seconds if authorized else error_feedback_seconds
	if authorized:
		door.authorize_fingerprint()
		GameplayUI.notify("Impronta riconosciuta. Puoi aprire il CED entro %s secondi." % String.num(door.fingerprint_unlock_seconds,1))
	else:
		GameplayUI.notify("Impronta non riconosciuta. Accesso negato.")
	_update_led()

func _process(delta: float) -> void:
	if _feedback <= 0.0:
		return
	_feedback = maxf(0.0, _feedback - delta)
	if _feedback == 0.0:
		_update_led()

func _update_led() -> void:
	if led == null:
		return
	var color := idle_color
	if _feedback > 0.0:
		color = accepted_color if _accepted else rejected_color
	var material := led.material_override as StandardMaterial3D
	material.albedo_color = color
	material.emission = color
