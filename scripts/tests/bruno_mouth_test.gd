extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func key(scene: Node, code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	scene._unhandled_input(event)

func run() -> void:
	var buses := AudioServer.bus_count
	change_scene_to_file("res://scenes/levels/bruno_mouth_test.tscn")
	await process_frame
	await process_frame
	var scene = current_scene
	check(scene.head != null and scene.mouth.ready_for_motion, "Head/controller not ready")
	check(scene.head.transform == scene.original_head.transform, "Head transform changed")
	check(scene.bruno.get_script() == null, "Boss AI must be disabled in preview")
	check(AudioServer.bus_count == buses + 1, "Private capture bus missing")
	key(scene, KEY_M)
	await create_timer(0.2).timeout
	check(is_equal_approx(scene.head.get_blend_shape_value(0), 0.72), "Manual opening overwritten")
	key(scene, KEY_3)
	check(scene.head.get_blend_shape_value(1) > 0.6, "Round expression missing")
	key(scene, KEY_4)
	check(scene.head.get_blend_shape_value(2) > 0.8, "Smile expression missing")
	key(scene, KEY_M)
	check(scene.head.get_blend_shape_value(0) == 0.0, "Manual stop did not close")
	key(scene, KEY_A)
	check(scene.animation_player.current_animation == "mie/talking1", "Body animation missing")
	scene.restart_voice()
	var maximum := 0.0
	var rms_max := 0.0
	var active_frames := 0
	var silent_frames := 0
	var smile_max := 0.0
	var round_max := 0.0
	var start := Time.get_ticks_msec()
	while Time.get_ticks_msec() - start < 16500:
		await process_frame
		var value: float = scene.head.get_blend_shape_value(0)
		maximum = maxf(maximum, value)
		rms_max = maxf(rms_max, scene.mouth.voice_rms)
		round_max = maxf(round_max, scene.head.get_blend_shape_value(1))
		smile_max = maxf(smile_max, scene.head.get_blend_shape_value(2))
		if value > 0.02:
			active_frames += 1
		if scene.voice.playing and scene.mouth.voice_rms < 0.012:
			silent_frames += 1
	check(maximum > 0.02 and active_frames > 10, "Real dialogue did not move mouth")
	check(maximum <= 0.9721, "Opening exceeded laugh maximum")
	check(maximum > 0.45, "New motion is not wider than previous version")
	check(round_max > 0.1 and smile_max > 0.5, "Speech/laugh expressions did not run")
	check(silent_frames > 0, "No silence detected in dialogue")
	check(not scene.voice.playing and scene.head.get_blend_shape_value(0) == 0.0, "Excerpt did not stop/close")
	scene.restart_voice()
	await create_timer(1.0).timeout
	scene.voice.stream_paused = true
	await create_timer(1.5).timeout
	check(scene.head.get_blend_shape_value(0) < 0.001, "Paused voice did not close")
	scene.voice.stream_paused = false
	scene.stop_voice()
	key(scene, KEY_O)
	check(scene.original_head.visible and not scene.head.visible, "Original comparison failed")
	key(scene, KEY_O)
	key(scene, KEY_2)
	await process_frame
	if not DisplayServer.get_name() == "headless":
		key(scene, KEY_A)
		key(scene, KEY_M)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/bruno_mouth_runtime.png")
		key(scene, KEY_3)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/bruno_mouth_round.png")
		key(scene, KEY_3)
		key(scene, KEY_4)
		scene.head.set_blend_shape_value(0, 0.97)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/bruno_mouth_smile.png")
	print("BRUNO_MOUTH_METRICS max=", maximum, " round=", round_max, " smile=", smile_max, " rms=", rms_max, " active=", active_frames, " silent=", silent_frames)
	scene.queue_free()
	await process_frame
	await process_frame
	check(AudioServer.bus_count == buses, "Capture bus leaked after scene exit")
	print("BRUNO_MOUTH_TEST failures=", failures)
	quit(0 if failures == 0 else 1)
