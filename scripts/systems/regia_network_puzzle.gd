extends Node3D

const STATE := preload("res://scripts/systems/regia_network_state.gd")
const INTERACT := preload("res://scripts/interactables/regia_puzzle_interactable.gd")
const PANEL := preload("res://scripts/ui/regia_puzzle_panel.gd")
const TERMINAL := preload("res://scripts/ui/regia_network_terminal.gd")
const GLYPHS := preload("res://scripts/ui/regia_alien_glyphs.gd")
const EXIT_DOOR := preload("res://scripts/interactables/regia_alien_exit_door.gd")
const SWITCH := preload("res://scripts/interactables/interruttore.gd")
const INSPECTION := preload("res://scripts/ui/regia_racket_inspection.gd")
const RACKET_SCENE := preload("res://scenes/pickups/bruno_racket_pickup.tscn")
const HANDLE_TEXTURE := preload("res://assets/textures/regia_racket_handle.res")
const ROUTER_VIEW := preload("res://scripts/ui/regia_router_view.gd")
const READER := preload("res://scripts/ui/regia_book_reader.gd")
const VISUALS := preload("res://scripts/ui/regia_item_visuals.gd")
const AUDIO := preload("res://scripts/systems/regia_audio.gd")
const LAPTOP_POSITION := Vector3(8.75, 1.0657, 4.90)
const LAPTOP_SCALE := 2.1
const CHARGER_POSITION := Vector3(8.95, 0.969, 5.38)
const ID := &"main.regia.network"
var state: Node
var integration: Node
var scene: Node3D
var power: Node
var laptop_visual: Node3D
var laptop_hinge: Node3D
var laptop_interaction: Node3D
var placement_interaction: Node3D
var laptop_terminal: Node3D
var alien_terminal: Node3D
var router_view: Node3D
var closure: MeshInstance3D
var exit_door: Node3D
var racket_drop: Node3D
var racket_visual_template: Node3D
var charger_visual: Node3D
var charger_interaction: Node3D
var charger_assembly: Node3D
var notes_visual: MeshInstance3D
var book_visual: MeshInstance3D
var power_strip: Node3D
var _laptop_source_pose: Transform3D
var fritz: Node3D
var switch_visual: Node3D
var regia_switch: Node3D
var corridor_switch: Node3D
var router_leds: Array[MeshInstance3D] = []
var alien_leds: Array[MeshInstance3D] = []
var cable_meshes: Dictionary = {}
var key_positions: Array[Vector3] = []
var busy_visuals := 0
var _last_unlocked := false
var _laptop_closed_angle := 0.0
var _font: Font
var audio: Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	integration = get_parent()
	scene = integration.scene
	var addon := scene.get_node_or_null("connesi_building_test2_addon_1")
	if addon == null:
		return
	audio = AUDIO.new()
	add_child(audio)
	add_to_group("regia_network")
	state = STATE.new()
	add_child(state)
	power = scene.get_node("ConnesiPower")
	state.powered = power.is_power_on()
	power.power_changed.connect(state.set_power)
	_font = GLYPHS.font()
	fritz = scene.get_node("connesi_building_test2/Fritzbox")
	switch_visual = addon.get_node("Switch Regia")
	charger_visual = addon.get_node("Caricatore PC")
	notes_visual = addon.get_node("Notebook")
	book_visual = addon.get_node("LibroRegia")
	power_strip = scene.get_node("connesi_building_test2/root")
	closure = addon.get_node("Porta Regia Chiusura")
	var laptop_source := addon.get_node("Portatile Regia") as MeshInstance3D
	_setup_laptop(laptop_source)
	_decorate_racket(scene.get_node("BrunoBuozzi").racket_visual)
	_make_interaction(fritz, "router", "FRITZ!BOX")
	_make_interaction(switch_visual, "connections", "SWITCH REGIA")
	charger_interaction = _make_interaction(charger_visual, "charger", "CARICATORE")
	charger_assembly = Node3D.new()
	add_child(charger_assembly)
	charger_assembly.global_position = CHARGER_POSITION
	VISUALS.box(charger_assembly, Vector3(0.12, 0.032, 0.06), Vector3.ZERO, Color("171a20"))
	_make_interaction(addon.get_node("Scatola Cavi"), "cables", "SCATOLA CAVI")
	_make_interaction(notes_visual, "notes", "APPUNTI")
	_make_interaction(book_visual, "book", "LIBRO ALIENO")
	_setup_exit()
	_setup_alien()
	_setup_router_leds()
	_setup_router_charger()
	router_view = ROUTER_VIEW.new()
	router_view.puzzle = self
	add_child(router_view)
	regia_switch = _light_switch(addon.get_node("Interruttore Luce Regia"), scene.get_node("Luci Regia"))
	var corridor_root := Node3D.new()
	add_child(corridor_root)
	scene.get_node("Luce Corridoio Regia").reparent(corridor_root, true)
	corridor_switch = _light_switch(addon.get_node("Interruttore Luce Corridoio Regia"), corridor_root)
	state.changed.connect(_refresh)
	SaveManager.restore_completed.connect(_restore_finished)
	scene.get_node("BrunoBuozzi").defeated.connect(_boss_defeated)
	SaveManager.register_object(ID, self)
	if not SaveManager.restoring:
		_refresh()
	print("REGIA_NETWORK_READY keys=", key_positions.size())

