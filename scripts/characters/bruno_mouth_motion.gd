extends Node
class_name BrunoMouthMotion

@export var target_mesh: MeshInstance3D
@export var voice: Node
@export var blend_shape_name: StringName = &"mouth_open"
@export_range(0.0, 1.0, 0.01) var max_open := 0.72
@export_range(0.01, 1.0, 0.01) var attack_seconds := 0.05
@export_range(0.01, 1.0, 0.01) var release_seconds := 0.09
@export_range(0.001, 0.2, 0.001) var silence_threshold := 0.012
@export_range(0.1, 20.0, 0.1) var rms_gain := 6.0
var current_open := 0.0
var voice_rms := 0.0
var ready_for_motion := false
var _shape := -1
var _capture: AudioEffectCapture
var _bus_name: StringName
var _original_bus: StringName
var _without_frames := 0.0
var laughing := false
var expressive_speech := true
var current_round := 0.0
var current_smile := 0.0
var _round_shape := -1
var _smile_shape := -1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if target_mesh == null or voice == null or target_mesh.mesh == null:
		push_error("Bruno mouth: assign a head mesh and a voice player.")
		set_process(false)
		return
	_shape = target_mesh.find_blend_shape_by_name(blend_shape_name)
	_round_shape = target_mesh.find_blend_shape_by_name(&"mouth_round")
	_smile_shape = target_mesh.find_blend_shape_by_name(&"mouth_smile")
	if _shape < 0:
		push_error("Bruno mouth: missing blend shape " + String(blend_shape_name))
		set_process(false)
		return
	_original_bus = voice.bus
	_bus_name = StringName("BrunoMouthPreview_" + str(get_instance_id()))
	AudioServer.add_bus()
	var bus := AudioServer.bus_count - 1
	AudioServer.set_bus_name(bus, _bus_name)
	AudioServer.set_bus_send(bus, _original_bus if AudioServer.get_bus_index(_original_bus) >= 0 else &"Master")
	_capture = AudioEffectCapture.new()
	_capture.buffer_length = 0.2
	AudioServer.add_bus_effect(bus, _capture)
	voice.bus = _bus_name
	voice.finished.connect(reset_mouth)
	ready_for_motion = true
	reset_mouth()

func _process(delta: float) -> void:
	if not ready_for_motion or not is_instance_valid(target_mesh) or not is_instance_valid(voice):
		return
	var count := _capture.get_frames_available()
	if count > 0:
		var frames := _capture.get_buffer(count)
		var energy := 0.0
		for frame: Vector2 in frames:
			energy += frame.length_squared() * 0.5
		voice_rms = sqrt(energy / maxf(frames.size(), 1))
		_without_frames = 0.0
	else:
		_without_frames += delta
		if _without_frames > 0.05:
			voice_rms = 0.0
	var target := 0.0
	if voice.get("playing") and not voice.get("stream_paused") and not get_tree().paused:
		var activity := clampf((voice_rms - silence_threshold) * rms_gain, 0.0, 1.0)
		target = pow(activity, 0.72) * (minf(1.0, max_open * 1.35) if laughing else max_open)
	var duration := attack_seconds if target > current_open else release_seconds
	current_open = lerpf(current_open, target, 1.0 - exp(-delta / maxf(duration, 0.001)))
	if current_open < 0.0001:
		current_open = 0.0
	target_mesh.set_blend_shape_value(_shape, current_open)
	var audible: bool = voice.get("playing") and not voice.get("stream_paused") and not get_tree().paused and voice_rms > silence_threshold
	var round_target := 0.0
	var smile_target := 0.0
	# Keep the smile between the short voiced bursts of a laugh.
	if laughing and voice.get("playing") and not voice.get("stream_paused") and not get_tree().paused:
		smile_target = 0.85
	if audible:
		if laughing:
			smile_target = 0.85
		elif expressive_speech:
			# Stylized variation, not phoneme recognition. Playback time makes
			# replay deterministic; expressions fade out during pauses.
			var phase: float = voice.call("get_playback_position")
			round_target = maxf(0.0, sin(phase * 5.1) * sin(phase * 2.3 + 0.7)) * 0.65
			smile_target = maxf(0.0, sin(phase * 3.4 + 1.0)) * 0.22 * (1.0 - round_target)
	current_round = lerpf(current_round, round_target, 1.0 - exp(-delta / 0.10))
	current_smile = lerpf(current_smile, smile_target, 1.0 - exp(-delta / 0.12))
	if _round_shape >= 0:
		target_mesh.set_blend_shape_value(_round_shape, current_round)
	if _smile_shape >= 0:
		target_mesh.set_blend_shape_value(_smile_shape, current_smile)

func reset_mouth() -> void:
	current_open = 0.0
	voice_rms = 0.0
	_without_frames = 0.0
	current_round = 0.0
	current_smile = 0.0
	if _capture != null:
		_capture.clear_buffer()
	if is_instance_valid(target_mesh) and _shape >= 0:
		target_mesh.set_blend_shape_value(_shape, 0.0)
		if _round_shape >= 0:
			target_mesh.set_blend_shape_value(_round_shape, 0.0)
		if _smile_shape >= 0:
			target_mesh.set_blend_shape_value(_smile_shape, 0.0)

func bind_voice(next_voice: Node) -> void:
	if next_voice == voice:
		# Original controllers reassign their bus each time they play.
		voice.set("bus", _bus_name)
		return
	if is_instance_valid(voice):
		if voice.is_connected("finished", reset_mouth):
			voice.disconnect("finished", reset_mouth)
		if voice.get("bus") == _bus_name:
			voice.set("bus", _original_bus)
	voice = next_voice
	_original_bus = voice.get("bus")
	var bus := AudioServer.get_bus_index(_bus_name)
	AudioServer.set_bus_send(bus, _original_bus)
	voice.set("bus", _bus_name)
	voice.connect("finished", reset_mouth)
	reset_mouth()

func _exit_tree() -> void:
	if is_instance_valid(voice):
		if voice.finished.is_connected(reset_mouth):
			voice.finished.disconnect(reset_mouth)
		if voice.bus == _bus_name:
			voice.bus = _original_bus
	if not _bus_name.is_empty():
		var bus := AudioServer.get_bus_index(_bus_name)
		if bus >= 0:
			AudioServer.remove_bus(bus)
	if is_instance_valid(target_mesh) and _shape >= 0:
		target_mesh.set_blend_shape_value(_shape, 0.0)
