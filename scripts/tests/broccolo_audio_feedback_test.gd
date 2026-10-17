extends SceneTree
var failures := 0
var capture: AudioEffectCapture
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func peak_after(seconds: float) -> float:
	await create_timer(seconds).timeout
	var samples := capture.get_buffer(capture.get_frames_available())
	var peak := 0.0
	for sample in samples: peak = maxf(peak, maxf(absf(sample.x), absf(sample.y)))
	return peak
func run() -> void:
	var world = load("res://scenes/levels/broccolo_combat_test.tscn").instantiate()
	world.auto_combat = false
	world.start_in_fps = false
	root.add_child(world)
	current_scene = world
	while not world.ready_for_test: await process_frame
	world.set_process(false)
	var actor = world.boss
	actor.set_physics_process(false)
	actor.animation.pause()
	world.study_camera.global_position = Vector3(0, 1.8, 4)
	world.study_camera.look_at(Vector3(0, 0.2, 0))
	var audio = actor.audio
	for stream in audio.exclamations + audio.copy_exclamations:
		check(stream.resource_path.ends_with("_mostro.mp3"), "Non-monster exclamation still configured")
	check(audio.hurt_streams.size() == 3, "Missing monster hurt variants")
	var sfx := AudioServer.get_bus_index(&"SFX")
	var prior_db := AudioServer.get_bus_volume_db(sfx)
	var prior_mute := AudioServer.is_bus_mute(sfx)
	AudioServer.set_bus_volume_db(sfx, 0)
	AudioServer.set_bus_mute(sfx, false)
	var effect_index := AudioServer.get_bus_effect_count(sfx)
	capture = AudioEffectCapture.new()
	capture.buffer_length = 1
	AudioServer.add_bus_effect(sfx, capture)
	# Allow 3D listener registration and the newly inserted audio capture to settle.
	await create_timer(0.25).timeout
	# Same footstep sample, listener and pitch: compare actual mixed PCM, not properties.
	audio.footsteps.stream = audio.footstep_stream.get_stream(0)
	audio.footsteps.pitch_scale = 1.7
	audio.footsteps.volume_db = -15
	audio.footsteps.unit_size = 3
	capture.clear_buffer()
	audio.footsteps.play()
	var old_peak := await peak_after(0.18)
	check(old_peak > 0.0001, "Baseline footstep did not reach audio capture")
	audio.footsteps.stop()
	await create_timer(0.08).timeout
	audio.footsteps.volume_db = audio.step_volume_db
	audio.footsteps.unit_size = audio.step_unit_size
	capture.clear_buffer()
	audio.footsteps.play()
	var new_peak := await peak_after(0.18)
	audio.footsteps.stop()
	check(new_peak > 0.005 and new_peak > old_peak * 3, "Footsteps not significantly louder at 4m")
	check(audio.footsteps.max_polyphony == 3, "Footstep tails still truncate")
	await create_timer(0.08).timeout
	var prior_hurt := -1
	for index in 3:
		actor.state = "show"
		actor.recovery = 0
		capture.clear_buffer()
		actor.take_damage(1)
		check(actor.state == "hurt" and audio.voice.playing, "Damage failed to play hurt voice immediately")
		check(audio.last_hurt != prior_hurt, "Repeated hurt variant")
		prior_hurt = audio.last_hurt
		check(audio.voice.stream.resource_path.contains("colpito") and audio.voice.pitch_scale == 1, "Wrong hurt voice or double monster pitch")
		var hurt_peak := await peak_after(0.18)
		check(hurt_peak > 0.001, "Hurt voice produced no PCM")
		var before: int = audio.hurts_played
		actor.take_damage(1)
		check(audio.hurts_played == before, "Protected hit replayed hurt voice")
		audio.stop_voice()
	# Final valid impact also produces a monster reaction before the death animation.
	actor.state = "show"
	actor.health = 1
	actor.recovery = 0
	var before: int = audio.hurts_played
	actor.take_damage(1)
	check(actor.state == "dead" and audio.hurts_played == before + 1 and audio.voice.playing, "Lethal hit was silent")
	print("BROCCOLO_AUDIO_FEEDBACK failures=", failures, " old_step_peak=", old_peak, " new_step_peak=", new_peak)
	audio.stop_voice()
	AudioServer.remove_bus_effect(sfx, effect_index)
	AudioServer.set_bus_volume_db(sfx, prior_db)
	AudioServer.set_bus_mute(sfx, prior_mute)
	world.queue_free()
	await process_frame
	await process_frame
	quit(0 if failures == 0 else 1)