func _exit_tree() -> void:
	SaveManager.unregister_object(ID, self)

func _make_interaction(source: Node3D, action: String, title: String) -> Node3D:
	var wrapper := INTERACT.new()
	wrapper.name = "Puzzle_" + action
	wrapper.puzzle = self
	wrapper.action = action
	wrapper.title = title
	add_child(wrapper)
	var frame := Transform3D(Basis.IDENTITY, source.global_position)
	wrapper.global_transform = frame
	var box: AABB = integration._bounds(source, frame)
	integration._move_visual(source, wrapper, frame)
	wrapper.visual = source
	var body := StaticBody3D.new()
	body.name = "InteractionBody"
	body.collision_layer = 2
	body.collision_mask = 0
	wrapper.add_child(body)
	integration._box(body, AABB(box.position - Vector3.ONE * 0.02, box.size + Vector3.ONE * 0.04))
	return wrapper

func _light_switch(source: Node3D, lights: Node) -> Node3D:
	var result := SWITCH.new()
	result.power_system = power
	result.lights_root = lights
	result.interaction_color = Color("b86cff")
	result.switch_on_sound = load("res://assets/audio/interactions/switches/light-switch-turn-off-sound.wav")
	result.switch_off_sound = result.switch_on_sound
	var pose := source.global_transform
	result.transform = global_transform.affine_inverse() * Transform3D(Basis.IDENTITY, pose.origin)
	var box: AABB = integration._bounds(source, Transform3D(Basis.IDENTITY, pose.origin))
	integration._disable_old_collisions(source)
	source.get_parent().remove_child(source)
	result.add_child(source)
	source.transform = Transform3D(Basis.IDENTITY, pose.origin).affine_inverse() * pose
	var body := StaticBody3D.new()
	body.collision_layer = 2
	body.collision_mask = 0
	result.add_child(body)
	integration._box(body, box)
	add_child(result)
	return result

