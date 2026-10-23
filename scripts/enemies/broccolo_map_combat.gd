extends "res://scripts/debug/broccolo_combat_lab.gd"
## Stesso combattimento del laboratorio, senza camera/UI/input debug nella mappa.
const BOSS_PORTRAIT := preload("res://assets/ui/broccolo.png")

@export_group("Mappa e navigazione")
## Volume mondiale campionato per pavimenti, corridoio, magazzino e scale.
@export var navigation_bounds := AABB(Vector3(-2, -0.5, -9), Vector3(14, 6, 14))
## Budget massimo indicativo per porzione di costruzione grafo, millisecondi.
@export_range(0.5, 8.0, 0.5) var navigation_budget_ms := 2.0
## Configurazioni delle tre grigliate; riferimenti relativi a questo componente.
@export var gate_config_paths: Array[NodePath] = []
## Altezza del salto per raggiungere il comando della porta, metri.
@export_range(0.3, 1.2, 0.05) var gate_jump_height := 0.75
## Secondi dal decollo alla richiesta di apertura.
@export_range(0.1, 0.8, 0.02) var gate_open_at := 0.28
## Distanza massima della capsula dal centro porta per tentare il salto, metri.
@export_range(0.6, 2.0, 0.1) var gate_approach_distance := 1.25
@export_group("Musica combattimento")
## Soundtrack del combattimento Broccolo, avviata all'handoff e fermata alla vittoria.
@export var boss_music_stream: AudioStream = preload("res://assets/models/enemies/broccolo/Broccolo_soundtrack.mp3")
## Volume della musica boss sul bus Music.
@export_range(-30.0, 6.0, 0.5) var boss_music_volume_db := -8.0
## Punto della traccia in cui ripartire da zero, prima della coda muta finale (secondi).
@export_range(30.0, 293.0, 1.0) var boss_music_loop_at_seconds := 285.0
@export_group("Illuminazione boss fight")
## Intensita della tinta sui soli circuiti collegati: 1 = viola pieno.
@export_range(0.0, 1.0, 0.01) var boss_light_violet_strength := 1.0
## Colore verso cui sfumano le luci ambientali; energia e stato restano invariati.
@export var boss_light_violet_color := Color(0.55, 0.38, 0.82)
## Gruppi Light3D relativi a questo componente. Stato e interruttori non cambiano.
@export var boss_light_root_paths: Array[NodePath] = []
## Interruttori Zone Light Switch di cui tingere anche le copie dei materiali emissivi.
@export var boss_light_switch_paths: Array[NodePath] = []
@export_group("Salvataggio combattimento")
## Identificatore stabile: blocca salvataggi in battaglia e conserva la sconfitta.
@export var persistent_id: StringName = &"main.broccolo.combat"

@export_group("Chiave dopo la vittoria")
## Pickup lasciato a terra dal solo principale; vuoto disabilita il drop nelle fixture.
@export var victory_pickup_scene: PackedScene
## ID stabile e unico del pickup, distinto dallo stato del combattimento.
@export var victory_pickup_id: StringName = &"main.broccolo.assistance_key"
## Punto di recupero per vecchi checkpoint con boss gia sconfitto e senza posizione del drop.
@export var victory_fallback_marker: Node3D

var encounter: Node
var gates: Array[Node] = []
var navigation_exclusions: Array[RID] = []
var defeated := false
var started := false
var preparing := true
var saved_hud: Dictionary = {}
var paths: Dictionary = {}
var active_minions: Array[Node]:
	get: return copies
var boss_music_player: AudioStreamPlayer
var saved_map_light_colors: Dictionary = {}
var saved_emission_colors: Dictionary = {}
var victory_pickup_pose := Transform3D.IDENTITY
var _pickup_pending := false

func _ready() -> void:
	rng.randomize()
	overview = false
	boss = get_node("MainBroccolo")
	boss.hide()
	boss.process_mode = Node.PROCESS_MODE_DISABLED
	boss_music_player = AudioStreamPlayer.new()
	boss_music_player.name = "BroccoloBossMusic"
	boss_music_player.bus = &"Music"
	boss_music_player.stream = boss_music_stream
	boss_music_player.volume_db = boss_music_volume_db
	add_child(boss_music_player)
	SaveManager.register_object(persistent_id, self)
	_prepare_map.call_deferred()

