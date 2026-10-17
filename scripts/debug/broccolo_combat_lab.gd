extends Node3D
## Laboratorio separato: controlli manuali e arena per il primo tuning Broccolo.

@export_group("Avvio prova")
## Avvio diretto con player FPS mobile e armi utilizzabili; Tab apre lo studio.
@export var start_in_fps := true
## Inizia il ciclo boss dopo la riduzione; disattivare per studio manuale.
@export var auto_combat := true
## Preparazione grafica delle copie sotto la mappa prima dello scontro (GPU).
@export var warmup_render := true
@export_group("Copie")
## Corpo configurabile riutilizzato per le copie; nessun riferimento alla mappa.
@export var actor_scene: PackedScene = preload("res://scenes/enemies/broccolo_lab_actor.tscn")
## Massimo di copie presenti, inclusi i corpi nella sequenza di morte.
@export_range(1, 12, 1) var max_copies := 3
## Attesa dal primo posto liberato prima di rigenerare, secondi.
@export_range(0.5, 30.0, 0.5) var regeneration_seconds := 6.0
## Intervallo tra due emissioni della stessa ondata, secondi.
@export_range(0.2, 3.0, 0.1) var emission_interval := 0.7
## Distanza dell'emersione dal corpo principale, metri.
@export_range(0.1, 1.0, 0.05) var emission_distance := 0.3
## Separazione minima fra direzioni delle copie presenti, gradi.
@export_range(10.0, 90.0, 5.0) var emission_separation_degrees := 55.0
@export_group("Navigazione laboratorio")
## Spaziatura della griglia fisica locale, metri. Solo arena di test.
@export_range(0.15, 0.8, 0.05) var grid_spacing := 0.4
## Estensione simmetrica della griglia sul piano X/Z, metri.
@export_range(4.0, 15.0, 0.5) var arena_extent := 8.0
@export_group("Collegamenti")
## Corpo principale con parametri e mosse serializzati nella scena.
@export var boss: CharacterBody3D
## Player FPS reale, senza modifiche ai suoi valori condivisi.
@export var player: CharacterBody3D
## HUD condiviso di Bruno, configurato localmente con broccolo.png.
@export var hud: CanvasLayer
## Scena grafica opzionale della sfera; null mantiene la versione mappa corrente.
@export var energy_visual_scene: PackedScene
## Condizione di bruciatura del player, collegata solo nella scena test.
@export var burn_status: Node3D

var copies: Array[Node] = []
var graph := AStar3D.new()
var cells: Dictionary = {}
var ready_for_test := false
var combat := false
var spawning := false
var replenish := -1.0
var emit_left := 0.0
var status: Label
var clips: OptionButton
var study_camera: Camera3D
var overview := true
var paused_actors := false
var selected: CharacterBody3D
var controls: Control
var follow_camera := true
var rng := RandomNumberGenerator.new()
var initial_wave := false
var hint_label: Label
var voice_owner: Node
var reserve: Array[Node] = []
var pool_ready := false
var spawn_times_ms: Array[float] = []

func claim_voice(actor: Node) -> bool:
	if is_instance_valid(voice_owner) and voice_owner.audio.voice.playing: return false
	voice_owner = actor
	return true

func _ready() -> void:
	rng.randomize()
	AudioManager.stop_menu_music()
	boss.target = player
	boss.lab = self
	boss.autonomous = false
	selected = boss
	boss.health_changed.connect(update_bar)
	boss.died.connect(_boss_died)
	_build_controls()
	await get_tree().physics_frame
	build_graph()
	await prepare_pool()
	if boss.preview_vfx_scene != null: boss.preview_transformation()
	ready_for_test = true
	update_bar()
	set_overview(not start_in_fps)
	if auto_combat: start_combat()

func prepare_pool() -> void:
	if pool_ready: return
	var configs := get_node("Roles").get_children()
	for index in max_copies:
		var actor = actor_scene.instantiate()
		actor.principal = false
		actor.role = configs[index % configs.size()]
		actor.position = Vector3(0, -1000, 0)
		actor.target = player
		actor.lab = self
		actor.pool = self
		actor.autonomous = false
		actor.preview_vfx_scene = boss.preview_vfx_scene
		add_child(actor)
		actor.add_collision_exception_with(boss)
		boss.add_collision_exception_with(actor)
		for other in reserve:
			actor.add_collision_exception_with(other)
			other.add_collision_exception_with(actor)
		await get_tree().process_frame
		retire_actor(actor)
		reserve.append(actor)
		await get_tree().process_frame
	if warmup_render and DisplayServer.get_name() != "headless": await _warm_render_pool()
	pool_ready = true
	print("BROCCOLO_POOL_READY count=", reserve.size())