func _setup_laptop(source: MeshInstance3D) -> void:
	laptop_interaction = _make_interaction(source, "laptop", "PORTATILE")
	laptop_visual = source
	_laptop_source_pose = source.transform
	laptop_interaction.scale = Vector3.ONE * LAPTOP_SCALE
	laptop_interaction.global_position.y += 0.05582 * (LAPTOP_SCALE - 1.0)
	# The original lid and base are one surface. Split triangles, preserving
	# original vertex positions, normals, UVs and material on both new surfaces.
	var original := source.mesh
	var arrays: Array = original.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var top := SurfaceTool.new()
	var bottom := SurfaceTool.new()
	top.begin(Mesh.PRIMITIVE_TRIANGLES)
	bottom.begin(Mesh.PRIMITIVE_TRIANGLES)
	for triangle in range(0, indices.size(), 3):
		var center := (vertices[indices[triangle]] + vertices[indices[triangle + 1]] + vertices[indices[triangle + 2]]) / 3
		var tool := top if center.x < -0.014 and center.z > -0.036 else bottom
		for j in 3:
			var index := indices[triangle + j]
			tool.set_normal(arrays[Mesh.ARRAY_NORMAL][index])
			tool.set_uv(arrays[Mesh.ARRAY_TEX_UV][index])
			tool.add_vertex(vertices[index])
	var material := source.get_active_material(0)
	source.mesh = bottom.commit()
	source.material_override = material
	laptop_hinge = Node3D.new()
	laptop_hinge.position = Vector3(-0.018, 0, -0.035)
	source.add_child(laptop_hinge)
	var lid := MeshInstance3D.new()
	lid.name = "PuzzleLaptopLid"
	lid.mesh = top.commit()
	lid.material_override = material
	lid.position = -laptop_hinge.position
	laptop_hinge.add_child(lid)
	# Closing rotates the original vertical lid onto the original keyboard.
	_laptop_closed_angle = PI / 2
	laptop_terminal = TERMINAL.new()
	laptop_terminal.puzzle = self
	laptop_terminal.kind = "laptop"
	laptop_terminal.screen_size = Vector2(0.285, 0.177)
	laptop_hinge.add_child(laptop_terminal)
	laptop_terminal.position = Vector3(0.003, 0.048, 0.095)
	laptop_terminal.basis = Basis(Vector3.UP, Vector3.BACK, Vector3.RIGHT)
	laptop_terminal.scale = Vector3.ONE / source.scale.x
	var place_marker := Node3D.new()
	add_child(place_marker)
	place_marker.global_position = Vector3(8.52, 0.950, 5.02)
	placement_interaction = INTERACT.new()
	placement_interaction.puzzle = self
	placement_interaction.action = "place"
	placement_interaction.title = "SPAZIO PORTATILE"
	placement_interaction.visual = place_marker
	add_child(placement_interaction)
	placement_interaction.global_position = place_marker.global_position
	var body := StaticBody3D.new()
	body.collision_layer = 2
	body.collision_mask = 0
	placement_interaction.add_child(body)
	integration._box(body, AABB(Vector3(-0.28, -0.02, -0.42), Vector3(0.56, 0.05, 0.84)))
	# A subtle place marker; it disappears once the laptop occupies the space.
	var marker := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(0.52, 0.78)
	marker.mesh = quad
	marker.rotation.x = -PI / 2
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.5, 0.25, 0.7, 0.22)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	marker.material_override = mat
	place_marker.add_child(marker)
	placement_interaction.visual = place_marker

func _setup_exit() -> void:
	# glTF import sanitises periods in node names. Resolve by verified imported
	# role and location, and reject ambiguous matches rather than guessing a path.
	var source: Node3D
	for candidate: Node in scene.get_node("connesi_building_test2").get_children():
		if candidate is Node3D and String(candidate.name).begins_with("Porta Regia") and candidate.global_position.distance_to(closure.global_position) < 1.0:
			assert(source == null, "Ambiguous regia exit mesh")
			source = candidate
	assert(source != null, "Regia exit mesh missing")
	print("REGIA_EXIT_SOURCE ", source.get_path())
	var initial := Transform3D(Basis.IDENTITY, source.global_position)
	var box: AABB = integration._bounds(source, initial)
	var frame := Transform3D(Basis.IDENTITY, initial.origin + Vector3(box.end.x, 0, 0))
	exit_door = EXIT_DOOR.new()
	exit_door.puzzle = self
	exit_door.name = "RegiaAlienExit"
	exit_door.interaction_color = Color("b86cff")
	# Looking out from the regia (+Z), world +X is the right-hand hinge.
	# The leaf extends towards -X; positive Y rotates it into the regia (+Z).
	exit_door.open_angle = 90.0
	exit_door.leaf_width = box.size.x
	exit_door.closed_plane_z = initial.origin.z + box.get_center().z
	exit_door.closed_center_x = initial.origin.x + box.get_center().x
	exit_door.open_sound = AUDIO.stream(&"open")
	exit_door.close_sound = AUDIO.stream(&"close")
	exit_door.transform = global_transform.affine_inverse() * frame
	var body := AnimatableBody3D.new()
	body.name = "DoorBody"
	body.collision_layer = 3
	body.sync_to_physics = false
	exit_door.add_child(body)
	integration._box(body, integration._bounds(source, frame))
	integration._area(exit_door, integration._bounds(source, frame), "Area3D")
	integration._move_visual(source, body, frame)
	add_child(exit_door)
	integration._persistent(exit_door, &"main.door.regia_exit", 2)

