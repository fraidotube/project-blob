extends Control

const GLYPHS := preload("res://scripts/ui/regia_alien_glyphs.gd")
const WIFI := preload("res://scripts/ui/regia_wifi_icon.gd")
const VISUALS := preload("res://scripts/ui/regia_item_visuals.gd")
const AUDIO := preload("res://scripts/systems/regia_audio.gd")
var audio: Node
var kind := "notes"
var source_texture: Texture2D
var viewport: SubViewport
var world: Node3D
var page_index := 0
var turning := false
var turn_pivot: Node3D
var pages: Array[SubViewport] = []
var page_roots: Array[Control] = []
var page_number: Label
var next_button: Button
var previous_button: Button
var wifi_visible := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	audio = AUDIO.new()
	add_child(audio)
	custom_minimum_size = Vector2(1440, 940)
	var column := VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(column)
	var title := Label.new()
	title.text = "APPUNTI" if kind == "notes" else "LIBRO ALIENO"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 25)
	column.add_child(title)
	var container := SubViewportContainer.new()
	container.custom_minimum_size = Vector2(1440, 840)
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.stretch = true
	container.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: turn_page(1)
			if event.button_index == MOUSE_BUTTON_WHEEL_UP: turn_page(-1)
	)
	column.add_child(container)
	viewport = SubViewport.new()
	viewport.size = Vector2i(1280, 800)
	viewport.own_world_3d = true
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	container.add_child(viewport)
	world = Node3D.new()
	viewport.add_child(world)
	for side in [-1.0, 1.0]:
		var cover := VISUALS.box(world, Vector3(0.63, 0.024, 0.9), Vector3(side * 0.31, -0.036, 0), Color("423027") if kind == "notes" else Color("562c20"))
		if source_texture != null and kind == "notes":
			var texture := AtlasTexture.new()
			texture.atlas = source_texture
			texture.region = Rect2(Vector2(source_texture.get_size()) * Vector2(0.025, 0.09), Vector2(source_texture.get_size()) * Vector2(0.60, 0.40))
			cover.material_override.albedo_texture = texture
		VISUALS.box(world, Vector3(0.59, 0.025, 0.85), Vector3(side * 0.3, -0.009, 0), Color("d7c9ad"))
		var page := SubViewport.new()
		page.size = Vector2i(640, 900)
		page.disable_3d = true
		page.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		add_child(page)
		pages.append(page)
		var root := Control.new()
		root.size = Vector2(640, 900)
		page.add_child(root)
		page_roots.append(root)
		var sheet := _sheet(side)
		var material := StandardMaterial3D.new()
		material.albedo_texture = page.get_texture()
		material.roughness = 1.0
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		sheet.material_override = material
		world.add_child(sheet)
	VISUALS.box(world, Vector3(0.022, 0.06, 0.87), Vector3(0, -0.02, 0), Color("483627"))
	turn_pivot = Node3D.new()
	world.add_child(turn_pivot)
	var turning_sheet := _sheet(1)
	var turning_material := StandardMaterial3D.new()
	turning_material.albedo_texture = pages[1].get_texture()
	turning_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	turning_sheet.material_override = turning_material
	turn_pivot.add_child(turning_sheet)
	turn_pivot.hide()
	var camera := Camera3D.new()
	camera.position = Vector3(0, 1.30, 0.35)
	camera.fov = 43
	world.add_child(camera)
	camera.look_at(Vector3(0, 0.01, 0))
	camera.current = true
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-60, -20, 0)
	light.light_energy = 1.1
	world.add_child(light)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-50, 150, 0)
	fill.light_energy = 0.55
	world.add_child(fill)
	var controls := HBoxContainer.new()
	controls.alignment = BoxContainer.ALIGNMENT_CENTER
	controls.add_theme_constant_override("separation", 20)
	column.add_child(controls)
	previous_button = _button(controls, "‹", func(): turn_page(-1))
	page_number = Label.new()
	page_number.custom_minimum_size = Vector2(90, 38)
	page_number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_child(page_number)
	next_button = _button(controls, "›", func(): turn_page(1))
	_button(controls, "CHIUDI [ESC]", GameplayUI.close_modal)
	_redraw_pages()

func _button(parent: Node, text: String, callback: Callable) -> Button:
	var result := Button.new()
	result.text = text
	result.custom_minimum_size = Vector2(90, 38)
	result.pressed.connect(callback)
	parent.add_child(result)
	return result