func _warm_render_pool() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(96, 96)
	viewport.world_3d = get_world_3d()
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	if burn_status != null:
		var warm_screen := ColorRect.new()
		warm_screen.size = Vector2(96, 96)
		warm_screen.material = burn_status.overlay.material
		viewport.add_child(warm_screen)
	var camera := Camera3D.new()
	camera.cull_mask = 1 << 19
	camera.near = 0.01
	viewport.add_child(camera)
	camera.current = true
	for actor in reserve:
		var energy_sample: Node3D
		if energy_visual_scene != null and actor == reserve[0]:
			energy_sample = energy_visual_scene.instantiate()
			energy_sample.process_mode = Node.PROCESS_MODE_ALWAYS
			actor.add_child(energy_sample)
			energy_sample.position.y = 0.18
		if actor.power_fx != null:
			actor.power_fx.process_mode = Node.PROCESS_MODE_ALWAYS
			actor.power_fx.ignite(actor.power_fx.reference_height * actor.miniature_scale, 0.5, actor.copy_aura_color)
		var meshes := actor.find_children("*", "GeometryInstance3D", true, false)
		var layers: Array[int] = []
		for mesh in meshes:
			layers.append(mesh.layers)
			mesh.layers = 1 << 19
		actor.show()
		camera.global_position = actor.global_position + Vector3(0.5, 0.35, 0.6)
		camera.look_at(actor.global_position + Vector3.UP * 0.18)
		var effect := preload("res://scripts/effects/broccolo_lab_burst.gd").new()
		effect.position = actor.global_position + Vector3.UP * 0.15
		add_child(effect)
		for geometry in effect.find_children("*", "GeometryInstance3D", true, false): geometry.layers = 1 << 19
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		effect.queue_free()
		actor.hide()
		if actor.power_fx != null:
			actor.power_fx.stop()
			actor.power_fx.process_mode = Node.PROCESS_MODE_INHERIT
		for index in meshes.size(): meshes[index].layers = layers[index]
		if energy_sample != null: energy_sample.queue_free()
	viewport.queue_free()

func retire_actor(actor: Node) -> void:
	if actor.power_fx != null: actor.power_fx.stop()
	if actor.spawn_tween != null:
		actor.spawn_tween.kill()
		actor.spawn_tween = null
	copies.erase(actor)
	if selected == actor: selected = boss
	actor.audio.stop_voice()
	actor.audio.footsteps.stop()
	actor.audio.effect.stop()
	actor.animation.stop()
	actor.collision_layer = 0
	actor.collision_mask = 0
	actor.velocity = Vector3.ZERO
	actor.state = "pooled"
	actor.hide()
	actor.process_mode = Node.PROCESS_MODE_DISABLED

func try_gate(_actor: CharacterBody3D) -> bool:
	return false

func update_bar() -> void:
	if is_instance_valid(boss): hud.update_boss_hud(boss.health, boss.max_health, 1)

func _boss_died() -> void:
	if burn_status != null: burn_status.stop()
	for effect in get_tree().get_nodes_in_group("broccolo_energy_visuals"): effect.queue_free()
	combat = false
	spawning = false
	for projectile in get_tree().get_nodes_in_group("broccolo_lab_projectiles"): projectile.queue_free()
	for copy in copies:
		if is_instance_valid(copy):
			copy.autonomous = false
			copy.audio.stop_voice()
			if copy.state != "dead": copy.preview_clip(&"mie/idle")
	hud.hide_boss_hud()

func set_overview(enabled: bool) -> void:
	overview = enabled
	player.set_physics_process(not enabled)
	player.set_process_unhandled_input(not enabled)
	var weapon := player.get_node("Head/Camera3D/WeaponHolder")
	weapon.visible = not enabled
	weapon.set_process(not enabled)
	weapon.set_physics_process(not enabled)
	weapon.set_process_unhandled_input(not enabled)
	if enabled: study_camera.make_current()
	else: player.get_node("Head/Camera3D").make_current()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if enabled else Input.MOUSE_MODE_CAPTURED
	controls.visible = enabled
	status.visible = enabled
	hint_label.text = "BROCCOLO — LABORATORIO\nTab: studio / FPS | F2: ciclo completo | F3: stop AI\nF4: scenetta vulnerabile | F5: colpo sul selezionato\nF6: emetti copie | F7: pausa attori | F8: ricomincia" if enabled else "PROVA BROCCOLO — movimento e armi abituali\nTab: studio | F2: avvia lotta | F4: scenetta | F8: ricomincia"