func _setup_alien() -> void:
	var wrapper := _make_interaction(closure, "alien", "CHIUSURA ALIENA")
	wrapper.reparent(exit_door.door_body, true)
	# Keep the assembly attached to the moving door after permanent unlock.
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 1
	closure.add_child(body)
	integration._box(body, closure.get_aabb())
	alien_terminal = TERMINAL.new()
	alien_terminal.kind = "alien"
	alien_terminal.puzzle = self
	alien_terminal.screen_size = Vector2(0.31, 0.25)
	closure.add_child(alien_terminal)
	alien_terminal.position = Vector3(0.005, 0.26, 0.100)
	for row in 4:
		for col in 3:
			var point := Vector3(-0.021 + col * 0.047, 0.011 - row * 0.048, 0.110)
			key_positions.append(point)
			var glyph := Label3D.new()
			glyph.text = GLYPHS.symbol(row * 3 + col)
			glyph.font = _font
			glyph.font_size = 64
			glyph.pixel_size = 0.00035
			glyph.outline_size = 0
			glyph.modulate = Color("e7b5ff")
			glyph.no_depth_test = false
			closure.add_child(glyph)
			glyph.position = point
	for position in [Vector3(-0.17, 0.438, 0.105), Vector3(0.18, 0.438, 0.105)]:
		alien_leds.append(_led(closure, position, 0.015))

func _setup_router_leds() -> void:
	# Lens UV rectangles verified on the original 1600px Fritz atlas.
	# Power/Internet, Info (connection), WLAN: preserve all printed legends.
	for y in [541.0, 728.0, 589.0]:
		var led := MeshInstance3D.new()
		var tool := SurfaceTool.new()
		tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		for uv in [Vector2(665, y - 4), Vector2(704, y - 4), Vector2(704, y + 4), Vector2(665, y - 4), Vector2(704, y + 4), Vector2(665, y + 4)]:
			var sample := _router_uv_surface(uv / 1600.0)
			tool.set_normal(sample[1])
			tool.add_vertex(sample[0] + sample[1] * 0.035)
		led.mesh = tool.commit()
		var material := StandardMaterial3D.new()
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		led.material_override = material
		fritz.add_child(led)
		router_leds.append(led)

func _setup_router_charger() -> void:
	# Permanent scene prop, separate from the collectible laptop charger.
	var assembly := Node3D.new()
	assembly.name = "FritzPowerAdapter"
	add_child(assembly)
	var outlet := power_strip.global_position + Vector3(-0.015, 0.049, 0)
	assembly.global_position = outlet
	VISUALS.box(assembly, Vector3(0.046, 0.014, 0.038), Vector3(0, 0.007, 0), Color("b9bbc0"))
	VISUALS.box(assembly, Vector3(0.054, 0.060, 0.046), Vector3(0, 0.040, 0), Color("e0e0db"))
	var port := fritz.to_global(_router_uv_surface(Vector2(1350, 1533) / 1600.0)[0])
	var anchors: Array[Vector3] = [outlet + Vector3(-0.027, 0.04, 0), outlet + Vector3(-0.09, 0.012, 0.05), Vector3(8.96, 0.953, 4.17), Vector3(8.91, 0.953, 4.03), Vector3(8.92, 0.953, 3.81), port + Vector3(0, -0.008, 0.07), port]
	var curve := Curve3D.new()
	curve.bake_interval = 0.008
	for i in anchors.size():
		var tangent := (anchors[mini(i + 1, anchors.size() - 1)] - anchors[maxi(i - 1, 0)]) * 0.18
		curve.add_point(anchors[i] - outlet, -tangent if i > 0 else Vector3.ZERO, tangent if i < anchors.size() - 1 else Vector3.ZERO)
	VISUALS.wire(assembly, curve.get_baked_points(), Color("c9cac7"), 0.003)
	var plug := VISUALS.box(assembly, Vector3(0.009, 0.009, 0.020), port - outlet, Color("c9cac7"))
	plug.basis = Basis.looking_at((anchors[-2] - port).normalized(), Vector3.UP)