func _prepare_map() -> void:
	encounter = get_parent()
	while is_inside_tree() and (not encounter.configured or not is_instance_valid(encounter.presentation) or not encounter.presentation.ready_for_preview):
		await get_tree().process_frame
	if not is_inside_tree(): return
	player = encounter.player
	hud = encounter.hud
	# Il link Inspector resta serializzato; questa risoluzione copre anche
	# l'istanza annidata della mappa, dove il Player e' fuori dal sotto-scene.
	if burn_status == null:
		burn_status = player.get_node_or_null("BroccoloBurnStatus")
	if burn_status == null:
		push_error("Broccolo: collegare BroccoloBurnStatus sotto Player nella mappa.")
	boss.target = player
	boss.lab = self
	boss.pool = self
	boss.autonomous = false
	boss.global_position = encounter.spawn.global_position
	boss.health_changed.connect(update_bar)
	boss.died.connect(_boss_died)
	selected = boss
	for path in gate_config_paths:
		var config := get_node_or_null(path)
		if config == null:
			push_error("Broccolo: configurazione porta mancante " + String(path))
			continue
		var door := get_tree().current_scene.get_node_or_null(NodePath(String(config.runtime_name)))
		while is_inside_tree() and door == null:
			await get_tree().process_frame
			door = get_tree().current_scene.get_node_or_null(NodePath(String(config.runtime_name)))
		if door != null:
			gates.append(door)
			navigation_exclusions.append(door.door_body.get_rid())
	await prepare_pool()
	await build_map_graph()
	ready_for_test = true
	preparing = false
	print("BROCCOLO_MAP_COMBAT_READY points=", graph.get_point_count(), " gates=", gates.size())

func configure(owner_encounter: Node, _center: Vector3) -> void:
	if started or defeated: return
	while is_inside_tree() and preparing: await get_tree().process_frame
	if not is_inside_tree() or defeated: return
	encounter = owner_encounter
	var actor: Node3D = encounter.presentation.actor
	var pose := Transform3D(actor.global_basis.orthonormalized(), actor.global_position)
	encounter.presentation.set_process(false)
	encounter.presentation.presentation.stop()
	encounter.presentation.voice.stop()
	encounter.presentation.music.stop()
	encounter.presentation.animation.stop()
	encounter.presentation.component.bind_voice(null)
	encounter.presentation.hide()
	boss.reset_for_spawn(pose.origin)
	boss.global_basis = pose.basis
	# Ripete nel mondo il ciclo approvato: corpo grande, riduzione con aura,
	# poi combattimento in scala ridotta. Le copie restano emesse dal corpo.
	boss.visual.scale = Vector3.ONE
	boss.visual.position = boss.model_offset
	boss.preview_transformation()
	boss.pool = self
	_save_hud()
	started = true
	initial_wave = false
	start_combat()
	update_bar()
	print("BROCCOLO_MAP_COMBAT_STARTED at=", boss.global_position)

func _save_hud() -> void:
	if not saved_hud.is_empty(): return
	saved_hud = {"texture": hud.boss_phase_1_texture, "blob": hud.boss_phase_1_blob_color, "glow": hud.boss_phase_1_glow_color}
	hud.boss_phase_1_texture = BOSS_PORTRAIT
	hud.boss_phase_1_blob_color = Color(0.03, 0.2, 0.5)
	hud.boss_phase_1_glow_color = Color(0.15, 0.65, 1)

func _restore_hud() -> void:
	if not is_instance_valid(hud) or saved_hud.is_empty(): return
	hud.hide_boss_hud()
	hud.boss_phase_1_texture = saved_hud.texture
	hud.boss_phase_1_blob_color = saved_hud.blob
	hud.boss_phase_1_glow_color = saved_hud.glow
	saved_hud.clear()

