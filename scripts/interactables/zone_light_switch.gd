extends "res://scripts/interactables/interruttore.gd"
## Interruttore applicato alla mesh, con collider automatico, persistenza e gestione emissione.
## Le luci iniziano spente; il blackout spegne anche le superfici emissive.

## Emesso soltanto per un comando del giocatore riuscito, mai per blackout o restore.
signal player_toggled(enabled: bool)

@export_group("Salvataggio circuito")
## ID unico e stabile (es. main.lights.warehouse_entrance).
## Quando duplichi un interruttore assegnane uno nuovo; non cambiare gli ID dei circuiti esistenti.
@export var persistent_id: StringName
@export_group("Materiali luminosi")
## Mesh o gruppi relativi a questo interruttore. Includi il gruppo intero se centro e lati emettono.
## I materiali emissivi vengono copiati in RAM: gli originali e le altre istanze restano intatti.
@export var emissive_visual_roots: Array[NodePath] = []
## Facoltativo: maschera emissiva alternativa per le sole copie locali.
## Lascia vuoto per usare la texture originale; nei lampadari ripristina la maschera della lampadina.
@export var emission_texture_override: Texture2D
var emissive_materials: Array[BaseMaterial3D] = []

func try_toggle_lights() -> void:
	var previous := lights_on
	super.try_toggle_lights()
	if previous != lights_on:player_toggled.emit(lights_on)

## Imposta il circuito senza simulare un comando E e senza emettere player_toggled.
## Ritorna false se si sta tentando di accendere senza alimentazione.
func set_lights_on(enabled: bool) -> bool:
	if enabled and (power_system == null or not power_system.is_power_on()):return false
	if lights_on == enabled:return true
	lights_on = enabled
	_set_lights(enabled)
	return true

func _ready() -> void:
	_build_interaction_body()
	_prepare_emissive_materials()
	super._ready()
	call_deferred("_register_persistence")

func _build_interaction_body() -> void:
	var visual:=get_node(".") as MeshInstance3D
	if visual==null or visual.mesh==null:
		push_error("Zone switch requires its original mesh")
		return
	var bounds:=visual.get_aabb()
	var body:=StaticBody3D.new()
	body.name="InteractionBody"
	body.collision_layer=2
	body.collision_mask=0
	var collision:=CollisionShape3D.new()
	var shape:=BoxShape3D.new()
	shape.size=Vector3(maxf(bounds.size.x,.025),maxf(bounds.size.y,.025),maxf(bounds.size.z,.025))+Vector3.ONE*.012
	collision.shape=shape
	collision.position=bounds.get_center()
	body.add_child(collision)
	add_child(body)

func _set_lights(enabled:bool) -> void:
	if lights_root!=null:_set_branch(lights_root,enabled)
	for material:BaseMaterial3D in emissive_materials:
		material.emission_enabled=enabled

func _prepare_emissive_materials() -> void:
	for path:NodePath in emissive_visual_roots:
		var visual:=get_node_or_null(path)
		if visual==null:
			push_error("Zone light emissive mesh missing: "+String(path))
			continue
		_prepare_emissive_branch(visual)

func _prepare_emissive_branch(node:Node) -> void:
	if node is MeshInstance3D and node.mesh!=null:
		if node.material_override!=null:
			var original:=node.material_override as BaseMaterial3D
			if original!=null and original.emission_enabled:
				var private_material:=original.duplicate() as BaseMaterial3D
				if emission_texture_override!=null:private_material.set_texture(BaseMaterial3D.TEXTURE_EMISSION,emission_texture_override)
				node.material_override=private_material
				emissive_materials.append(private_material)
		else:
			for surface in node.mesh.get_surface_count():
				var original:=node.get_active_material(surface) as BaseMaterial3D
				if original!=null and original.emission_enabled:
					var private_material:=original.duplicate() as BaseMaterial3D
					if emission_texture_override!=null:private_material.set_texture(BaseMaterial3D.TEXTURE_EMISSION,emission_texture_override)
					node.set_surface_override_material(surface,private_material)
					emissive_materials.append(private_material)
	for child in node.get_children():_prepare_emissive_branch(child)

func _set_branch(node:Node,enabled:bool) -> void:
	if node is Light3D:node.visible=enabled
	for child in node.get_children():_set_branch(child,enabled)

func _register_persistence() -> void:
	if not persistent_id.is_empty():SaveManager.register_object(persistent_id,self)

func _exit_tree() -> void:
	if is_instance_valid(switch_audio):switch_audio.stop()
	if not persistent_id.is_empty():SaveManager.unregister_object(persistent_id,self)

func restore_priority() -> int:
	return 20

func get_persistent_state() -> Dictionary:
	return {"lights_on":lights_on}

func apply_persistent_state(state:Dictionary) -> void:
	lights_on=bool(state.get("lights_on",false)) and power_system!=null and power_system.is_power_on()
	_set_lights(lights_on)