func _router_uv_surface(point: Vector2) -> Array[Vector3]:
	var arrays: Array = fritz.mesh.surface_get_arrays(0)
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	for triangle in range(0, indices.size(), 3):
		var a := indices[triangle]
		var b := indices[triangle + 1]
		var c := indices[triangle + 2]
		var first := uvs[b] - uvs[a]
		var second := uvs[c] - uvs[a]
		var delta := point - uvs[a]
		var determinant := first.cross(second)
		if absf(determinant) < 0.000001: continue
		var v := delta.cross(second) / determinant
		var w := first.cross(delta) / determinant
		var u := 1.0 - v - w
		if minf(u, minf(v, w)) >= -0.0001:
			return [vertices[a] * u + vertices[b] * v + vertices[c] * w, (normals[a] * u + normals[b] * v + normals[c] * w).normalized()]
	assert(false, "Fritz atlas mount not found")
	return [Vector3.ZERO, Vector3.UP]

func _led(parent: Node3D, position: Vector3, radius: float) -> MeshInstance3D:
	var led := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2
	led.mesh = sphere
	led.material_override = StandardMaterial3D.new()
	parent.add_child(led)
	led.position = position
	return led

func _led_color(led: MeshInstance3D, color: Color) -> void:
	var material := led.material_override as StandardMaterial3D
	material.albedo_color = color
	material.emission_enabled = color.get_luminance() > 0.04
	material.emission = color
	material.emission_energy_multiplier = 2.5

func action_label(action: String) -> String:
	match action:
		"laptop": return "RACCOGLI" if state.laptop_shutdown or not state.laptop_placed else "USA"
		"place": return "APPOGGIA PORTATILE"
		"cables", "racket": return "RACCOGLI"
		"charger": return "RACCOGLI"
		"notes", "book": return "LEGGI"
		"alien": return "ESAMINA"
		"router": return "ESAMINA" if state.pc_link or state.switch_link else "COLLEGA"
	return "COLLEGA / SCOLLEGA"

func interact_action(action: String) -> void:
	match action:
		"laptop":
			if not state.laptop_collected:
				if state.take_laptop(): GameplayUI.notify("Portatile raccolto.", &"regia_laptop")
			else:
				var charger_was_connected: bool = state.charger_connected
				var result: String = state.use_laptop()
				if not charger_was_connected and state.charger_connected:
					audio.play_at(&"cable", laptop_port(true))
				if result == "terminal": GameplayUI.open_terminal(laptop_terminal)
				elif result == "RACCOLTO": GameplayUI.notify("Portatile e caricatore raccolti.", &"regia_laptop")
				else: GameplayUI.notify(result)
		"place":
			if not state.place_laptop(): GameplayUI.notify(state.status)
		"charger":
			if state.take_charger(): GameplayUI.notify("Caricatore raccolto.", &"regia_charger")
		"cables":
			if state.take_cable(): GameplayUI.notify("Cavo di rete raccolto.", &"network_cable")
			else: GameplayUI.notify(state.status)
		"router":
			if state.pc_link or state.switch_link: GameplayUI.open_terminal(router_view)
			else: _router_choice()
		"connections": _router_choice()
		"alien": GameplayUI.open_terminal(alien_terminal)
		"notes":
			state.notes_read = true
			_open_book("notes", notes_visual)
		"book":
			state.book_read = true
			_open_book("book", book_visual)
		"racket":
			if state.racket_available and not state.racket_collected and InventoryManager.add_item(&"bruno_racket"):
				state.racket_collected = true
				state.changed.emit()
				GameplayUI.notify("Racchetta di Bruno raccolta.", &"bruno_racket")

func _open_book(kind: String, source: MeshInstance3D) -> void:
	var panel := READER.new()
	panel.kind = kind
	panel.source_texture = source.get_active_material(0).albedo_texture
	if not GameplayUI.open_puzzle_panel(panel): panel.free()

func _router_choice() -> void:
	if not state.laptop_collected or (not InventoryManager.has_item(&"network_cable") and not state.pc_link and not state.switch_link):
		GameplayUI.notify("Mi serve un PC ed un cavo di rete per configurarlo.")
		return
	var panel := PANEL.new()
	panel.heading.text = "DOVE COLLEGARE IL FRITZ?"
	panel.body.text = "Cavi disponibili: %d / 2" % int(InventoryManager.items.get("network_cable", 0))
	for destination: String in ["pc", "switch"]:
		var linked: bool = state.pc_link if destination == "pc" else state.switch_link
		var target_name := "PC" if destination == "pc" else "switch"
		var prefix := ("Scollega dal " if linked else "Collega al ") if destination == "pc" else ("Scollega dallo " if linked else "Collega allo ")
		var text := prefix + target_name
		panel.add_action(text, func():
			var previous: bool = state.pc_link if destination == "pc" else state.switch_link
			if state.toggle_cable(destination):
				GameplayUI.close_modal()
				if not previous: _animate_cable(destination)
			else: panel.body.text = state.status
		, linked or (InventoryManager.has_item(&"network_cable") and (destination == "switch" or state.laptop_placed)))
	panel.add_action("ANNULLA [ESC]", GameplayUI.close_modal)
	if not GameplayUI.open_puzzle_panel(panel): panel.free()