func _boss_died() -> void:
	if defeated: return
	_stop_boss_music()
	_restore_map_lighting()
	defeated = true
	super._boss_died()
	for actor in copies.duplicate(): retire_actor(actor)
	_restore_hud()
	if victory_pickup_scene != null:
		victory_pickup_pose = _floor_pickup_pose(boss.global_position)
		_pickup_pending = true
		_spawn_victory_pickup.call_deferred()

func _floor_pickup_pose(origin: Vector3) -> Transform3D:
	var ray := PhysicsRayQueryParameters3D.create(origin + Vector3.UP * 0.35, origin - Vector3.UP * 2.0, 1)
	var excluded: Array[RID] = []
	if is_instance_valid(boss): excluded.append(boss.get_rid())
	if is_instance_valid(player): excluded.append(player.get_rid())
	for actor in reserve:
		if is_instance_valid(actor): excluded.append(actor.get_rid())
	ray.exclude = excluded
	var hit := get_world_3d().direct_space_state.intersect_ray(ray)
	var point: Vector3 = hit.get("position", origin)
	return Transform3D(Basis.IDENTITY, point + Vector3.UP * 0.03)

func _spawn_victory_pickup() -> void:
	_pickup_pending = false
	if not defeated or victory_pickup_scene == null: return
	var state := SaveManager.object_state(victory_pickup_id)
	if bool(state.get("collected", false)) or SaveManager.participants.has(victory_pickup_id): return
	var pickup := victory_pickup_scene.instantiate() as Node3D
	if InventoryManager.has_item(pickup.item_id):
		pickup.free()
		return
	pickup.persistent_id = victory_pickup_id
	var scene := get_tree().current_scene as Node3D
	pickup.transform = scene.global_transform.affine_inverse() * victory_pickup_pose
	scene.add_child(pickup)
	# A pickup created during restore is not in SaveManager's initial restore list.
	pickup.apply_persistent_state(state)

func stop_combat() -> void:
	_stop_boss_music()
	_restore_map_lighting()
	combat = false
	spawning = false
	for projectile in get_tree().get_nodes_in_group("broccolo_lab_projectiles"): projectile.queue_free()
	for actor in copies.duplicate(): retire_actor(actor)
	if is_instance_valid(boss): retire_actor(boss)
	_restore_hud()

func _process(delta: float) -> void:
	if started and not defeated and is_instance_valid(boss_music_player) and boss_music_player.playing:
		var loop_point := minf(boss_music_loop_at_seconds, boss_music_player.stream.get_length() - 0.05)
		if boss_music_player.get_playback_position() >= loop_point:
			boss_music_player.play()
	if ready_for_test and started and not defeated: super._process(delta)

func start_combat() -> void:
	super.start_combat()
	if started and not defeated and is_instance_valid(boss_music_player) and boss_music_stream != null:
		boss_music_player.stream = boss_music_stream
		boss_music_player.volume_db = boss_music_volume_db
		boss_music_player.play()
	if started and not defeated:
		_apply_map_lighting()

func _apply_map_lighting() -> void:
	if not saved_map_light_colors.is_empty() or not saved_emission_colors.is_empty(): return
	for path in boss_light_root_paths:
		var branch := get_node_or_null(path)
		if branch == null:
			push_error("Broccolo: gruppo luci mancante " + String(path))
			continue
		_tint_light_branch(branch)
	for path in boss_light_switch_paths:
		var light_switch := get_node_or_null(path)
		if light_switch == null or not light_switch.get("emissive_materials") is Array:
			push_error("Broccolo: interruttore emissivo mancante " + String(path))
			continue
		for material: BaseMaterial3D in light_switch.emissive_materials:
			if saved_emission_colors.has(material.get_instance_id()): continue
			saved_emission_colors[material.get_instance_id()] = {"material": material, "color": material.emission}
			material.emission = material.emission.lerp(boss_light_violet_color, boss_light_violet_strength)

func _tint_light_branch(branch: Node) -> void:
	if branch is Light3D and not saved_map_light_colors.has(branch.get_instance_id()):
		saved_map_light_colors[branch.get_instance_id()] = {"node": branch, "color": branch.light_color}
		branch.light_color = branch.light_color.lerp(boss_light_violet_color, boss_light_violet_strength)
	for child in branch.get_children(): _tint_light_branch(child)

