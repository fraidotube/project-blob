extends SceneTree

class StationOwner extends Node3D:
	var state: Node
	func click_alien_key(_camera: Camera3D, _position: Vector2) -> void:
		pass

var failures := 0
var terminal: Node3D
func _initialize() -> void:
	call_deferred("run")
func check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error("TERMINAL_RENDER: " + message)
func photo(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	terminal.viewport.get_texture().get_image().save_png("res://.godot/network_ui_" + name + ".png")
func click(control: Control) -> void:
	await process_frame
	check(control.get_global_rect().end.y <= terminal.viewport.size.y, "Control outside screen: " + control.name)
	var position := control.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = position
	terminal.viewport.push_input(motion, true)
	var event := InputEventMouseButton.new()
	event.position = position
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	terminal.viewport.push_input(event, true)
	event.pressed = false
	terminal.viewport.push_input(event, true)
	await process_frame
func run() -> void:
	var station := StationOwner.new()
	root.add_child(station)
	station.state = load("res://scripts/systems/regia_network_state.gd").new()
	station.add_child(station.state)
	station.state.laptop_collected = true
	station.state.laptop_placed = true
	station.state.laptop_on = true
	station.state.laptop_open = true
	station.state.charger_connected = true
	station.state.powered = true
	station.state.pc_link = true
	station.state.switch_link = true
	terminal = load("res://scripts/ui/regia_network_terminal.gd").new()
	terminal.puzzle = station
	station.add_child(terminal)
	terminal.set_terminal_active(true, true)
	await photo("desktop")
	await click(terminal.chrome_button)
	check(terminal.browser.visible, "Chrome click failed")
	terminal.navigate("192")
	await photo("login")
	var fields: Array[Node] = terminal.page.find_children("*", "LineEdit", true, false)
	fields[0].text = "admin"
	fields[1].text = "admin2026"
	await click(terminal.page.get_child(5))
	check(terminal.logged_in, "Login failed")
	fields = terminal.page.find_children("*", "LineEdit", true, false)
	fields[0].text = "narcisolo"
	fields[1].text = "ottavonano"
	await click(terminal.page.get_child(5))
	await create_timer(3.2).timeout
	check(station.state.online, "PPPoE submission failed")
	await photo("internet")
	await click(terminal.router_sidebar.get_child(4))
	var checks: Array[Node] = terminal.page.find_children("*", "CheckBox", true, false)
	check(checks.size() == 2, "WiFi navigation failed")
	if checks.size() == 2:
		await click(checks[0])
		await click(checks[1])
		await click(terminal.page.get_child(7))
		check(station.state.alien_connected(), "WiFi open network submission failed")
		check(terminal.page.position.y + terminal.page.get_combined_minimum_size().y <= 510, "WiFi feedback outside browser")
		await photo("wifi")
	var alien := load("res://scripts/ui/regia_network_terminal.gd").new() as Node3D
	alien.kind = "alien"
	alien.puzzle = station
	station.add_child(alien)
	terminal = alien
	await photo("alien")
	for i in 4: alien.press_symbol(0)
	check(not alien.alien_text.text.is_empty() and not alien.alien_text.text.contains("ERRATA"), "Alien error feedback contains Italian")
	var latin := RegEx.new()
	latin.compile("[A-Za-z]")
	for control in alien.desktop.find_children("*", "Control", true, false):
		if control is Label or control is Button:
			check(latin.search(control.text) == null, "Latin caption on alien display")
	print("REGIA_TERMINAL_RENDER_TEST failures=", failures)
	station.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