func _animate_cable(destination: String) -> void:
	if not cable_meshes.has(destination): return
	var mesh: MeshInstance3D = cable_meshes[destination]
	busy_visuals += 1
	mesh.scale = Vector3.ONE * 0.01
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(mesh, "scale", Vector3.ONE, 0.6)
	tween.tween_callback(func():
		busy_visuals -= 1
		var connected: bool = state.pc_link if destination == "pc" else state.switch_link
		if connected:
			var endpoint: Vector3 = laptop_port(false) if destination == "pc" else switch_visual.global_position
			audio.play_at(&"cable", endpoint)
	)

func _cable(name: String, points: Array[Vector3], color: Color) -> void:
	if not cable_meshes.has(name):
		# Smooth slack curves follow desk/floor anchors rather than taut chords.
		var curve := Curve3D.new()
		curve.bake_interval = 0.008
		for i in points.size():
			var tangent := (points[mini(i + 1, points.size() - 1)] - points[maxi(i - 1, 0)]) * 0.18
			curve.add_point(points[i], -tangent if i > 0 else Vector3.ZERO, tangent if i < points.size() - 1 else Vector3.ZERO)
		points = []
		for point in curve.get_baked_points(): points.append(point)
		var mesh := MeshInstance3D.new()
		var tool := SurfaceTool.new()
		tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		for segment in points.size() - 1:
			var direction := (points[segment + 1] - points[segment]).normalized()
			var side := direction.cross(Vector3.UP)
			if side.length_squared() < 0.01: side = direction.cross(Vector3.RIGHT)
			var radius := 0.003 if name.begins_with("charger") else 0.004
			side = side.normalized() * radius
			var other := direction.cross(side).normalized() * radius
			for ring in 8:
				var a := side * cos(TAU * ring / 8) + other * sin(TAU * ring / 8)
				var b := side * cos(TAU * (ring + 1) / 8) + other * sin(TAU * (ring + 1) / 8)
				for vertex in [points[segment] + a, points[segment + 1] + a, points[segment + 1] + b, points[segment] + a, points[segment + 1] + b, points[segment] + b]:
					tool.add_vertex(vertex - points[0])
		tool.generate_normals()
		mesh.mesh = tool.commit()
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = 0.78
		mesh.material_override = material
		add_child(mesh)
		mesh.global_position = points[0]
		for end in [0, points.size() - 1]:
			var connector := MeshInstance3D.new()
			var plug := BoxMesh.new()
			plug.size = Vector3(0.012, 0.014, 0.021) if not name.begins_with("charger") else Vector3(0.008, 0.008, 0.015)
			connector.mesh = plug
			var plastic := StandardMaterial3D.new()
			plastic.albedo_color = Color("c5cfda") if not name.begins_with("charger") else Color("17171c")
			plastic.roughness = 0.48
			connector.material_override = plastic
			mesh.add_child(connector)
			connector.position = points[end] - points[0]
			var neighbour := points[1] if end == 0 else points[end - 1]
			connector.basis = Basis.looking_at((neighbour - points[end]).normalized(), Vector3.UP)
		cable_meshes[name] = mesh
	var cable: MeshInstance3D = cable_meshes[name]
	cable.visible = state.pc_link if name == "pc" else (state.switch_link if name == "switch" else state.charger_connected)

