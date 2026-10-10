extends CanvasLayer

const SKIN := preload("res://scripts/ui/inventory_skin.gd")
const BLOB_PANEL := preload("res://scripts/ui/blob_inventory_panel.gd")

var modal := ""
var terminal: Node3D
var _camera: Camera3D
var _player_camera: Camera3D
var _old_paused := false
var _visibility: Dictionary = {}
var _transitioning := false
var _release_fire := false
var _tween: Tween
var _inventory: PanelContainer
var _list: ItemList
var _description: Label
var _item_ids: Array[String] = []
var _notice: PanelContainer
var _notice_text: Label
var _notice_title: Label
var _notice_icon: TextureRect
var _notice_hint: Label
var _notice_tween: Tween
var _notice_active := false
var _canvas: Control
var _inventory_frame: Control
var _backdrop: ColorRect
var _item_title: Label
var _item_icon: TextureRect
var _count: Label
var _key_icon: Texture2D = SKIN.key_icon()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 90
	var canvas := Control.new()
	_canvas = canvas
	canvas.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(canvas)
	_backdrop = ColorRect.new()
	_backdrop.color = Color(0.012, 0.005, 0.024, 0.78)
	_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_backdrop.visible = false
	canvas.add_child(_backdrop)
	_inventory_frame = BLOB_PANEL.new()
	_inventory_frame.visible = false
	canvas.add_child(_inventory_frame)
	_inventory = PanelContainer.new()
	_inventory.size = Vector2(920, 680)
	_inventory.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	_inventory.add_theme_color_override("font_color", SKIN.PAPER)
	_inventory.visible = false
	canvas.add_child(_inventory)
	var margin := MarginContainer.new()
	for edge: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 34)
	_inventory.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	margin.add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	var title := Label.new()
	title.text = "INVENTARIO"
	title.add_theme_font_override("font", SKIN.font())
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", SKIN.PAPER)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	_count = Label.new()
	_count.add_theme_font_override("font", SKIN.font())
	_count.add_theme_font_size_override("font_size", 22)
	_count.add_theme_color_override("font_color", SKIN.GOLD)
	header.add_child(_count)
	var subtitle := Label.new()
	subtitle.text = "OGGETTI MISSIONE  /  PROJECT BLOB"
	subtitle.add_theme_font_size_override("font_size", 15)
	subtitle.add_theme_color_override("font_color", Color("9c85af"))
	column.add_child(subtitle)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 20)
	column.add_child(body)
	_list = ItemList.new()
	_list.custom_minimum_size = Vector2(325, 300)
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.fixed_icon_size = Vector2i(46, 46)
	_list.add_theme_font_override("font", SKIN.font())
	_list.add_theme_font_size_override("font_size", 25)
	_list.add_theme_color_override("font_color", SKIN.PAPER)
	_list.add_theme_color_override("font_selected_color", Color("f0d4ff"))
	_list.add_theme_constant_override("v_separation", 18)
	_list.add_theme_stylebox_override("panel", SKIN.plate(SKIN.INK, Color("472354")))
	_list.add_theme_stylebox_override("selected", SKIN.plate(SKIN.BLUE, SKIN.GOLD, 8))
	_list.add_theme_stylebox_override("selected_focus", SKIN.plate(SKIN.BLUE, SKIN.GOLD, 8))
	_list.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	body.add_child(_list)
	_list.item_selected.connect(_select_item)
	var dossier := PanelContainer.new()
	dossier.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dossier.add_theme_stylebox_override("panel", SKIN.detail_panel())
	body.add_child(dossier)
	var details := VBoxContainer.new()
	details.add_theme_constant_override("separation", 12)
	dossier.add_child(details)
	var tag := Label.new()
	tag.text = "OGGETTO MISSIONE"
	tag.add_theme_font_override("font", SKIN.font())
	tag.add_theme_font_size_override("font_size", 20)
	tag.add_theme_color_override("font_color", SKIN.GOLD)
	details.add_child(tag)
	_item_icon = TextureRect.new()
	_item_icon.custom_minimum_size.y = 96
	_item_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_item_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	details.add_child(_item_icon)
	_item_title = Label.new()
	_item_title.custom_minimum_size.x = 300
	_item_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_item_title.add_theme_font_override("font", SKIN.font())
	_item_title.add_theme_font_size_override("font_size", 32)
	_item_title.add_theme_color_override("font_color", SKIN.PAPER)
	details.add_child(_item_title)
	_description = Label.new()
	_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_description.custom_minimum_size = Vector2(300, 60)
	_description.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_description.add_theme_font_size_override("font_size", 20)
	_description.add_theme_color_override("font_color", Color("b9a7c7"))
	details.add_child(_description)
	var close := Button.new()
	close.text = "CHIUDI  [I / ESC]"
	SKIN.button(close)
	close.pressed.connect(close_modal)
	column.add_child(close)
	_build_notice(canvas)
	InventoryManager.inventory_changed.connect(_refresh_inventory)
	get_viewport().size_changed.connect(_layout)
	_inventory.resized.connect(_layout.call_deferred)
	_layout.call_deferred()

