extends SceneTree

const AUDIO := preload("res://scripts/systems/regia_audio.gd")
var failures := 0
var cues: Array[StringName] = []

class Station extends Node3D:
	var state: Node
	func click_alien_key(_camera: Camera3D, _point: Vector2) -> void:
		pass

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error("REGIA_AUDIO: " + message)

func run() -> void:
	var sfx_bus := AudioServer.get_bus_index(&"SFX")
	var effect_index := AudioServer.get_bus_effect_count(sfx_bus)
	var capture := AudioEffectCapture.new()
	AudioServer.add_bus_effect(sfx_bus, capture)
	for cue in AUDIO.FILES:
		var sound := AUDIO.stream(cue)
		var limit := 2.5 if cue == &"sliding" else 1.5
		check(sound != null and sound.get_length() > 0.02 and sound.get_length() < limit, "Invalid/long clip: " + str(cue))
	var station := Station.new()
	root.add_child(station)
	station.state = load("res://scripts/systems/regia_network_state.gd").new()
	station.add_child(station.state)
	station.state.laptop_placed = true
	station.state.laptop_on = true
	station.state.charger_connected = true
	station.state.powered = true
	var terminal = load("res://scripts/ui/regia_network_terminal.gd").new()
	terminal.puzzle = station
	station.add_child(terminal)
	terminal.set_terminal_active(true, true)
	terminal.audio.cue_played.connect(func(cue: StringName): cues.append(cue))
	var camera := Camera3D.new()
	station.add_child(camera)
	camera.global_transform = terminal.camera_target()
	camera.current = true
	await process_frame
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = camera.unproject_position(terminal.screen.global_position)
	terminal.handle_pointer(click, camera)
	check(cues == [&"mouse"], "On-screen mouse press did not play once")
	click.pressed = false
	terminal.handle_pointer(click, camera)
	check(cues.size() == 1, "Mouse release duplicated click")
	click.pressed = true
	click.position = Vector2(-10000, -10000)
	terminal.handle_pointer(click, camera)
	check(cues.size() == 1, "Off-screen mouse played")
	terminal.open_browser()
	await process_frame
	var key := InputEventKey.new()
	key.keycode = KEY_A
	key.unicode = 97
	key.pressed = true
	terminal.handle_pointer(key, camera)
	await process_frame
	check(cues.count(&"keyboard") == 1 and terminal.address.text == "a", "Real focused typing did not play/input")
	key.pressed = false
	terminal.handle_pointer(key, camera)
	terminal.address.text = "programmatic"
	check(cues.count(&"keyboard") == 1, "Release/programmatic text played typing")
	terminal.set_terminal_active(false, false)
	key.pressed = true
	terminal.handle_pointer(key, camera)
	check(cues.count(&"keyboard") == 1, "Inactive terminal played typing")
	var alien = load("res://scripts/ui/regia_network_terminal.gd").new()
	alien.kind = "alien"
	alien.puzzle = station
	station.add_child(alien)
	alien.audio.cue_played.connect(func(cue: StringName): cues.append(cue))
	alien.press_symbol(1)
	check(cues.count(&"button") == 1 and alien.wifi_flash > 0, "No-WiFi physical key must still beep")
	alien.press_symbol(-1)
	station.state.unlocked = true
	alien.press_symbol(1)
	check(cues.count(&"button") == 1, "Invalid/unlocked key played")
	var reader = load("res://scripts/ui/regia_book_reader.gd").new()
	reader.kind = "book"
	root.add_child(reader)
	reader.audio.cue_played.connect(func(cue: StringName): cues.append(cue))
	reader.turn_page(-1)
	check(cues.count(&"page") == 0, "Book boundary played")
	reader.turn_page(1)
	check(reader.turning and cues.count(&"page") == 1, "Page audio not synced to animation start")
	reader.turn_page(1)
	check(cues.count(&"page") == 1, "Busy page played twice")
	await create_timer(0.7).timeout
	check(reader.page_index == 1, "Page animation failed")
	var saves := root.get_node("SaveManager")
	saves.restoring = true
	reader.audio.play_ui(&"page")
	check(cues.count(&"page") == 1, "Restore replayed sound")
	saves.restoring = false
	capture.clear_buffer()
	for i in 12: terminal.audio.play_ui(&"keyboard")
	check(terminal.audio._players.size() <= 4, "Typing accumulated players")
	await create_timer(0.08).timeout
	var samples := capture.get_buffer(capture.get_frames_available())
	var peak := 0.0
	for sample in samples: peak = maxf(peak, maxf(absf(sample.x), absf(sample.y)))
	print("REGIA_AUDIO_PCM frames=", samples.size(), " peak=", peak)
	check(peak > 0.001, "MP3 cues did not produce actual audio samples on SFX")
	paused = true
	await process_frame
	await process_frame
	check(terminal.audio._players[0].stream_paused, "Pause did not suspend sound")
	paused = false
	await process_frame
	await process_frame
	check(not terminal.audio._players[0].stream_paused, "Resume did not resume sound")
	station.queue_free()
	reader.queue_free()
	await process_frame
	AudioServer.remove_bus_effect(sfx_bus, effect_index)
	print("REGIA_AUDIO_TEST failures=", failures)
	quit(0 if failures == 0 else 1)
