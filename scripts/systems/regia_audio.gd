extends Node

signal cue_played(cue: StringName)

const FILES := {
	&"button": "res://assets/audio/edificio/button_digital.mp3",
	&"unlock": "res://assets/audio/edificio/gameplay/door_unlock.mp3",
	&"open": "res://assets/audio/edificio/gameplay/door_open.mp3",
	&"close": "res://assets/audio/edificio/gameplay/door_close.mp3",
	&"mouse": "res://assets/audio/edificio/gameplay/mouse_click.mp3",
	&"keyboard": "res://assets/audio/edificio/gameplay/keyboard_click.mp3",
	&"cable": "res://assets/audio/edificio/gameplay/cable_connect.mp3",
	&"page": "res://assets/audio/edificio/gameplay/page_turn.mp3",
	&"sliding": "res://assets/audio/edificio/gameplay/sliding_motion.mp3",
}
static var _streams: Dictionary = {}
var _players: Array[Node] = []

static func stream(cue: StringName) -> AudioStreamMP3:
	if not _streams.has(cue):
		var path: String = FILES[cue]
		var sound: AudioStreamMP3
		if FileAccess.file_exists(path + ".import") or not FileAccess.file_exists(path):
			sound = load(path) as AudioStreamMP3
		else:
			# New local files can be used before the editor imports them.
			sound = AudioStreamMP3.new()
			sound.data = FileAccess.get_file_as_bytes(path)
		_streams[cue] = sound
	return _streams[cue]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func play_ui(cue: StringName, volume_db: float = -5.0) -> void:
	if get_node("/root/SaveManager").restoring: return
	var player := _available(false) as AudioStreamPlayer
	player.stream = stream(cue)
	player.volume_db = volume_db
	_start(player, cue)

func play_at(cue: StringName, position: Vector3, volume_db: float = -3.0) -> void:
	if get_node("/root/SaveManager").restoring: return
	var player := _available(true) as AudioStreamPlayer3D
	player.stream = stream(cue)
	player.volume_db = volume_db
	player.unit_size = 2.0
	player.max_distance = 12.0
	_start(player, cue, position)

func _start(player: Node, cue: StringName, position: Vector3 = Vector3.ZERO) -> void:
	if player is AudioStreamPlayer3D: player.global_position = position
	player.stream_paused = false
	player.play()
	cue_played.emit(cue)

func _available(spatial: bool) -> Node:
	var matching: Array[Node] = []
	for player in _players:
		if (player is AudioStreamPlayer3D) == spatial:
			matching.append(player)
			if not player.playing: return player
	if matching.size() >= 4:
		var oldest := matching[0]
		oldest.stop()
		_players.erase(oldest)
		_players.append(oldest)
		return oldest
	var player: Node = AudioStreamPlayer3D.new() if spatial else AudioStreamPlayer.new()
	player.bus = &"SFX"
	add_child(player)
	_players.append(player)
	return player

func _process(_delta: float) -> void:
	# Modal PC/book views intentionally pause the world but retain their audio.
	var suspended: bool = get_tree().paused and get_node("/root/GameplayUI").modal.is_empty()
	for player in _players:
		player.stream_paused = suspended