func _build_notice(canvas: Control) -> void:
	_notice = PanelContainer.new()
	_notice.custom_minimum_size = Vector2(550, 88)
	_notice.add_theme_stylebox_override("panel", SKIN.plate(SKIN.INK, SKIN.GOLD, 12))
	_notice.visible = false
	canvas.add_child(_notice)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	_notice.add_child(row)
	_notice_icon = TextureRect.new()
	_notice_icon.custom_minimum_size = Vector2(54, 54)
	_notice_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_notice_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(_notice_icon)
	var text := VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text)
	_notice_title = Label.new()
	_notice_title.add_theme_font_override("font", SKIN.font())
	_notice_title.add_theme_font_size_override("font_size", 19)
	_notice_title.add_theme_color_override("font_color", SKIN.GOLD)
	text.add_child(_notice_title)
	_notice_text = Label.new()
	_notice_text.custom_minimum_size.x = 260
	_notice_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_notice_text.add_theme_font_size_override("font_size", 20)
	_notice_text.add_theme_color_override("font_color", SKIN.PAPER)
	text.add_child(_notice_text)
	var hint := Label.new()
	_notice_hint = hint
	hint.text = "[I] INVENTARIO"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_override("font", SKIN.font())
	hint.add_theme_font_size_override("font_size", 17)
	hint.add_theme_color_override("font_color", SKIN.GOLD)
	row.add_child(hint)
	_ignore_mouse(_notice)

