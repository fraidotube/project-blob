extends "res://scripts/interactables/persistent_interactable.gd"
class_name SavePCStation

# Reference: connesi.it theme CSS, read 2026-10-10. Original game UI.
const BRAND_GREEN := Color("2bb673")
const BRAND_BLUE := Color("25387b")
const BRAND_NAVY := Color("001f3f")

@export var generate_test_geometry := true
@export var screen_origin := Vector3(0, 1.3, 0)
@export var screen_size := Vector2(0.9, 0.50625)
@export var focus_marker: Marker3D
var viewport: SubViewport
var screen: MeshInstance3D
var save_button: Button
var exit_button: Button
var status_label: Label
var stamp_label: Label
var active := false
var _last_pointer := Vector2(-100, -100)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	interaction_name = "PC — CONNESIOS"
	if generate_test_geometry:
		_box(self, Vector3(1.0, 0.62, 0.12), screen_origin - Vector3(0, 0, 0.07), Color(0.055, 0.07, 0.09))
		_box(self, Vector3(0.12, 0.34, 0.12), Vector3(0, 0.86, -0.1), Color(0.08, 0.1, 0.13))
		_box(self, Vector3(1.7, 0.1, 0.7), Vector3(0, 0.75, 0.1), Color(0.22, 0.18, 0.13))
		_box(self, Vector3(0.55, 0.03, 0.18), Vector3(0, 0.83, 0.28), Color(0.13, 0.15, 0.17))
	_interaction_box(Vector3(1.05, 0.8, 0.3), screen_origin)
	viewport = SubViewport.new()
	viewport.size = Vector2i(1024, 576)
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.gui_disable_input = false
	add_child(viewport)
	_build_desktop()
	screen = MeshInstance3D.new()
	screen.name = "ConnesiScreen"
	screen.position = screen_origin + Vector3(0, 0, 0.005)
	var quad := QuadMesh.new()
	quad.size = screen_size
	screen.mesh = quad
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = viewport.get_texture()
	screen.material_override = material
	add_child(screen)
	super._ready()

func get_interaction_action() -> String:
	return "USA"

func interact(_player: Node) -> void:
	GameplayUI.open_terminal(self)

func camera_target() -> Transform3D:
	if focus_marker != null:
		return focus_marker.global_transform
	var aspect := float(get_viewport().get_visible_rect().size.x) / maxf(get_viewport().get_visible_rect().size.y, 1.0)
	var distance := maxf(screen_size.y, screen_size.x / aspect) * 1.15 / (2.0 * tan(deg_to_rad(20.0)))
	var origin := screen.global_position + screen.global_basis.z.normalized() * distance
	return Transform3D(Basis.IDENTITY, origin).looking_at(screen.global_position, global_basis.y.normalized())

func set_terminal_active(enabled: bool, ready_for_input: bool) -> void:
	active = enabled
	save_button.disabled = not ready_for_input
	exit_button.disabled = not ready_for_input
	_update_stamp()

func handle_pointer(event: InputEvent, camera: Camera3D) -> void:
	if not active:
		return
	if event is InputEventMouse:
		var inverse := screen.global_transform.affine_inverse()
		var ray_origin := inverse * camera.project_ray_origin(event.position)
		var ray_direction := inverse.basis * camera.project_ray_normal(event.position)
		var point := Vector2(-100, -100)
		if absf(ray_direction.z) > 0.0001:
			var distance := -ray_origin.z / ray_direction.z
			var hit := ray_origin + ray_direction * distance
			if distance >= 0 and absf(hit.x) <= screen_size.x * 0.5 and absf(hit.y) <= screen_size.y * 0.5:
				point = Vector2(hit.x / screen_size.x + 0.5, 0.5 - hit.y / screen_size.y) * Vector2(viewport.size)
		var forwarded := event.duplicate() as InputEventMouse
		forwarded.position = point
		forwarded.global_position = point
		if forwarded is InputEventMouseMotion:
			forwarded.relative = point - _last_pointer
		_last_pointer = point
		viewport.push_input(forwarded, true)
	elif event is InputEventKey:
		viewport.push_input(event.duplicate(), true)

