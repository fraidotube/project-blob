extends Node3D

@export var power_system: Node
@export var video_player: VideoStreamPlayer
@export var audio_player: AudioStreamPlayer3D
@export var room_area: Area3D

@export var inside_volume_db := -14.0
@export var outside_volume_db := -80.0

var tv_on := false
var player_inside_room := false


func _ready() -> void:
	if power_system:
		power_system.power_changed.connect(_on_power_changed)

	if room_area:
		room_area.body_entered.connect(_on_room_body_entered)
		room_area.body_exited.connect(_on_room_body_exited)

	if video_player:
		video_player.stop()

	if audio_player:
		audio_player.stop()
		audio_player.volume_db = outside_volume_db


func toggle_tv() -> void:
	if power_system == null:
		return

	if not power_system.is_power_on():
		return

	if tv_on:
		turn_off_tv()
	else:
		turn_on_tv()


func turn_on_tv() -> void:
	if tv_on:
		return

	tv_on = true

	if video_player:
		video_player.play()

	if audio_player:
		audio_player.play()
		_update_audio_volume()


func turn_off_tv() -> void:
	if not tv_on:
		return

	tv_on = false

	if video_player:
		video_player.stop()

	if audio_player:
		audio_player.stop()


func _on_power_changed(is_on: bool) -> void:
	if not is_on:
		turn_off_tv()


func _on_room_body_entered(body: Node) -> void:
	if body.name != "Player":
		return

	player_inside_room = true
	_update_audio_volume()


func _on_room_body_exited(body: Node) -> void:
	if body.name != "Player":
		return

	player_inside_room = false
	_update_audio_volume()


func _update_audio_volume() -> void:
	if audio_player == null:
		return

	if player_inside_room:
		audio_player.volume_db = inside_volume_db
	else:
		audio_player.volume_db = outside_volume_db
		