func _ignore_mouse(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child: Node in node.get_children():
		_ignore_mouse(child)

func _layout() -> void:
	_canvas.size = get_viewport().get_visible_rect().size
	_backdrop.size = _canvas.size
	_inventory.size = _inventory.get_combined_minimum_size().max(Vector2(920, 680))
	# Keep the whole dossier usable on smaller windows without changing game settings.
	_inventory.scale = Vector2.ONE * maxf(0.2, minf(1.0, minf((_canvas.size.x - 48) / _inventory.size.x, (_canvas.size.y - 180) / _inventory.size.y)))
	_inventory.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_inventory.position = (_canvas.size - _inventory.size * _inventory.scale) * 0.5
	_inventory_frame.position = _inventory.position
	_inventory_frame.size = _inventory.size
	_inventory_frame.scale = _inventory.scale
	_position_notice()

func _position_notice() -> void:
	var anchor := Vector2(_canvas.size.x * 0.5, _canvas.size.y - 140)
	for hud: Node in get_tree().get_nodes_in_group("hud"):
		var bar := hud.get_node_or_null("Interface/HudBar/HudBackground") as Control
		if bar != null:
			var rect := bar.get_global_rect()
			anchor = Vector2(rect.get_center().x, rect.position.y)
			break
	_notice.scale = Vector2.ONE * minf(1.0, (_canvas.size.x - 32) / maxf(_notice.size.x, 500))
	var extent := _notice.size * _notice.scale
	_notice.position = Vector2(clampf(anchor.x - extent.x * 0.5, 16, maxf(16, _canvas.size.x - extent.x - 16)), maxf(16, anchor.y - extent.y - 18))

func _process(_delta: float) -> void:
	if _release_fire and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_release_fire = false
	if _notice_active:
		_position_notice()
		var allowed := modal.is_empty() and not SaveManager.restoring and not get_tree().paused
		for hud: Node in get_tree().get_nodes_in_group("hud"):
			var interface := hud.get_node_or_null("Interface") as CanvasItem
			if interface != null:
				allowed = allowed and interface.is_visible_in_tree()
		_notice.visible = allowed

func input_blocked() -> bool:
	return not modal.is_empty() or _release_fire or SaveManager.restoring

func _input(event: InputEvent) -> void:
	if not modal.is_empty():
		if event.is_action_pressed("ui_cancel") or (modal == "inventory" and event.is_action_pressed("inventory")):
			close_modal()
			get_viewport().set_input_as_handled()
		elif modal == "terminal" and not _transitioning and is_instance_valid(terminal):
			terminal.call("handle_pointer", event, _camera)
		if modal == "terminal":
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("inventory") and not event.is_echo() and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if open_inventory():
			get_viewport().set_input_as_handled()

func _begin(kind: String) -> bool:
	var player := get_tree().get_first_node_in_group("player")
	if not modal.is_empty() or get_tree().paused or SaveManager.busy or player == null:
		return false
	if bool(player.get("is_dead")) or not player.is_physics_processing():
		return false
	modal = kind
	_old_paused = get_tree().paused
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	return true

func open_inventory() -> bool:
	if not _begin("inventory"):
		return false
	_refresh_inventory()
	_backdrop.visible = true
	_inventory_frame.visible = true
	_inventory.visible = true
	return true

func _refresh_inventory() -> void:
	if _list == null:
		return
	_list.clear()
	_item_ids.clear()
	for id: String in InventoryManager.items:
		var definition: Resource = InventoryManager.definitions[id]
		_item_ids.append(id)
		var icon: Texture2D = definition.icon
		if icon == null and id == "bruno_key":
			icon = _key_icon
		_list.add_item(definition.display_name + "  ×" + str(InventoryManager.items[id]), icon)
	_count.text = "01 OGGETTO" if _item_ids.size() == 1 else "%02d OGGETTI" % _item_ids.size()
	if _item_ids.is_empty():
		_item_icon.texture = null
		_item_title.text = "NESSUN OGGETTO"
		_description.text = "Non hai ancora raccolto oggetti."
	else:
		_list.select(0)
		_select_item(0)

func _select_item(index: int) -> void:
	if index >= 0 and index < _item_ids.size():
		var definition: Resource = InventoryManager.definitions[_item_ids[index]]
		_description.text = definition.description
		_item_title.text = definition.display_name
		_item_icon.texture = _list.get_item_icon(index)

func open_terminal(station: Node3D) -> bool:
	if not SaveManager.can_save():
		notify(SaveManager.last_error)
		return false
	if not _begin("terminal"):
		return false
	terminal = station
	_player_camera = get_viewport().get_camera_3d()
	for hud: Node in get_tree().get_nodes_in_group("hud"):
		var interface := hud.get_node_or_null("Interface")
		if interface is CanvasItem:
			_visibility[interface] = interface.visible
			interface.visible = false
	var player := get_tree().get_first_node_in_group("player")
	var weapon := player.get_node_or_null("Head/Camera3D/WeaponHolder")
	if weapon is Node3D:
		_visibility[weapon] = weapon.visible
		weapon.visible = false
	_camera = Camera3D.new()
	_camera.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().current_scene.add_child(_camera)
	_camera.global_transform = _player_camera.global_transform
	_camera.fov = _player_camera.fov
	_camera.current = true
	_transitioning = true
	station.call("set_terminal_active", true, false)
	_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.set_parallel(true)
	_tween.tween_property(_camera, "global_transform", station.call("camera_target"), 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(_camera, "fov", 40.0, 0.75)
	await _tween.finished
	if modal == "terminal" and is_instance_valid(terminal):
		_transitioning = false
		terminal.call("set_terminal_active", true, true)
	return true

func close_modal() -> void:
	if modal.is_empty() or _transitioning:
		return
	if modal == "terminal" and is_instance_valid(_camera) and is_instance_valid(_player_camera):
		_transitioning = true
		terminal.call("set_terminal_active", true, false)
		_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		_tween.set_parallel(true)
		_tween.tween_property(_camera, "global_transform", _player_camera.global_transform, 0.5)
		_tween.tween_property(_camera, "fov", _player_camera.fov, 0.5)
		await _tween.finished
	close_immediately()

func close_immediately() -> void:
	if modal.is_empty():
		return
	if _tween != null and _tween.is_running():
		_tween.kill()
	if is_instance_valid(terminal):
		terminal.call("set_terminal_active", false, false)
	if is_instance_valid(_player_camera):
		_player_camera.current = true
	if is_instance_valid(_camera):
		_camera.queue_free()
	_camera = null
	_player_camera = null
	for node: Node in _visibility:
		if is_instance_valid(node):
			node.set("visible", _visibility[node])
	_visibility.clear()
	_inventory.visible = false
	_inventory_frame.visible = false
	_backdrop.visible = false
	terminal = null
	modal = ""
	_transitioning = false
	_release_fire = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	get_tree().paused = _old_paused
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func clear_notice() -> void:
	if _notice_tween != null and _notice_tween.is_running():
		_notice_tween.kill()
	_notice_active = false
	_notice.visible = false

func notify(message: String, item_id: StringName = &"") -> void:
	clear_notice()
	_notice_title.text = "OGGETTO RACCOLTO" if not item_id.is_empty() else "AVVISO"
	_notice_text.text = message
	_notice_hint.visible = not item_id.is_empty()
	_notice_icon.texture = _key_icon if item_id == &"bruno_key" else null
	_notice_icon.visible = _notice_icon.texture != null
	_notice_active = true
	_notice.modulate.a = 0.0
	_position_notice()
	_notice_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_notice_tween.tween_property(_notice, "modulate:a", 1.0, 0.18)
	_notice_tween.tween_interval(3.2)
	_notice_tween.tween_property(_notice, "modulate:a", 0.0, 0.35)
	_notice_tween.tween_callback(func() -> void:
		_notice_active = false
		_notice.visible = false)