func _sheet(side: float) -> MeshInstance3D:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 24:
		var start := float(i) / 24
		var end := float(i + 1) / 24
		var triangle_uvs: Array[Vector2] = [Vector2(start, 0), Vector2(end, 0), Vector2(end, 1), Vector2(start, 0), Vector2(end, 1), Vector2(start, 1)]
		if side < 0:
			triangle_uvs = [Vector2(start, 0), Vector2(end, 1), Vector2(end, 0), Vector2(start, 0), Vector2(start, 1), Vector2(end, 1)]
		for uv in triangle_uvs:
			tool.set_uv(Vector2(uv.x if side > 0 else 1 - uv.x, uv.y))
			tool.set_normal(Vector3.UP)
			tool.add_vertex(Vector3(side * uv.x * 0.6, 0.035 * exp(-uv.x * 7.0) + 0.008, (uv.y - 0.5) * 0.84))
	var sheet := MeshInstance3D.new()
	sheet.mesh = tool.commit()
	return sheet

func _text(parent: Control, text: String, at: Vector2, font: Font, size: int, width: float = 510) -> Label:
	var label := Label.new()
	label.text = text
	label.position = at
	label.size.x = width
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color("30261b"))
	parent.add_child(label)
	return label

func _redraw_pages() -> void:
	wifi_visible = kind == "book" and page_index == 2
	for side in 2:
		var root := page_roots[side]
		for child in root.get_children():
			root.remove_child(child)
			child.queue_free()
		var paper := ColorRect.new()
		paper.size = root.size
		paper.color = Color("e9dec5") if kind == "notes" else Color("b69870")
		root.add_child(paper)
		if kind == "book" and source_texture != null:
			var atlas := AtlasTexture.new()
			atlas.atlas = source_texture
			atlas.region = Rect2(Vector2(source_texture.get_size()) * Vector2(0.22, 0.51), Vector2(source_texture.get_size()) * Vector2(0.14, 0.19))
			var texture := TextureRect.new()
			texture.texture = atlas
			texture.size = root.size
			texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			root.add_child(texture)
		if kind == "notes": _notes_page(root, side)
		else: _alien_page(root, side)
	page_number.text = "%d / %d" % [page_index + 1, 3 if kind == "book" else 1]
	previous_button.disabled = page_index == 0
	next_button.disabled = kind != "book" or page_index == 2

func _notes_page(root: Control, side: int) -> void:
	for y in range(100, 820, 38):
		var line := ColorRect.new()
		line.position = Vector2(38, y)
		line.size = Vector2(555, 1)
		line.color = Color(0.36, 0.47, 0.55, 0.18)
		root.add_child(line)
	var handwriting := SystemFont.new()
	handwriting.font_names = PackedStringArray(["Segoe Print", "Comic Sans MS"])
	handwriting.multichannel_signed_distance_field = true
	if side == 0:
		_text(root, "Appunti di laboratorio", Vector2(55, 38), handwriting, 31)
		_text(root, "Configurazione di rete\n\nVerificare alimentazione e\ncollegamenti.\n\nLa rete locale permette l'accesso\nai dispositivi. L'uplink collega la\npostazione alla rete aziendale.\n\nAnnotare le impostazioni e\nverificare le interfacce.", Vector2(58, 145), handwriting, 24)
		var pppoe := _text(root, "PPPoE\nnarcisolo / ottavonano", Vector2(48, 655), handwriting, 29)
		pppoe.rotation = -0.04
		pppoe.add_theme_color_override("font_color", Color("214d8a"))
	else:
		_text(root, "Controlli e manutenzione", Vector2(55, 38), handwriting, 28)
		_text(root, "Registrare le modifiche ai dispositivi prima di lasciare il laboratorio.\n\nControllare i connettori e conservare i parametri di accesso.\n\nNon dimenticare il registro degli interventi.", Vector2(58, 150), handwriting, 24)
		var login := _text(root, "admin / admin2026", Vector2(195, 680), handwriting, 28, 385)
		login.rotation = 0.035
		login.add_theme_color_override("font_color", Color("214d8a"))

func _alien_page(root: Control, side: int) -> void:
	var font := GLYPHS.font()
	var count := 11 if wifi_visible and side == 1 else 19
	for line in count:
		var text := ""
		for word in 4:
			for character in 3 + (line + word + page_index) % 3:
				text += GLYPHS.symbol((line * 5 + word * 3 + character + side * 7 + page_index * 4) % 12)
			text += "  "
		_text(root, text, Vector2(52, 63 + line * 37), font, 25, 545)
	if wifi_visible and side == 1:
		var wifi := WIFI.new()
		wifi.position = Vector2(210, 600)
		wifi.size = Vector2(200, 180)
		wifi.modulate = Color(0.1, 0.1, 0.1)
		root.add_child(wifi)

func turn_page(direction: int) -> void:
	if turning or kind != "book" or page_index + direction < 0 or page_index + direction > 2: return
	turning = true
	audio.play_ui(&"page", -3.0)
	turn_pivot.show()
	turn_pivot.rotation.z = 0 if direction > 0 else PI
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(turn_pivot, "rotation:z", PI if direction > 0 else 0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	page_index += direction
	turn_pivot.hide()
	turning = false
	_redraw_pages()
