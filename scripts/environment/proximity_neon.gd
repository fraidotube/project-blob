extends Node3D
## Sensore di presenza indipendente: Light3D e materiale locale, senza modificare il GLB.

@export_group("Collegamenti")
## Mesh originale del neon; materiali duplicati soltanto durante il gioco.
@export var visual: MeshInstance3D
## Luce reale da accendere. Colore, energia, range e ombre si regolano sul nodo Light3D.
@export var light: Light3D
## Corrente aziendale. Se assente il componente segnala il collegamento mancante.
@export var power_system: Node
## Player; se vuoto viene cercato nel gruppo player.
@export var player: Node3D

@export_group("Sensore di presenza")
## Distanza orizzontale di accensione, in metri dall'origine di questo nodo.
@export_range(0.2, 10.0, 0.1) var activation_radius := 2.2
## Distanza aggiuntiva prima dello spegnimento, metri; evita lampeggi sul confine.
@export_range(0.0, 3.0, 0.1) var release_margin := 0.5
## Dislivello massimo tra sensore e player, metri; evita rilevamenti al piano superiore.
@export_range(0.2, 6.0, 0.1) var max_vertical_distance := 2.5
## Attesa prima di spegnere dopo l'uscita dal sensore, secondi.
@export_range(0.0, 5.0, 0.1) var off_delay := 0.6
## Intervallo di controllo, secondi. Non esegue ricerche fisiche a ogni frame.
@export_range(0.05, 1.0, 0.05) var check_interval := 0.15
## Pareti e porte impediscono al sensore di vedere il player.
@export var require_line_of_sight := true
## Layer fisici degli ostacoli del sensore.
@export_flags_3d_physics var occlusion_mask := 1

@export_group("Superficie luminosa")
## Colore della sola emissione, senza cambiare la texture albedo del neon.
@export var emission_color := Color(0.85, 0.92, 1.0)
## Intensita emissiva delle zone chiare della texture originale.
@export_range(0.0, 8.0, 0.1) var emission_energy := 1.5
## Luminosita minima della texture per isolare il tubo dal corpo scuro (0-1).
@export_range(0.1, 1.0, 0.05) var emission_threshold := 0.7

var materials: Array[BaseMaterial3D] = []
var is_lit := false
var _elapsed := 0.0
var _absent := 0.0

func _ready() -> void:
	if visual == null or light == null or power_system == null:
		push_error("Neon: collegare Visual, Light e Power System su " + String(get_path()))
		set_physics_process(false)
		return
	_prepare_materials()
	_set_lit(false)
	power_system.power_changed.connect(_on_power_changed)

func _prepare_materials() -> void:
	if visual.mesh == null: return
	for surface in visual.mesh.get_surface_count():
		var original := visual.get_active_material(surface) as BaseMaterial3D
		if original == null: continue
		var material := original.duplicate() as BaseMaterial3D
		# The imported Baked material is unlit: use real lighting while switched off.
		material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
		material.emission = emission_color
		material.emission_energy_multiplier = emission_energy
		if original.albedo_texture != null:
			var mask := original.albedo_texture.get_image().duplicate() as Image
			if mask.is_compressed(): mask.decompress()
			# Emission is a small mask; the full-resolution albedo remains untouched.
			mask.resize(256, 256, Image.INTERPOLATE_BILINEAR)
			mask.convert(Image.FORMAT_RGB8)
			for y in mask.get_height():
				for x in mask.get_width():
					var pixel := mask.get_pixel(x, y)
					var value := smoothstep(emission_threshold, 1.0, minf(pixel.r, minf(pixel.g, pixel.b)))
					mask.set_pixel(x, y, Color(value, value, value))
			material.emission_texture = ImageTexture.create_from_image(mask)
		visual.set_surface_override_material(surface, material)
		materials.append(material)

func _physics_process(delta: float) -> void:
	_elapsed += delta
	if _elapsed < check_interval: return
	var elapsed := _elapsed
	_elapsed = 0.0
	if not power_system.is_power_on():
		_absent = 0.0
		_set_lit(false)
		return
	if not is_instance_valid(player): player = get_tree().get_first_node_in_group("player") as Node3D
	if _detects_player():
		_absent = 0.0
		_set_lit(true)
	else:
		_absent += elapsed
		if _absent >= off_delay: _set_lit(false)

func _detects_player() -> bool:
	if not is_instance_valid(player): return false
	var offset := player.global_position - global_position
	var radius := activation_radius + (release_margin if is_lit else 0.0)
	if absf(offset.y) > max_vertical_distance or Vector2(offset.x, offset.z).length() > radius: return false
	if not require_line_of_sight: return true
	var ray := PhysicsRayQueryParameters3D.create(global_position, player.global_position, occlusion_mask)
	if player is CollisionObject3D: ray.exclude = [player.get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(ray).is_empty()

func _set_lit(enabled: bool) -> void:
	is_lit = enabled
	light.visible = enabled
	for material in materials: material.emission_enabled = enabled

func _on_power_changed(enabled: bool) -> void:
	if not enabled:
		_absent = 0.0
		_set_lit(false)