func _build_controls() -> void:
	study_camera = Camera3D.new()
	add_child(study_camera)
	study_camera.position = Vector3(2.4, 1.5, 2.6)
	study_camera.look_at(boss.global_position + Vector3.UP * 0.3)
	study_camera.fov = 48
	var canvas := CanvasLayer.new()
	canvas.layer = 15
	add_child(canvas)
	var stack := VBoxContainer.new()
	stack.position = Vector2(16, 100)
	canvas.add_child(stack)
	status = Label.new()
	stack.add_child(status)
	var hint := Label.new()
	hint_label = hint
	hint.text = "BROCCOLO — LABORATORIO\nTab: studio / FPS | F2: ciclo completo | F3: stop AI\nF4: scenetta vulnerabile | F5: colpo sul selezionato\nF6: emetti copie | F7: pausa attori | F8: ricomincia\nIn FPS: comandi e armi abituali. In studio: bersaglio selezionato."
	stack.add_child(hint)
	var panel := VBoxContainer.new()
	stack.add_child(panel)
	controls = panel
	clips = OptionButton.new()
	for clip in boss.animation.get_animation_list():
		if String(clip).begins_with("mie/"): clips.add_item(String(clip))
	panel.add_child(clips)
	add_button(panel, "Prova clip selezionata (nessun attacco)", func():
		if is_instance_valid(selected): selected.preview_clip(StringName(clips.get_item_text(clips.selected))))
	add_button(panel, "Seleziona principale / prossima copia", select_next)
	add_button(panel, "Ciclo completo", start_combat)
	add_button(panel, "Gioca in FPS e combatti", func():
		start_combat()
		set_overview(false))
	add_button(panel, "Stop AI / torna allo studio", stop_combat)
	add_button(panel, "Scenetta: apre vulnerabilita del principale", func():
		if is_instance_valid(boss): boss.begin_show())
	add_button(panel, "Colpo utile sul selezionato", hit_selected)
	add_button(panel, "Attacco FlyingKick sul selezionato", func():
		if is_instance_valid(selected): selected.begin_move(selected.get_node("Moves/FlyingKick")))
	add_button(panel, "Lancio sfera sul selezionato", func():
		if is_instance_valid(selected): selected.begin_move(selected.get_node("Moves/Throw")))
	if burn_status != null:
		add_button(panel, "Prova bruciatura in FPS", func():
			stop_combat()
			set_overview(false)
			burn_status.ignite())
	add_button(panel, "Onda melee / VFX emissione", func():
		if is_instance_valid(selected):
			selected.emit_wave(0.85)
			selected.burst(selected.global_position + Vector3.UP * 0.1))
	add_button(panel, "Emetti / rigenera copie", request_copies)
	add_button(panel, "Ripeti trasformazione / aura dorata", func():
		if is_instance_valid(boss):
			selected = boss
			follow_camera = true
			boss.preview_transformation())
	add_button(panel, "Vista ravvicinata / arena", func(): follow_camera = not follow_camera)
	add_button(panel, "Ricomincia laboratorio", func(): get_tree().reload_current_scene())

func add_button(parent: Node, title: String, action: Callable) -> void:
	var button := Button.new()
	button.text = title
	button.pressed.connect(action)
	parent.add_child(button)

func select_next() -> void:
	var actors: Array[Node] = []
	if is_instance_valid(boss): actors.append(boss)
	for copy in copies:
		if is_instance_valid(copy): actors.append(copy)
	if actors.is_empty(): return
	selected = actors[(actors.find(selected) + 1) % actors.size()]

func hit_selected() -> void:
	if is_instance_valid(selected): selected.take_bullet_hit(1, selected.global_position + Vector3.UP * 0.13)

func start_combat() -> void:
	if not is_instance_valid(boss) or boss.state == "dead": return
	combat = true
	boss.autonomous = true
	if boss.state == "preview": boss.state = "chase"
	for copy in copies:
		if is_instance_valid(copy):
			copy.autonomous = true
			if copy.state == "preview": copy.state = "chase"
	request_copies()