func _refresh() -> void:
	if laptop_visual == null: return
	laptop_interaction.visible = not state.laptop_collected or state.laptop_placed
	for body: Node in laptop_interaction.find_children("*", "CollisionObject3D", true, false):
		body.collision_layer = 2 if laptop_interaction.visible else 0
	placement_interaction.visible = not state.laptop_placed
	placement_interaction.get_child(0).collision_layer = 0 if state.laptop_placed else 2
	placement_interaction.visual.visible = not state.laptop_placed
	if state.laptop_placed:
		laptop_interaction.global_transform = Transform3D(Basis(Vector3.UP, PI).scaled(Vector3.ONE * LAPTOP_SCALE), LAPTOP_POSITION)
	charger_interaction.visible = not state.charger_collected
	charger_interaction.get_node("InteractionBody").collision_layer = 0 if state.charger_collected else 2
	charger_assembly.visible = state.charger_connected and state.laptop_placed
	laptop_hinge.rotation.y = 0.0 if state.laptop_open else _laptop_closed_angle
	laptop_terminal.visible = state.laptop_open
	_led_color(router_leds[0], Color("35df70") if state.powered else Color("171b1a"))
	_led_color(router_leds[1], Color("35df70") if state.online else Color("ef3535"))
	_led_color(router_leds[2], Color("35df70") if state.powered and state.wifi_enabled else Color("171b1a"))
	_led_color(alien_leds[0], Color("24acff") if state.alien_connected() else Color("ef3535"))
	_led_color(alien_leds[1], Color("35df70") if state.unlocked else Color("ef3535"))
	var router_port: Vector3 = fritz.to_global(_router_uv_surface(Vector2(1350, 1160) / 1600.0)[0])
	var second_port: Vector3 = fritz.to_global(_router_uv_surface(Vector2(1350, 1225) / 1600.0)[0])
	var pc_port := laptop_port(false)
	var power_port := laptop_port(true)
	_cable("pc", [router_port, router_port + Vector3(0.01, -0.01, -0.09), Vector3(8.47, 0.951, 3.74), Vector3(8.39, 0.951, 4.13), Vector3(8.48, 0.951, 4.43), pc_port + Vector3(0, -0.01, -0.06), pc_port], Color("d4b850"))
	_cable("switch", [second_port, second_port + Vector3(-0.06, -0.01, -0.10), Vector3(8.44, 0.95, 3.72), Vector3(8.24, 1.05, 3.55), switch_visual.global_position + Vector3(-0.02, 0, 0.13)], Color("4e83c5"))
	_cable("charger", [CHARGER_POSITION + Vector3(-0.06, 0, 0), Vector3(8.83, 0.953, 5.46), power_port + Vector3(0, -0.01, 0.06), power_port], Color("202025"))
	var outlet := power_strip.global_position + Vector3(-0.07, 0.049, 0)
	_cable("charger_ac", [CHARGER_POSITION + Vector3(0.06, 0, 0), Vector3(9.18, 0.953, 5.32), Vector3(9.21, 0.953, 4.63), Vector3(9.17, 0.953, 4.27), outlet], Color("202025"))
	if is_instance_valid(racket_drop):
		racket_drop.visible = state.racket_available and not state.racket_collected
		racket_drop.get_node("InteractionBody").collision_layer = 2 if racket_drop.visible else 0
	if state.unlocked:
		for body: Node in closure.find_children("*", "CollisionObject3D", true, false): body.collision_layer = 0
		closure.get_parent().get_node("InteractionBody").collision_layer = 0
		if not _last_unlocked:
			_last_unlocked = true
			if not SaveManager.restoring:
				audio.play_at(&"unlock", closure.global_position, 0.0)
				_open_unlocked_exit.call_deferred()
	else:
		_last_unlocked = false
	closure.show()

func laptop_port(right: bool) -> Vector3:
	var pose := Transform3D(Basis(Vector3.UP, PI).scaled(Vector3.ONE * LAPTOP_SCALE), LAPTOP_POSITION) * _laptop_source_pose
	return pose * Vector3(0.075, 0.197 if right else -0.101, -0.044)

func _open_unlocked_exit() -> void:
	busy_visuals += 1
	if GameplayUI.modal == "terminal" and GameplayUI.terminal == alien_terminal:
		await GameplayUI.close_modal()
	if is_inside_tree():
		exit_door.open_door()
		busy_visuals -= 1

