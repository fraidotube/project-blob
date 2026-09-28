extends Node

const MENU_MUSIC := preload(
	"res://assets/audio/ProjectBlob - Soundtrack.mp3"
)

const REQUIRED_BUSES := [
	"Music",
	"SFX",
	"UI"
]

var music_player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_ensure_audio_buses()
	_create_music_player()
	play_menu_music()


func _ensure_audio_buses() -> void:
	for bus_name in REQUIRED_BUSES:
		if AudioServer.get_bus_index(bus_name) >= 0:
			continue

		AudioServer.add_bus()

		var index := AudioServer.bus_count - 1

		AudioServer.set_bus_name(
			index,
			bus_name
		)

		AudioServer.set_bus_send(
			index,
			"Master"
		)


func _create_music_player() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "MenuMusic"
	music_player.stream = MENU_MUSIC
	music_player.bus = &"Music"

	add_child(music_player)

	var mp3_stream := MENU_MUSIC as AudioStreamMP3

	if mp3_stream != null:
		mp3_stream.loop = true


func play_menu_music() -> void:
	if music_player == null:
		return

	if music_player.playing:
		return

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

	if music_player == null:
		_create_music_player()

	play_menu_music()