func stop_combat() -> void:
	if burn_status != null: burn_status.stop()
	for effect in get_tree().get_nodes_in_group("broccolo_energy_visuals"): effect.queue_free()
	combat = false
	spawning = false
	for projectile in get_tree().get_nodes_in_group("broccolo_lab_projectiles"): projectile.queue_free()
	for actor in [boss] + copies:
		if is_instance_valid(actor) and actor.state != "dead":
			actor.autonomous = false
			actor.audio.stop_voice()
			actor.preview_clip(&"mie/idle")
	set_overview(true)

func request_copies() -> void:
	if not is_instance_valid(boss) or boss.state in ["dead", "shrink"]: return
	spawning = true
	replenish = -1
	emit_left = 0
	if boss.power_fx == null: boss.burst(boss.global_position + Vector3.UP * 0.1)

func _process(delta: float) -> void:
	if not ready_for_test: return
	for index in range(copies.size() - 1, -1, -1):
		if not is_instance_valid(copies[index]) or copies[index].is_queued_for_deletion(): copies.remove_at(index)
	if combat and is_instance_valid(player) and player.is_dead: stop_combat()
	if combat and not initial_wave and is_instance_valid(boss) and boss.state != "shrink":
		initial_wave = true
		request_copies()
	if combat and initial_wave and not paused_actors and copies.size() < max_copies and not spawning:
		if replenish < 0: replenish = regeneration_seconds
		else:
			replenish -= delta
			if replenish <= 0:
				request_copies()
				replenish = -1
	if spawning and not paused_actors:
		emit_left -= delta
		if copies.size() >= max_copies or not is_instance_valid(boss) or boss.state == "dead": spawning = false
		elif emit_left <= 0:
			emit_copy()
			emit_left = emission_interval
	if overview:
		if follow_camera and is_instance_valid(selected):
			var framing := maxf(1.0, selected.visual.scale.x / selected.miniature_scale)
			var aim_height := 0.12 * framing
			if selected.power_fx != null and selected.power_fx.visible and selected.power_fx.shell.visible:
				framing *= 1.35
				aim_height = selected.power_fx.body_height * 0.6
			study_camera.global_position = selected.global_position + Vector3(0.45, 0.3, 0.55) * framing
			study_camera.look_at(selected.global_position + Vector3.UP * aim_height)
		else:
			study_camera.position = Vector3(8, 8, 8)
			study_camera.look_at(Vector3.ZERO)
	var description := "principale eliminato"
	if is_instance_valid(selected): description = "%s | %s | HP %d | %s" % ["Principale" if selected.principal else "Copia", selected.state, selected.health, "VULNERABILE" if selected.vulnerable() else "PROTETTO"]
	if is_instance_valid(selected) and not selected.principal: description += " | " + String(selected.role_id)
	if status != null: status.text = "%s\nCopie %d/%d | Rigenerazione %.1fs\nCorsa: partenza / ciclo / inversione / frenata / atterraggio" % [description, copies.size(), max_copies, maxf(0, replenish)]