func _restore_map_lighting() -> void:
	for entry: Dictionary in saved_map_light_colors.values():
		var light := entry.get("node") as Light3D
		if is_instance_valid(light): light.light_color = entry.get("color", Color.WHITE)
	saved_map_light_colors.clear()
	for entry: Dictionary in saved_emission_colors.values():
		var material := entry.get("material") as BaseMaterial3D
		if is_instance_valid(material): material.emission = entry.color
	saved_emission_colors.clear()

func _stop_boss_music() -> void:
	if is_instance_valid(boss_music_player):boss_music_player.stop()

func _unhandled_input(_event: InputEvent) -> void:
	pass

func try_gate(actor: CharacterBody3D) -> bool:
	if actor.gate_retry > 0 or not actor.is_on_floor(): return false
	for door in gates:
		if not is_instance_valid(door) or door.is_open or not door.enemy_jump_open_enabled or not door.unlocked or door.fingerprint_locked: continue
		var offset: Vector3 = actor.global_position - door.closed_center
		var target_offset: Vector3 = player.global_position - door.closed_center
		var tangent: Vector3 = door.opening_normal.cross(Vector3.UP)
		if absf(offset.y) > 1.6 or Vector2(offset.x, offset.z).length() > gate_approach_distance: continue
		if absf(offset.dot(tangent)) > door.leaf_width * 0.5 + 0.12: continue
		if offset.dot(door.opening_normal) * target_offset.dot(door.opening_normal) >= 0: continue
		actor.begin_gate(door, gate_jump_height, gate_open_at)
		return true
	return false

func build_map_graph() -> void:
	graph.clear()
	var columns: Dictionary = {}
	var space := get_world_3d().direct_space_state
	var excluded := navigation_exclusions.duplicate()
	excluded.append(player.get_rid())
	for actor in [boss] + reserve: excluded.append(actor.get_rid())
	var shape := CapsuleShape3D.new()
	var body: CollisionShape3D = boss.get_node("BodyShape")
	shape.radius = body.shape.radius * body.scale.x + 0.01
	shape.height = body.shape.height * body.scale.y
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.collision_mask = 1
	query.exclude = excluded
	var slice_start := Time.get_ticks_usec()
	var width := int(navigation_bounds.size.x / grid_spacing)
	var depth := int(navigation_bounds.size.z / grid_spacing)
	for x in width + 1:
		for z in depth + 1:
			var at := navigation_bounds.position + Vector3(x * grid_spacing, 0, z * grid_spacing)
			var top := navigation_bounds.end.y
			for layer in 10:
				var ray := PhysicsRayQueryParameters3D.create(Vector3(at.x, top, at.z), Vector3(at.x, navigation_bounds.position.y, at.z), 1)
				ray.exclude = excluded
				var hit := space.intersect_ray(ray)
				if hit.is_empty(): break
				top = hit.position.y - 0.04
				if hit.normal.y < 0.65: continue
				at.y = hit.position.y + 0.012
				query.transform.origin = at + Vector3.UP * (shape.height * 0.5 + 0.005)
				query.motion = Vector3.ZERO
				if not space.intersect_shape(query, 1).is_empty(): continue
				var id := graph.get_available_point_id()
				graph.add_point(id, at)
				var cell := Vector2i(x, z)
				if not columns.has(cell): columns[cell] = []
				columns[cell].append(id)
			if Time.get_ticks_usec() - slice_start > navigation_budget_ms * 1000:
				await get_tree().process_frame
				slice_start = Time.get_ticks_usec()
	for cell: Vector2i in columns:
		for offset in [Vector2i(1, 0), Vector2i(0, 1)]:
			var neighbor: Vector2i = cell + offset
			if not columns.has(neighbor): continue
			for a_id: int in columns[cell]:
				for b_id: int in columns[neighbor]:
					var a := graph.get_point_position(a_id)
					var b := graph.get_point_position(b_id)
					if absf(a.y - b.y) > boss.obstacle_height: continue
					var elevation := maxf(a.y, b.y) + shape.height * 0.5 + 0.02
					query.transform.origin = Vector3(a.x, elevation, a.z)
					query.motion = Vector3(b.x - a.x, 0, b.z - a.z)
					if space.intersect_shape(query, 1).is_empty() and space.cast_motion(query)[0] > 0.999:
						graph.connect_points(a_id, b_id)
		if Time.get_ticks_usec() - slice_start > navigation_budget_ms * 1000:
			await get_tree().process_frame
			slice_start = Time.get_ticks_usec()
	# La griglia puo perdere una fila presso soglie/battenti sottili. Collega
	# i due pavimenti del varco solo dopo sweep completo della capsula reale.
	var portals := 0
	for door in gates:
		var center: Vector3 = door.closed_center
		center.y = door.global_position.y + 0.012
		var near_side: Vector3 = center - door.opening_normal * 0.7
		var far_side: Vector3 = center + door.opening_normal * 0.7
		var a_id := graph.get_closest_point(near_side)
		var b_id := graph.get_closest_point(far_side)
		if a_id < 0 or b_id < 0 or a_id == b_id: continue
		var a := graph.get_point_position(a_id)
		var b := graph.get_point_position(b_id)
		if a.distance_to(near_side) > 0.5 or b.distance_to(far_side) > 0.5 or absf(a.y - b.y) > boss.obstacle_height: continue
		query.transform.origin = Vector3(a.x, maxf(a.y, b.y) + shape.height * 0.5 + 0.02, a.z)
		query.motion = Vector3(b.x - a.x, 0, b.z - a.z)
		if space.intersect_shape(query, 1).is_empty() and space.cast_motion(query)[0] > 0.999:
			graph.connect_points(a_id, b_id)
			portals += 1
	print("BROCCOLO_MAP_GATE_PORTALS count=", portals)

