extends Node

const MENU_MUSIC := preload(
	"res://assets/audio/ProjectBlob - Soundtrack.mp3"
)

const BUS_DEFINITIONS := [
	{"name": "Music", "send": "Master", "base_db": 0.0},
	{"name": "SFX", "send": "Master", "base_db": 0.0},
	{"name": "Ambience", "send": "SFX", "base_db": 2.0},
	{"name": "Player", "send": "SFX", "base_db": -2.0},
	{"name": "Weapons", "send": "SFX", "base_db": 0.0},
	{"name": "UI", "send": "Master", "base_db": 0.0}
]

var music_player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_ensure_audio_buses()
	_configure_audio_routing()

	var settings := get_node_or_null(
		"/root/SettingsManager"
	)

	if settings != null:
		settings.load_settings()
		settings.apply_audio()

	_create_music_player()
	play_menu_music()

	get_tree().node_added.connect(
		_on_node_added
	)

	# La scena iniziale può essere già presente prima del connect.
	call_deferred(
		"route_current_scene_audio"
	)


func _ensure_audio_buses() -> void:
	for definition in BUS_DEFINITIONS:
		var bus_name: String = definition["name"]

		if AudioServer.get_bus_index(
			bus_name
		) >= 0:
			continue

		AudioServer.add_bus()

		var index := AudioServer.bus_count - 1
		AudioServer.set_bus_name(
			index,
			bus_name
		)


func _configure_audio_routing() -> void:
	for definition in BUS_DEFINITIONS:
		var bus_name: String = definition["name"]
		var send_name: String = definition["send"]
		var base_db: float = float(
			definition["base_db"]
		)

		var index := AudioServer.get_bus_index(
			bus_name
		)

		if index < 0:
			continue

		AudioServer.set_bus_send(
			index,
			send_name
		)

		if bus_name in [
			"Ambience",
			"Player",
			"Weapons"
		]:
			AudioServer.set_bus_volume_db(
				index,
				base_db
			)


func _create_music_player() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "MenuMusic"
	music_player.stream = MENU_MUSIC
	music_player.bus = &"Music"
	add_child(music_player)

	var mp3_stream := (
		MENU_MUSIC as AudioStreamMP3
	)

	if mp3_stream != null:
		mp3_stream.loop = true


func play_menu_music() -> void:
	if music_player == null:
		return

	if music_player.playing:
		return

	var settings := get_node_or_null(
		"/root/SettingsManager"
	)

	if settings != null:
		settings.load_settings()
		settings.apply_audio()

	music_player.volume_db = -18.0
	music_player.play()

	var tween := create_tween()
	tween.set_pause_mode(
		Tween.TWEEN_PAUSE_PROCESS
	)

	tween.tween_property(
		music_player,
		"volume_db",
		-8.0,
		2.0
	)


func fade_out_menu_music(
	duration: float = 0.65
) -> void:
	if music_player == null:
		return

	if not music_player.playing:
		return

	var tween := create_tween()
	tween.set_pause_mode(
		Tween.TWEEN_PAUSE_PROCESS
	)

	tween.tween_property(
		music_player,
		"volume_db",
		-60.0,
		duration
	)

	await tween.finished
	music_player.stop()


func ensure_menu_music() -> void:
	_ensure_audio_buses()
	_configure_audio_routing()

	var settings := get_node_or_null(
		"/root/SettingsManager"
	)

	if settings != null:
		settings.load_settings()
		settings.apply_audio()

	if music_player == null:
		_create_music_player()

	play_menu_music()


func route_current_scene_audio() -> void:
	var current := get_tree().current_scene

	if current == null:
		return

	_route_recursive(current)


func _on_node_added(
	node: Node
) -> void:
	if (
		node is AudioStreamPlayer
		or node is AudioStreamPlayer2D
		or node is AudioStreamPlayer3D
	):
		call_deferred(
			"_route_audio_node",
			node
		)


func _route_recursive(
	node: Node
) -> void:
	if (
		node is AudioStreamPlayer
		or node is AudioStreamPlayer2D
		or node is AudioStreamPlayer3D
	):
		_route_audio_node(node)

	for child in node.get_children():
		_route_recursive(child)


func _route_audio_node(
	node: Node
) -> void:
	if not is_instance_valid(node):
		return

	var node_name := node.name.to_lower()

	# Non tocchiamo il player musicale del menu.
	if node == music_player:
		return

	if (
		"footstep" in node_name
		or "jumpaudio" in node_name
		or "landaudio" in node_name
		or "playerstep" in node_name
	):
		node.set("bus", &"Player")
		return

	if (
		"shotaudio" in node_name
		or "reloadaudio" in node_name
		or "emptyaudio" in node_name
		or "readyaudio" in node_name
		or "shellcasing" in node_name
		or "flashlightclick" in node_name
		or "weapon" in node_name
		or "gun" in node_name
	):
		node.set("bus", &"Weapons")
		return

	if (
		"ambience" in node_name
		or "ambient" in node_name
	):
		node.set("bus", &"Ambience")
		return

	if (
		"uihover" in node_name
		or "uiclick" in node_name
		or "menuui" in node_name
	):
		node.set("bus", &"UI")
		return

	# Gli effetti mondo già esplicitamente su Master vengono
	# lasciati intatti per non spostare alla cieca il fuoco
	# o altri effetti che hai già bilanciato.


func debug_print_audio_routes() -> void:
	var current := get_tree().current_scene

	if current == null:
		return

	_print_recursive(current)


func _print_recursive(
	node: Node
) -> void:
	if (
		node is AudioStreamPlayer
		or node is AudioStreamPlayer2D
		or node is AudioStreamPlayer3D
	):
		print(
			"AUDIO ROUTE | ",
			node.get_path(),
			" -> ",
			node.get("bus"),
			" | volume_db=",
			node.get("volume_db")
		)

	for child in node.get_children():
		_print_recursive(child)
