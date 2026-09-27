extends Area3D


@export var meteorite_audio: AudioStreamPlayer3D

@export var play_only_once: bool = true


var _already_played: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	if meteorite_audio == null:
		return

	if play_only_once and _already_played:
		return

	_already_played = true

	meteorite_audio.play()