func route_direction(from: Vector3, to: Vector3) -> Vector3:
	if graph.get_point_count() == 0: return Vector3.ZERO
	var start := graph.get_closest_point(from)
	var destination := graph.get_closest_point(to - Vector3.UP * 0.75)
	var key := Vector2i(start, destination)
	if not paths.has(key):
		if paths.size() > 256: paths.clear()
		# Punti su mobili/ripiani possono essere vicini al bersaglio ma separati:
		# avvicinarsi al limite raggiungibile permette poi salto/apertura/LOS.
		paths[key] = graph.get_point_path(start, destination, true)
	var path: PackedVector3Array = paths[key]
	if path.size() < 2: return Vector3.ZERO
	var heading := path[1] - from
	heading.y = 0
	return heading.normalized()

func blocks_saving() -> bool:
	return _pickup_pending or (started and not defeated)

func restore_priority() -> int:
	return 36

func get_persistent_state() -> Dictionary:
	return {"defeated": defeated, "victory_pickup_pose": victory_pickup_pose}

func apply_persistent_state(data: Dictionary) -> void:
	while is_inside_tree() and preparing: await get_tree().process_frame
	if not is_inside_tree(): return
	stop_combat()
	started = false
	initial_wave = false
	defeated = bool(data.get("defeated", false))
	_pickup_pending = false
	var existing: Node = SaveManager.participants.get(victory_pickup_id)
	if is_instance_valid(existing):
		SaveManager.unregister_object(victory_pickup_id, existing)
		existing.queue_free()
	if is_instance_valid(encounter):
		encounter.second_presentation_started = defeated
		encounter.presentation.sequence = false
		encounter.presentation.animation.play(&"mie/idle", 0)
		encounter.presentation.set_process(true)
		if defeated: encounter.presentation.hide()
	if defeated and victory_pickup_scene != null:
		var fallback := victory_fallback_marker.global_position if victory_fallback_marker != null else boss.global_position
		victory_pickup_pose = data.get("victory_pickup_pose", _floor_pickup_pose(fallback))
		_spawn_victory_pickup()

func _exit_tree() -> void:
	_stop_boss_music()
	_restore_map_lighting()
	_restore_hud()
	SaveManager.unregister_object(persistent_id, self)
