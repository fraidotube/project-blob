extends PanelContainer

var puzzle: Node
var pivot: Node3D
var viewport: SubViewport
var camera: Camera3D
var dragging := false
var panning := false
var item_id := "bruno_racket"
const VISUALS := preload("res://scripts/ui/regia_item_visuals.gd")

func _ready() -> void:
	custom_minimum_size = Vector2(880, 620)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("100b1b")
	style.border_color = Color("b86cff")
	style.set_border_width_all(2)
	style.set_content_margin_all(20)
	add_theme_stylebox_override("panel", style)
	var column := VBoxContainer.new()
	add_child(column)
	var title := Label.new()
	title.text = String(InventoryManager.definitions[item_id].display_name).to_upper() + "  ·  ESAMINA"
	title.add_theme_font_size_override("font_size", 28)
	column.add_child(title)
	var container := SubViewportContainer.new()
	container.custom_minimum_size = Vector2(820, 460)
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.stretch = true
	container.gui_input.connect(_pointer)
	column.add_child(container)
	viewport = SubViewport.new()
	viewport.size = Vector2i(820, 460)
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	container.add_child(viewport)
	var world := Node3D.new()
	viewport.add_child(world)
	pivot = Node3D.new()
	world.add_child(pivot)
	var racket := VISUALS.make(item_id, puzzle)
	pivot.add_child(racket)
	var box: AABB = VISUALS.bounds(racket)
	var factor := 0.8 / maxf(box.size.x, maxf(box.size.y, box.size.z))
	racket.scale *= factor
	racket.position = -box.get_center() * factor
	pivot.rotation_degrees = Vector3(-45 if item_id == "bruno_racket" else 45, 0, 18)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -25, 0)
	light.light_energy = 2.5
	world.add_child(light)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(40, 155, 0)
	fill.light_energy = 1.1
	world.add_child(fill)
	camera = Camera3D.new()
	camera.position = Vector3(0, 0, 1.3)
	camera.fov = 42
	world.add_child(camera)
	camera.current = true
	var hint := Label.new()
	hint.text = "Sinistro: ruota · Destro: sposta · Rotella: zoom"
	hint.add_theme_font_size_override("font_size", 18)
	column.add_child(hint)
	var close := Button.new()
	close.text = "TORNA ALL'INVENTARIO [ESC]"
	close.custom_minimum_size.y = 40
	close.pressed.connect(GameplayUI.close_modal)
	column.add_child(close)

func _pointer(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			panning = event.pressed
		elif event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			camera.position.z = clampf(camera.position.z + (-0.1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 0.1), 0.4, 2.5)
	elif event is InputEventMouseMotion and dragging:
		pivot.rotation.y += event.relative.x * 0.009
		pivot.rotation.x += event.relative.y * 0.009
	elif event is InputEventMouseMotion and panning:
		camera.position.x = clampf(camera.position.x - event.relative.x * 0.0015, -0.65, 0.65)
		camera.position.y = clampf(camera.position.y + event.relative.y * 0.0015, -0.5, 0.5)
