extends Area3D

@export_group("Cough")
@export var cough_sounds: Array[AudioStream] = []
@export_range(-40.0, 12.0, 0.5) var cough_volume_db: float = 0.0
@export_range(0.0, 10.0, 0.1) var first_cough_delay: float = 0.8
@export_range(0.5, 30.0, 0.1) var cough_interval_min: float = 3.0
@export_range(0.5, 30.0, 0.1) var cough_interval_max: float = 5.5

var _player_inside := false
var _cough_audio: AudioStreamPlayer
var _cough_timer: Timer


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	_cough_audio = AudioStreamPlayer.new()
	_cough_audio.name = "CoughAudio"
	_cough_audio.bus = &"Player"
	_cough_audio.volume_db = cough_volume_db
	add_child(_cough_audio)

	_cough_timer = Timer.new()
	_cough_timer.name = "CoughTimer"
	_cough_timer.one_shot = true
	_cough_timer.timeout.connect(_on_cough_timer_timeout)
	add_child(_cough_timer)

	call_deferred("_sync_initial_overlaps")


func _sync_initial_overlaps() -> void:
	for body: Node3D in get_overlapping_bodies():
		if body.is_in_group("player"):
			_enter_smoke()
			return


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_enter_smoke()


func _on_body_exited(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	_player_inside = false
	_cough_timer.stop()


func _enter_smoke() -> void:
	if _player_inside:
		return

	_player_inside = true

	if _get_valid_cough_sounds().is_empty():
		return

	_cough_timer.start(first_cough_delay)


func _on_cough_timer_timeout() -> void:
	if not _player_inside:
		return

	var valid_sounds := _get_valid_cough_sounds()

	if not valid_sounds.is_empty():
		_cough_audio.stop()
		_cough_audio.stream = valid_sounds.pick_random()
		_cough_audio.volume_db = cough_volume_db
		_cough_audio.play()

	var minimum := minf(cough_interval_min, cough_interval_max)
	var maximum := maxf(cough_interval_min, cough_interval_max)

	_cough_timer.start(
		randf_range(minimum, maximum)
	)


func _get_valid_cough_sounds() -> Array[AudioStream]:
	var valid: Array[AudioStream] = []

	for stream: AudioStream in cough_sounds:
		if stream != null:
			valid.append(stream)

	return valid
