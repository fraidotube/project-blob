extends Node3D

@export var power_system: Node
@export var video_player: VideoStreamPlayer
@export var video_surface: GeometryInstance3D
@export var audio_player: AudioStreamPlayer3D
@export var room_area: Area3D

@export var inside_volume_db := -14.0
@export var outside_volume_db := -80.0

var tv_on := false
var player_inside_room := false


func _ready() -> void:
	# SAFE fallback: se il riferimento non è stato assegnato nell'Inspector,
	# cerca automaticamente il TVVideoQuad figlio di Monitor Appeso.
	if video_surface == null:
		var auto_surface := get_node_or_null("TVVideoQuad")
		if auto_surface is GeometryInstance3D:
			video_surface = auto_surface as GeometryInstance3D

	if power_system:
		power_system.power_changed.connect(_on_power_changed)

	if room_area:
		room_area.body_entered.connect(_on_room_body_entered)
		room_area.body_exited.connect(_on_room_body_exited)

	if video_player:
		video_player.stop()

	_set_video_surface_visible(false)

	if audio_player:
		audio_player.stop()
		audio_player.volume_db = outside_volume_db


func toggle_tv() -> void:
	if power_system == null:
		return

	if not bool(power_system.is_power_on()):
		return

	if tv_on:
		turn_off_tv()
	else:
		turn_on_tv()


func turn_on_tv() -> void:
	if tv_on:
		return

	tv_on = true

	_set_video_surface_visible(true)

	if video_player:
		video_player.play()

	if audio_player:
		audio_player.play()
		_update_audio_volume()


func turn_off_tv() -> void:
	if not tv_on:
		# Anche se lo stato logico era già OFF, forziamo comunque
		# la superficie video a sparire.
		_set_video_surface_visible(false)

		if video_player:
			video_player.stop()

		if audio_player:
			audio_player.stop()

		return

	tv_on = false

	if video_player:
		video_player.stop()

	if audio_player:
		audio_player.stop()

	_set_video_surface_visible(false)


func _set_video_surface_visible(enabled: bool) -> void:
	if video_surface == null:
		return

	video_surface.visible = enabled


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