func _build_desktop() -> void:
	var desktop := Control.new()
	desktop.size = Vector2(viewport.size)
	var theme := Theme.new()
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Segoe UI", "Arial"])
	theme.default_font = font
	theme.default_font_size = 18
	theme.set_color("font_color", "Label", BRAND_BLUE)
	desktop.theme = theme
	viewport.add_child(desktop)
	var wallpaper := ColorRect.new()
	wallpaper.color = Color("edf3f5")
	wallpaper.size = desktop.size
	wallpaper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desktop.add_child(wallpaper)
	var header := ColorRect.new()
	header.color = Color.WHITE
	header.size = Vector2(1024, 98)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desktop.add_child(header)
	var brand := Label.new()
	brand.text = "ConnesiOS"
	brand.position = Vector2(36, 8)
	brand.add_theme_font_size_override("font_size", 42)
	var bold := SystemFont.new()
	bold.font_names = font.font_names
	bold.font_weight = 700
	brand.add_theme_font_override("font", bold)
	desktop.add_child(brand)
	var caption := Label.new()
	caption.text = "POSTAZIONE REGIA  /  PROJECT BLOB"
	caption.position = Vector2(39, 65)
	caption.add_theme_font_size_override("font_size", 14)
	caption.add_theme_color_override("font_color", Color("617187"))
	desktop.add_child(caption)
	var connected := Label.new()
	connected.text = "●  SESSIONE LOCALE"
	connected.position = Vector2(776, 36)
	connected.add_theme_font_size_override("font_size", 17)
	connected.add_theme_color_override("font_color", Color("168050"))
	desktop.add_child(connected)
	var rail := ColorRect.new()
	rail.position = Vector2(0, 98)
	rail.size = Vector2(258, 436)
	rail.color = BRAND_BLUE
	rail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desktop.add_child(rail)
	var statement := Label.new()
	statement.text = "La tua\npartita.\nConnessa."
	statement.position = Vector2(30, 143)
	statement.add_theme_font_override("font", bold)
	statement.add_theme_font_size_override("font_size", 36)
	statement.add_theme_color_override("font_color", Color.WHITE)
	desktop.add_child(statement)
	var accent := ColorRect.new()
	accent.position = Vector2(34, 327)
	accent.size = Vector2(70, 5)
	accent.color = BRAND_GREEN
	accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desktop.add_child(accent)
	var reassuring := Label.new()
	reassuring.text = "Un punto sicuro\nper ripartire."
	reassuring.position = Vector2(34, 355)
	reassuring.add_theme_font_size_override("font_size", 20)
	reassuring.add_theme_color_override("font_color", Color("cad9eb"))
	desktop.add_child(reassuring)
	var window := PanelContainer.new()
	window.position = Vector2(289, 122)
	window.size = Vector2(700, 387)
	var style := StyleBoxFlat.new()
	style.bg_color = Color.WHITE
	style.border_color = Color("dce6ea")
	style.set_border_width_all(1)
	style.set_corner_radius_all(18)
	style.shadow_color = Color(0.0, 0.12, 0.25, 0.10)
	style.shadow_size = 8
	style.content_margin_left = 30
	style.content_margin_right = 30
	style.content_margin_top = 22
	style.content_margin_bottom = 22
	window.add_theme_stylebox_override("panel", style)
	desktop.add_child(window)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	window.add_child(column)
	var category := Label.new()
	category.text = "CONNESIOS  /  ARCHIVIO SESSIONE"
	category.add_theme_font_size_override("font_size", 14)
	category.add_theme_color_override("font_color", Color("168050"))
	column.add_child(category)
	var title := Label.new()
	title.text = "Riparti da qui."
	title.add_theme_font_override("font", bold)
	title.add_theme_font_size_override("font_size", 32)
	column.add_child(title)
	var explanation := Label.new()
	explanation.text = "Salva i tuoi progressi prima di tornare in azione.\nIl nuovo salvataggio sostituisce quello precedente."
	explanation.add_theme_font_size_override("font_size", 18)
	explanation.add_theme_color_override("font_color", Color("526276"))
	column.add_child(explanation)
	stamp_label = Label.new()
	stamp_label.add_theme_font_size_override("font_size", 16)
	stamp_label.add_theme_color_override("font_color", Color("526276"))
	column.add_child(stamp_label)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 14)
	column.add_child(actions)
	save_button = Button.new()
	save_button.text = "SALVA PARTITA"
	save_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_button.custom_minimum_size.y = 52
	_style_button(save_button, true)
	save_button.disabled = true
	save_button.pressed.connect(_save_pressed)
	actions.add_child(save_button)
	exit_button = Button.new()
	exit_button.text = "ESCI"
	exit_button.custom_minimum_size = Vector2(136, 52)
	_style_button(exit_button, false)
	exit_button.disabled = true
	exit_button.pressed.connect(GameplayUI.close_modal)
	actions.add_child(exit_button)
	status_label = Label.new()
	status_label.text = "Accedi alla postazione per salvare."
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.custom_minimum_size.y = 32
	status_label.add_theme_font_size_override("font_size", 17)
	column.add_child(status_label)
	var footer := ColorRect.new()
	footer.position.y = 534
	footer.size = Vector2(1024, 42)
	footer.color = BRAND_NAVY
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desktop.add_child(footer)
	var footer_text := Label.new()
	footer_text.text = "CONNESIOS  ·  REGIA                                     ESC  /  TORNA AL GIOCO"
	footer_text.position = Vector2(35, 544)
	footer_text.add_theme_font_size_override("font_size", 14)
	footer_text.add_theme_color_override("font_color", Color.WHITE)
	desktop.add_child(footer_text)
	_update_stamp()

func _style_button(button: Button, primary: bool) -> void:
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 20)
	for state: String in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := StyleBoxFlat.new()
		style.set_corner_radius_all(25)
		style.set_border_width_all(2)
		style.content_margin_left = 20
		style.content_margin_right = 20
		style.bg_color = BRAND_GREEN if primary else Color.WHITE
		style.border_color = BRAND_GREEN if primary else BRAND_BLUE
		if state == "hover":
			style.bg_color = Color("21985e") if primary else Color("e8eff8")
		elif state == "pressed":
			style.bg_color = Color("168050") if primary else Color("d3dff0")
		elif state == "disabled":
			style.bg_color = Color("e0e9e5")
			style.border_color = Color("c3d3cc")
		elif state == "focus":
			style.bg_color = Color.TRANSPARENT
			style.border_color = BRAND_NAVY
		button.add_theme_stylebox_override(state, style)
	for state: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		button.add_theme_color_override(state, Color.WHITE if primary else BRAND_BLUE)
	button.add_theme_color_override("font_disabled_color", Color("617187"))

func _update_stamp() -> void:
	var data := SaveManager.read_checkpoint()
	stamp_label.text = "Ultimo salvataggio: " + String(data.get("timestamp", "nessuno")).replace("T", " ")

func _save_pressed() -> void:
	if not active or save_button.disabled:
		return
	var success := SaveManager.save_checkpoint()
	status_label.text = "SALVATAGGIO COMPLETATO" if success else SaveManager.last_error
	status_label.add_theme_color_override("font_color", Color("168050") if success else Color("aa3a32"))
	_update_stamp()