func click_alien_key(camera: Camera3D, mouse: Vector2) -> void:
	var inverse := closure.global_transform.affine_inverse()
	var origin := inverse * camera.project_ray_origin(mouse)
	var direction := inverse.basis * camera.project_ray_normal(mouse)
	if absf(direction.z) < 0.0001: return
	var distance := (0.110 - origin.z) / direction.z
	if distance < 0: return
	var point := origin + direction * distance
	for i in key_positions.size():
		if Vector2(point.x, point.y).distance_to(Vector2(key_positions[i].x, key_positions[i].y)) < 0.024:
			alien_terminal.press_symbol(i)
			return

func _boss_defeated() -> void:
	if state.racket_available or state.racket_collected: return
	var boss := scene.get_node("BrunoBuozzi")
	state.racket_available = true
	var original: Node3D = boss.racket_visual
	state.racket_position = original.global_position if is_instance_valid(original) else boss.global_position
	var hand_position: Vector3 = state.racket_position
	if is_instance_valid(original): original.hide()
	var query := PhysicsRayQueryParameters3D.create(state.racket_position + Vector3.UP, state.racket_position - Vector3.UP * 5, 1)
	query.exclude = [boss.get_rid(), scene.get_node("Player").get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	state.racket_position = hit.get("position", boss.global_position) + Vector3.UP * 0.08
	_spawn_racket()
	if not SaveManager.restoring:
		busy_visuals += 1
		var visual: Node3D = racket_drop.visual
		visual.global_position = hand_position
		var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(visual, "global_position", state.racket_position, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_callback(func(): busy_visuals -= 1)
	state.changed.emit()

func _spawn_racket() -> void:
	if is_instance_valid(racket_drop): return
	var visual := RACKET_SCENE.instantiate() as Node3D
	add_child(visual)
	visual.global_position = state.racket_position
	visual.remove_from_group("bruno_racket_target")
	_decorate_racket(visual)
	racket_drop = _make_interaction(visual, "racket", "RACCHETTA DI BRUNO")
	racket_drop.visible = not state.racket_collected

func _decorate_racket(visual: Node3D) -> void:
	for mesh: MeshInstance3D in integration._meshes(visual):
		if mesh.name == "Rychka":
			# Cylindrical UVs put the clue along one side of the handle, rather
			# than duplicating it across the original scattered UV islands.
			var arrays: Array = mesh.mesh.surface_get_arrays(0)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var box := mesh.get_aabb()
			var uv := PackedVector2Array()
			for vertex in vertices:
				uv.append(Vector2((vertex.x - box.position.x) / box.size.x, atan2(vertex.z, vertex.y) / TAU + 0.5))
			arrays[Mesh.ARRAY_TEX_UV] = uv
			var updated := ArrayMesh.new()
			updated.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
			var material := mesh.get_active_material(0).duplicate() as StandardMaterial3D
			material.albedo_texture = HANDLE_TEXTURE
			mesh.mesh = updated
			mesh.material_override = material

func _process(_delta: float) -> void:
	if state == null: return
	if state.racket_available:
		var boss := scene.get_node("BrunoBuozzi")
		if is_instance_valid(boss.racket_visual): boss.racket_visual.hide()

func _restore_finished() -> void:
	if state != null and integration.loot.defeated and not state.racket_available and not state.racket_collected:
		_boss_defeated()

func open_racket_inspection() -> void:
	if not InventoryManager.has_item(&"bruno_racket"): return
	var panel := INSPECTION.new()
	panel.puzzle = self
	if not GameplayUI.open_puzzle_panel(panel, true): panel.free()

func blocks_saving() -> bool:
	return busy_visuals > 0 or state.connecting_seconds > 0 or (is_instance_valid(exit_door) and exit_door.retreating)

func restore_priority() -> int:
	return 30

func get_persistent_state() -> Dictionary:
	state.light_regia = regia_switch.lights_on
	state.light_corridor = corridor_switch.lights_on
	return state.snapshot()

func apply_persistent_state(data: Dictionary) -> void:
	state.powered = power.is_power_on()
	state.restore(data)
	regia_switch.lights_on = state.light_regia and state.powered
	regia_switch._set_lights(regia_switch.lights_on)
	corridor_switch.lights_on = state.light_corridor and state.powered
	corridor_switch._set_lights(corridor_switch.lights_on)
	if state.racket_available:
		_spawn_racket()
	# Older checkpoints have no puzzle state. Recover a unique final drop.
	if integration.loot.defeated and not state.racket_available and not state.racket_collected:
		_boss_defeated()
	_refresh()