func emit_copy() -> Node:
	if not pool_ready or copies.size() >= max_copies or not is_instance_valid(boss): return null
	var started := Time.get_ticks_usec()
	for attempt in 36:
		var angle := rng.randf_range(-PI, PI)
		var direction := Vector3(sin(angle), 0, cos(angle))
		var distinct := true
		var separation := deg_to_rad(minf(emission_separation_degrees, 270.0 / max_copies))
		for other in copies:
			if is_instance_valid(other) and direction.dot(other.scatter_direction) > cos(separation): distinct = false
		if not distinct: continue
		var motion := direction * emission_distance
		if boss.test_move(boss.global_transform, motion): continue
		var copy: CharacterBody3D
		for candidate in reserve:
			if is_instance_valid(candidate) and candidate.state == "pooled":
				copy = candidate
				break
		if copy == null: return null
		copy.reset_for_spawn(boss.global_position)
		copy.autonomous = combat
		if copy.power_fx != null:
			copy.begin_emergence(direction, emission_distance)
			boss.power_fx.emit_copy(boss.power_fx.reference_height * boss.miniature_scale, boss.power_fx.emission_seconds, copy.copy_aura_color)
		else:
			copy.move_and_collide(motion)
			copy.scatter_direction = direction
			copy.scatter_left = copy.scatter_seconds
			copy.state = "scatter"
			copy.rotation.y = angle
			# Versione gia approvata nella mappa, fino all'approvazione dei nuovi VFX.
			var offset: Vector3 = copy.model_offset * copy.miniature_scale
			copy.visual.position = offset - motion
			var tween := copy.create_tween()
			copy.spawn_tween = tween
			tween.tween_property(copy.visual, "position", offset, 0.45)
		copies.append(copy)
		if boss.power_fx == null: boss.burst(boss.global_position + Vector3.UP * 0.1)
		spawn_times_ms.append((Time.get_ticks_usec() - started) / 1000.0)
		return copy
	return null

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	match event.keycode:
		KEY_TAB: set_overview(not overview)
		KEY_F2: start_combat()
		KEY_F3: stop_combat()
		KEY_F4:
			if is_instance_valid(boss): boss.begin_show()
		KEY_F5: hit_selected()
		KEY_F6: request_copies()
		KEY_F7:
			paused_actors = not paused_actors
			if burn_status != null: burn_status.set_paused(paused_actors)
			for actor in [boss] + copies:
				if is_instance_valid(actor):
					actor.set_physics_process(not paused_actors)
					actor.animation.speed_scale = 0 if paused_actors else 1
					actor.audio.set_paused(paused_actors)
					if actor.power_fx != null: actor.power_fx.set_paused(paused_actors)
			for projectile in get_tree().get_nodes_in_group("broccolo_lab_projectiles"): projectile.set_paused(paused_actors)
			for effect in get_tree().get_nodes_in_group("broccolo_energy_visuals"): effect.set_paused(paused_actors)
		KEY_F8: get_tree().reload_current_scene()
		_: return
	get_viewport().set_input_as_handled()

func build_graph() -> void:
	graph.clear()
	cells.clear()
	var half := int(arena_extent / grid_spacing)
	var space := get_world_3d().direct_space_state
	var exclude: Array[RID] = [boss.get_rid(), player.get_rid()]
	var shape := CapsuleShape3D.new()
	var configured_shape: CollisionShape3D = boss.get_node("BodyShape")
	shape.radius = configured_shape.shape.radius * configured_shape.scale.x + 0.015
	shape.height = configured_shape.shape.height * configured_shape.scale.y + 0.01
	for x in range(-half, half + 1):
		for z in range(-half, half + 1):
			var at := Vector3(x * grid_spacing, 0, z * grid_spacing)
			var ray := PhysicsRayQueryParameters3D.create(at + Vector3.UP * 2.5, at - Vector3.UP, 1)
			ray.exclude = exclude
			var floor_hit := space.intersect_ray(ray)
			if floor_hit.is_empty() or floor_hit.normal.y < 0.7 or floor_hit.position.y > 1.2: continue
			at.y = floor_hit.position.y + 0.015
			var query := PhysicsShapeQueryParameters3D.new()
			query.shape = shape
			query.transform.origin = at + Vector3.UP * (shape.height * 0.5 + 0.01)
			query.collision_mask = 1
			query.exclude = exclude
			if not space.intersect_shape(query).is_empty(): continue
			var id := graph.get_available_point_id()
			graph.add_point(id, at)
			cells[Vector2i(x, z)] = id
	for cell: Vector2i in cells:
		for offset in [Vector2i(1, 0), Vector2i(0, 1)]:
			var neighbor: Vector2i = cell + offset
			if not cells.has(neighbor): continue
			var a := graph.get_point_position(cells[cell])
			var b := graph.get_point_position(cells[neighbor])
			if absf(a.y - b.y) > boss.obstacle_height: continue
			var elevation := maxf(a.y, b.y) + 0.15
			var ray := PhysicsRayQueryParameters3D.create(Vector3(a.x, elevation, a.z), Vector3(b.x, elevation, b.z), 1)
			ray.exclude = exclude
			if space.intersect_ray(ray).is_empty(): graph.connect_points(cells[cell], cells[neighbor])

func route_direction(from: Vector3, to: Vector3) -> Vector3:
	if graph.get_point_count() == 0: return Vector3.ZERO
	var path := graph.get_point_path(graph.get_closest_point(from), graph.get_closest_point(to))
	if path.size() < 2: return Vector3.ZERO
	var heading := path[1] - from
	heading.y = 0
	return heading.normalized()
