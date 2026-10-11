extends Node3D

const GLYPHS := preload("res://scripts/ui/regia_alien_glyphs.gd")
const WIFI_ICON := preload("res://scripts/ui/regia_wifi_icon.gd")
const CHROME_ICON := preload("res://scripts/ui/regia_chrome_icon.gd")
const WALLPAPER := preload("res://scripts/ui/regia_windows_wallpaper.gd")
const DESKTOP_ICON := preload("res://scripts/ui/regia_desktop_icon.gd")
const AUDIO := preload("res://scripts/systems/regia_audio.gd")
var audio: Node
var puzzle: Node
var kind := "laptop"
var viewport: SubViewport
var screen: MeshInstance3D
var screen_size := Vector2(0.23, 0.15)
var active := false
var ready_for_input := false
var desktop: Control
var browser: Panel
var page: VBoxContainer
var address: LineEdit
var network_status: Label
var router_status: Label
var alien_text: Label
var wifi_flash := 0.0
var alien_feedback := ""
var feedback_seconds := 0.0
var logged_in := false
var last_pointer := Vector2(-100, -100)
var glyph_font: Font
var suggestion: Button
var alien_slots: Array[Label] = []
var wifi_icon: Control
var router_shell: Control
var router_sidebar: Panel
var router_feedback: Label
var chrome_button: Button
var start_menu: Panel
var start_button: Button
var shutdown_button: Button
var shutdown_feedback: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	audio = AUDIO.new()
	add_child(audio)
	glyph_font = GLYPHS.font()
	viewport = SubViewport.new()
	viewport.size = Vector2i(1920, 1080) if kind == "laptop" else Vector2i(1024, 576)
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	desktop = Control.new()
	desktop.size = Vector2(1024, 576)
	# Keep UI coordinates logical, render text and shapes at full HD.
	desktop.scale = Vector2(viewport.size) / desktop.size
	var theme := Theme.new()
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Segoe UI", "Arial"])
	font.multichannel_signed_distance_field = true
	theme.default_font = font
	theme.default_font_size = 20
	var input_style := StyleBoxFlat.new()
	input_style.bg_color = Color("ffffff")
	input_style.border_color = Color("c0c7ce")
	input_style.set_border_width_all(1)
	input_style.set_corner_radius_all(16)
	input_style.set_content_margin_all(8)
	theme.set_stylebox("normal", "LineEdit", input_style)
	theme.set_color("font_color", "LineEdit", Color("263b50"))
	for state_name: String in ["normal", "hover", "pressed"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("eef1f5") if state_name == "normal" else Color("dce5ed")
		style.set_corner_radius_all(4)
		theme.set_stylebox(state_name, "Button", style)
		theme.set_color("font_color" if state_name == "normal" else "font_" + state_name + "_color", "Button", Color("263b50"))
	desktop.theme = theme
	viewport.add_child(desktop)
	if kind == "laptop":
		_build_windows()
	else:
		_build_alien()
	screen = MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = screen_size
	screen.mesh = quad
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	material.albedo_texture = viewport.get_texture()
	material.emission_enabled = true
	material.emission_texture = viewport.get_texture()
	material.emission_energy_multiplier = 0.4
	screen.material_override = material
	add_child(screen)
	puzzle.state.changed.connect(refresh)
	refresh()

func camera_target() -> Transform3D:
	var center := screen.global_position
	if kind == "alien":
		center -= screen.global_basis.y * 0.16
	var distance := (1.00 if kind == "alien" else 0.36) * screen.global_basis.x.length()
	return Transform3D(Basis.IDENTITY, center + screen.global_basis.z.normalized() * distance).looking_at(center, screen.global_basis.y.normalized())

func requires_save_eligibility() -> bool:
	return false

func set_terminal_active(enabled: bool, input_ready: bool) -> void:
	active = enabled
	ready_for_input = input_ready
	if not enabled:
		if start_menu != null: start_menu.hide()
		logged_in = false
		if browser != null:
			browser.hide()
	refresh()

func _process(delta: float) -> void:
	if wifi_flash > 0:
		wifi_flash = maxf(0, wifi_flash - delta)
		refresh()
	if feedback_seconds > 0:
		feedback_seconds = maxf(0, feedback_seconds - delta)
		if feedback_seconds == 0:
			alien_feedback = ""
			refresh()

func handle_pointer(event: InputEvent, camera: Camera3D) -> void:
	if not active or not ready_for_input:
		return
	if kind == "alien" and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		puzzle.click_alien_key(camera, event.position)
	if event is InputEventMouse:
		var inverse := screen.global_transform.affine_inverse()
		var origin := inverse * camera.project_ray_origin(event.position)
		var direction := inverse.basis * camera.project_ray_normal(event.position)
		var point := Vector2(-100, -100)
		if absf(direction.z) > 0.0001:
			var distance := -origin.z / direction.z
			var hit := origin + direction * distance
			if distance >= 0 and absf(hit.x) <= screen_size.x / 2 and absf(hit.y) <= screen_size.y / 2:
				point = Vector2(hit.x / screen_size.x + 0.5, 0.5 - hit.y / screen_size.y) * Vector2(viewport.size)
		var forwarded := event.duplicate() as InputEventMouse
		forwarded.position = point
		forwarded.global_position = point
		if forwarded is InputEventMouseMotion:
			forwarded.relative = point - last_pointer
		last_pointer = point
		if kind == "laptop" and desktop.visible and point.x >= 0 and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			audio.play_ui(&"mouse")
		viewport.push_input(forwarded, true)
	elif event is InputEventKey:
		viewport.push_input(event.duplicate(), true)

func label(parent: Node, text: String, at: Vector2, font_size: int = 20, color: Color = Color.WHITE) -> Label:
	var result := Label.new()
	result.text = text
	result.position = at
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", color)
	parent.add_child(result)
	return result

func button(parent: Node, text: String, at: Vector2, size: Vector2, callback: Callable) -> Button:
	var result := Button.new()
	result.text = text
	result.position = at
	result.size = size
	result.pressed.connect(callback)
	parent.add_child(result)
	return result

func _build_windows() -> void:
	var wallpaper := WALLPAPER.new()
	wallpaper.size = desktop.size
	wallpaper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desktop.add_child(wallpaper)
	var computer := button(desktop, "\nQuesto PC", Vector2(12, 14), Vector2(92, 82), func(): show_browser_error("Documenti locali non disponibili."))
	var documents := button(desktop, "\nDocumenti", Vector2(12, 111), Vector2(92, 82), func(): show_browser_error("Nessun documento salvato."))
	for entry in [[computer, "computer"], [documents, "folder"]]:
		var desktop_icon := DESKTOP_ICON.new()
		desktop_icon.kind = entry[1]
		desktop_icon.position = Vector2(26, 3)
		desktop_icon.size = Vector2(40, 40)
		entry[0].add_child(desktop_icon)
	var chrome := button(desktop, "\nGoogle Chrome", Vector2(12, 208), Vector2(92, 82), open_browser)
	chrome_button = chrome
	for icon in [computer, documents, chrome]:
		icon.add_theme_font_size_override("font_size", 13)
		icon.add_theme_color_override("font_color", Color.WHITE)
		icon.add_theme_color_override("font_hover_color", Color.WHITE)
		icon.add_theme_color_override("font_pressed_color", Color.WHITE)
		icon.add_theme_color_override("font_outline_color", Color("061725"))
		icon.add_theme_constant_override("outline_size", 2)
		icon.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		var hover := StyleBoxFlat.new()
		hover.bg_color = Color(0.6, 0.8, 1.0, 0.18)
		hover.border_color = Color(0.7, 0.9, 1.0, 0.4)
		hover.set_border_width_all(1)
		icon.add_theme_stylebox_override("hover", hover)
		icon.add_theme_stylebox_override("pressed", hover)
	var chrome_icon := CHROME_ICON.new()
	chrome_icon.position = Vector2(29, 6)
	chrome_icon.size = Vector2(34, 34)
	chrome_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chrome.add_child(chrome_icon)
	var taskbar := ColorRect.new()
	taskbar.position.y = 531
	taskbar.size = Vector2(1024, 45)
	taskbar.color = Color("15191e")
	desktop.add_child(taskbar)
	start_button = button(desktop, "⊞", Vector2(0, 531), Vector2(48, 45), func(): start_menu.visible = not start_menu.visible)
	var search := ColorRect.new()
	search.position = Vector2(48, 531)
	search.size = Vector2(250, 45)
	search.color = Color("f2f2f2")
	desktop.add_child(search)
	label(desktop, "⌕   Scrivi qui per eseguire la ricerca", Vector2(59, 544), 13, Color("34383d"))
	label(desktop, "▣     ◇     ▤", Vector2(318, 543), 19)
	network_status = label(desktop, "", Vector2(817, 542), 13)
	browser = Panel.new()
	browser.position = Vector2(145, 22)
	browser.size = Vector2(850, 488)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("eef1f5")
	style.set_corner_radius_all(8)
	browser.add_theme_stylebox_override("panel", style)
	desktop.add_child(browser)
	label(browser, "Chrome  ·  Nuova scheda", Vector2(20, 8), 18, Color("283441"))
	button(browser, "×", Vector2(795, 0), Vector2(48, 32), browser.hide)
	address = LineEdit.new()
	address.position = Vector2(18, 43)
	address.size = Vector2(732, 37)
	address.placeholder_text = "Cerca o inserisci un indirizzo"
	address.text_submitted.connect(navigate)
	address.text_changed.connect(_autocomplete)
	address.gui_input.connect(_keyboard_input)
	browser.add_child(address)
	button(browser, "Vai", Vector2(760, 43), Vector2(68, 37), func(): navigate(address.text))
	suggestion = button(browser, "192.168.178.1 · Fritz locale", Vector2(22, 80), Vector2(360, 27), func(): navigate("192.168.178.1"))
	suggestion.add_theme_font_size_override("font_size", 15)
	suggestion.hide()
	page = VBoxContainer.new()
	page.position = Vector2(26, 112)
	page.size = Vector2(788, 355)
	page.add_theme_constant_override("separation", 9)
	browser.add_child(page)
	browser.hide()
	start_menu = Panel.new()
	start_menu.position = Vector2(0, 321)
	start_menu.size = Vector2(290, 210)
	var start_style := StyleBoxFlat.new()
	start_style.bg_color = Color("20262d")
	start_menu.add_theme_stylebox_override("panel", start_style)
	desktop.add_child(start_menu)
	label(start_menu, "Operatore", Vector2(18, 16), 21)
	shutdown_feedback = label(start_menu, "", Vector2(18, 63), 17)
	shutdown_feedback.size = Vector2(252, 72)
	shutdown_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	shutdown_button = button(start_menu, "⏻  Arresta il sistema", Vector2(18, 155), Vector2(252, 38), _shutdown)
	start_menu.hide()

func _shutdown() -> void:
	if not puzzle.state.shutdown_laptop():
		shutdown_feedback.text = puzzle.state.status
		return
	start_menu.hide()
	if GameplayUI.modal == "terminal" and GameplayUI.terminal == self:
		await GameplayUI.close_modal()
	else:
		set_terminal_active(false, false)

func _autocomplete(value: String) -> void:
	if value.length() >= 3 and value.length() < 13 and "192.168.178.1".begins_with(value):
		address.tooltip_text = "192.168.178.1 · Fritz locale"
		suggestion.show()
	else:
		address.tooltip_text = ""
		suggestion.hide()

func open_browser() -> void:
	browser.show()
	_clear_page()
	_page_label("Nuova scheda", 30)
	_page_label("Inserisci l'indirizzo del dispositivo da configurare.", 20)
	address.grab_focus()

func _clear_page() -> void:
	for child in page.get_children():
		page.remove_child(child)
		child.queue_free()
	router_status = null
	router_feedback = null
	page.add_theme_constant_override("separation", 9)
	page.position = Vector2(26, 112)
	page.size = Vector2(788, 355)
	if router_shell != null: router_shell.hide()

func _router_frame(with_sidebar: bool) -> void:
	if router_shell == null:
		router_shell = Control.new()
		router_shell.position = Vector2(18, 92)
		router_shell.size = Vector2(814, 382)
		router_shell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		browser.add_child(router_shell)
		browser.move_child(router_shell, page.get_index())
		var background := ColorRect.new()
		background.size = router_shell.size
		background.color = Color.WHITE
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		router_shell.add_child(background)
		var header := ColorRect.new()
		header.size = Vector2(814, 58)
		header.color = Color("0874c9")
		header.mouse_filter = Control.MOUSE_FILTER_IGNORE
		router_shell.add_child(header)
		var diamond := ColorRect.new()
		diamond.size = Vector2(35, 35)
		diamond.position = Vector2(35, 4)
		diamond.rotation = PI / 4
		diamond.color = Color("ffe600")
		diamond.mouse_filter = Control.MOUSE_FILTER_IGNORE
		router_shell.add_child(diamond)
		var logo := label(router_shell, "FRITZ!", Vector2(8, 11), 25, Color("ed2520"))
		logo.add_theme_color_override("font_outline_color", Color.BLACK)
		logo.add_theme_constant_override("outline_size", 2)
		label(router_shell, "FRITZ!Box  ·  Regia", Vector2(182, 13), 26)
		router_sidebar = Panel.new()
		router_sidebar.position = Vector2(0, 58)
		router_sidebar.size = Vector2(174, 324)
		var side_style := StyleBoxFlat.new()
		side_style.bg_color = Color("f5f6f7")
		side_style.border_color = Color("d7dce1")
		side_style.border_width_right = 1
		router_sidebar.add_theme_stylebox_override("panel", side_style)
		router_shell.add_child(router_sidebar)
		label(router_sidebar, "Panoramica", Vector2(16, 14), 18, Color("244158"))
		var internet := button(router_sidebar, "Internet", Vector2(8, 50), Vector2(158, 35), func(): _build_router("internet"))
		_router_button_style(internet)
		label(router_sidebar, "Telefonia", Vector2(16, 98), 18, Color("718496"))
		label(router_sidebar, "Rete locale", Vector2(16, 138), 18, Color("244158"))
		var wifi := button(router_sidebar, "Wi-Fi", Vector2(8, 178), Vector2(158, 35), func(): _build_router("wifi"))
		_router_button_style(wifi)
		label(router_sidebar, "Sistema", Vector2(16, 235), 18, Color("718496"))
	router_shell.show()
	page.add_theme_constant_override("separation", 5)
	router_sidebar.visible = with_sidebar
	page.position = Vector2(212, 159) if with_sidebar else Vector2(188, 163)
	page.size = Vector2(610, 305)

func _router_button_style(control: Button) -> void:
	control.add_theme_font_size_override("font_size", 18)
	for state_name: String in ["normal", "hover", "pressed"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("147acf") if state_name == "normal" else Color("075ca3")
		style.set_corner_radius_all(3)
		style.content_margin_top = 7
		style.content_margin_bottom = 7
		control.add_theme_stylebox_override(state_name, style)
	control.add_theme_color_override("font_color", Color.WHITE)
	control.add_theme_color_override("font_hover_color", Color.WHITE)

func _page_label(text: String, size: int = 20) -> Label:
	var result := label(page, text, Vector2.ZERO, size, Color("263b50"))
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return result

func show_browser_error(message: String) -> void:
	browser.show()
	_clear_page()
	_page_label("Impossibile raggiungere la pagina", 28)
	_page_label(message)

func navigate(url: String) -> void:
	suggestion.hide()
	var clean := url.strip_edges().trim_prefix("http://").trim_prefix("https://").trim_suffix("/")
	if clean.length() >= 3 and "192.168.178.1".begins_with(clean):
		clean = "192.168.178.1"
	address.text = clean
	if not puzzle.state.local_network():
		logged_in = false
		show_browser_error("Nessuna connessione locale. Controlla il cavo fra portatile e Fritz e l'alimentazione.")
		return
	if clean != "192.168.178.1":
		show_browser_error("Questo indirizzo non è raggiungibile dalla postazione. ERR_NAME_NOT_RESOLVED")
		return
	if logged_in:
		_build_router()
	else:
		_build_login()

func _field(caption: String, secret: bool = false) -> LineEdit:
	var row := HBoxContainer.new()
	page.add_child(row)
	var caption_label := label(row, caption, Vector2.ZERO, 18, Color("263b50"))
	caption_label.custom_minimum_size.x = 155
	var field := LineEdit.new()
	field.secret = secret
	field.gui_input.connect(_keyboard_input)
	field.custom_minimum_size = Vector2(360, 34)
	field.add_theme_font_size_override("font_size", 18)
	field.add_theme_color_override("font_color", Color("263b50"))
	var style := StyleBoxFlat.new()
	style.bg_color = Color.WHITE
	style.border_color = Color("83909a")
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.set_content_margin_all(6)
	field.add_theme_stylebox_override("normal", style)
	row.add_child(field)
	return field

func _keyboard_input(event: InputEvent) -> void:
	if not active or not ready_for_input or not desktop.visible: return
	if event is InputEventKey and event.pressed and not event.ctrl_pressed and not event.alt_pressed and not event.meta_pressed:
		if event.unicode >= 32 or event.keycode in [KEY_BACKSPACE, KEY_DELETE, KEY_ENTER, KEY_KP_ENTER]:
			audio.play_ui(&"keyboard", -7.0)

func _build_login() -> void:
	_clear_page()
	_router_frame(false)
	_page_label("Benvenuto  ·  Accesso locale", 23)
	_page_label("Accedi per modificare Internet e rete wireless.")
	var username := _field("Nome utente")
	var password := _field("Password", true)
	var feedback := _page_label("")
	var login := Button.new()
	login.text = "Accedi"
	login.custom_minimum_size.y = 38
	page.add_child(login)
	_router_button_style(login)
	login.pressed.connect(func():
		if not puzzle.state.local_network():
			navigate(address.text)
		elif username.text == "admin" and password.text == "admin2026":
			logged_in = true
			_build_router()
		else:
			feedback.text = "Nome utente o password non corretti."
	)

func _build_router(section: String = "internet") -> void:
	_clear_page()
	_router_frame(true)
	_page_label("Internet > Dati di accesso" if section == "internet" else "Wi-Fi > Rete wireless", 23)
	router_status = _page_label("")
	var tabs := HBoxContainer.new()
	page.add_child(tabs)
	for tab: String in ["internet", "wifi"]:
		var tab_button := Button.new()
		tab_button.text = "Internet · PPPoE" if tab == "internet" else "WiFi · Radio e sicurezza"
		tab_button.custom_minimum_size = Vector2(285, 30)
		_router_button_style(tab_button)
		tab_button.pressed.connect(func(): _build_router(tab))
		tabs.add_child(tab_button)
	if section == "wifi":
		_build_wifi()
		refresh()
		return
	var username := _field("PPPoE · utente")
	var password := _field("PPPoE · password", true)
	if puzzle.state.pppoe_valid:
		username.text = "narcisolo"
		password.text = "ottavonano"
	var submit := Button.new()
	submit.text = "Applica configurazione Internet"
	page.add_child(submit)
	_router_button_style(submit)
	var feedback := _page_label("", 16)
	router_feedback = feedback
	submit.pressed.connect(func():
		puzzle.state.configure_pppoe(username.text, password.text)
		feedback.text = puzzle.state.status
	)
	refresh()

func _build_wifi() -> void:
	_page_label("Nome rete: FRITZ!Box Regia", 18)
	var wifi := CheckBox.new()
	wifi.add_theme_font_size_override("font_size", 18)
	for color_name: String in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		wifi.add_theme_color_override(color_name, Color("263b50"))
	wifi.text = "Attiva radio WiFi"
	wifi.button_pressed = puzzle.state.wifi_enabled
	page.add_child(wifi)
	var protection := CheckBox.new()
	protection.add_theme_font_size_override("font_size", 18)
	for color_name: String in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color", "font_focus_color"]:
		protection.add_theme_color_override(color_name, Color("263b50"))
	protection.text = "Proteggi la rete con una password (WPA2)"
	protection.button_pressed = puzzle.state.wifi_protected
	page.add_child(protection)
	var wifi_password_field := _field("Password WiFi", true)
	wifi_password_field.text = puzzle.state.wifi_password
	var wifi_submit := Button.new()
	wifi_submit.text = "Applica WiFi"
	page.add_child(wifi_submit)
	_router_button_style(wifi_submit)
	var feedback := _page_label("", 16)
	wifi_submit.pressed.connect(func():
		if puzzle.state.configure_wifi(wifi.button_pressed, protection.button_pressed, wifi_password_field.text):
			feedback.text = "WiFi salvato · rete aperta." if not protection.button_pressed and wifi.button_pressed else "WiFi salvato."
	)

func _build_alien() -> void:
	var background := ColorRect.new()
	background.color = Color("08131f")
	background.size = desktop.size
	desktop.add_child(background)
	alien_text = label(desktop, "", Vector2(45, 65), 84, Color("88f4fa"))
	alien_text.size = Vector2(940, 300)
	alien_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	alien_text.add_theme_font_override("font", glyph_font)
	wifi_icon = WIFI_ICON.new()
	wifi_icon.position = Vector2(360, 75)
	wifi_icon.size = Vector2(300, 290)
	wifi_icon.hide()
	desktop.add_child(wifi_icon)
	for i in 4:
		var slot := label(desktop, "", Vector2(115 + i * 205, 130), 90, Color("88f4fa"))
		slot.size = Vector2(160, 180)
		slot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot.add_theme_font_override("font", glyph_font)
		alien_slots.append(slot)
	var connection_caption := label(desktop, GLYPHS.inscription([3, 6, 1, 8]), Vector2(75, 458), 33, Color("e6bbff"))
	connection_caption.add_theme_font_override("font", glyph_font)
	var opening_caption := label(desktop, GLYPHS.inscription([10, 5, 11, 0]), Vector2(690, 458), 33, Color("e6bbff"))
	opening_caption.add_theme_font_override("font", glyph_font)
	var reset := button(desktop, GLYPHS.inscription([8, 1, 6]), Vector2(10, 510), Vector2(150, 56), func():
		if not puzzle.state.unlocked: audio.play_at(&"button", global_position)
		puzzle.state.entered.clear()
		refresh()
	)
	reset.add_theme_font_override("font", glyph_font)
	for state_name: String in ["normal", "hover", "pressed"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("0c2836") if state_name == "normal" else Color("174657")
		style.border_color = Color("397781")
		style.set_border_width_all(1)
		reset.add_theme_stylebox_override(state_name, style)
	reset.add_theme_color_override("font_color", Color("88f4fa"))
	reset.add_theme_color_override("font_hover_color", Color("c2fbff"))
	reset.add_theme_color_override("font_pressed_color", Color("c2fbff"))

func press_symbol(index: int) -> void:
	if index < 0 or index >= 12 or puzzle.state.unlocked: return
	audio.play_at(&"button", global_position)
	var result: String = puzzle.state.press_symbol(index)
	if result == "NO_WIFI":
		wifi_flash = 2.0
	elif result in ["ERRATA", "APERTA"]:
		alien_feedback = result
		feedback_seconds = 1.5
	refresh()

func refresh() -> void:
	if desktop == null:
		return
	if kind == "laptop":
		desktop.visible = puzzle.state.laptop_on and puzzle.state.powered and puzzle.state.charger_connected
		network_status.text = ("▣" if puzzle.state.local_network() else "⊗") + "    ◖))    ITA    21:26"
		if browser.visible and not puzzle.state.local_network() and logged_in:
			logged_in = false
			show_browser_error("Connessione al Fritz interrotta. Controlla cavo e alimentazione.")
		if is_instance_valid(router_status):
			router_status.text = "● Online" if puzzle.state.online else ("◌ Connessione PPPoE in corso…" if puzzle.state.connecting_seconds > 0 else "● Offline · controlla PPPoE e uplink allo switch")
			router_status.add_theme_color_override("font_color", Color("168050") if puzzle.state.online else Color("aa3a32"))
		if is_instance_valid(router_feedback):
			router_feedback.text = "Connessione Internet operativa." if puzzle.state.online else puzzle.state.status
	else:
		wifi_icon.hide()
		for slot in alien_slots: slot.hide()
		if wifi_flash > 0:
			alien_text.text = ""
			wifi_icon.visible = int(wifi_flash * 6) % 2 == 0
		elif not alien_feedback.is_empty():
			alien_text.add_theme_font_override("font", glyph_font)
			alien_text.text = GLYPHS.inscription([11, 3, 8, 0]) if alien_feedback == "APERTA" else GLYPHS.inscription([5, 10, 1, 6])
		else:
			alien_text.text = ""
			for i in 4:
				var slot := alien_slots[i]
				slot.show()
				if not puzzle.state.alien_connected():
					slot.add_theme_font_override("font", glyph_font)
					slot.text = GLYPHS.symbol([0, 3, 6, 11][i])
				elif i < puzzle.state.entered.size():
					slot.add_theme_font_override("font", glyph_font)
					slot.text = GLYPHS.symbol(puzzle.state.entered[i])
				else:
					slot.add_theme_font_override("font", glyph_font)
					slot.text = "·"
