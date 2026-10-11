extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("ANGELASTRI_MOUTH: " + message)

func key(scene: Node, code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	scene._unhandled_input(event)

func photo(name: String) -> void:
	await process_frame
	await process_frame
	if DisplayServer.get_name() == "headless": return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/angelastri_" + name + ".png")

func run() -> void:
	var buses := AudioServer.bus_count
	var fixture: Node = load("res://scenes/levels/angelastri_mouth_test.tscn").instantiate()
	var motion_only := OS.get_cmdline_user_args().has("--motion")
	var full_presentation := OS.get_cmdline_user_args().has("--presentation") or motion_only
	fixture.automatic_preview = full_presentation
	root.add_child(fixture)
	current_scene = fixture
	await process_frame
	await process_frame
	await process_frame
	var preview = current_scene
	if full_presentation:
		check(preview.presentation_stage == "intro" and preview.voice.playing, "Autoplay intro missing")
		if motion_only:
			var before: Array[Quaternion] = []
			for bone in preview.skeleton.get_bone_count(): before.append(preview.skeleton.get_bone_pose_rotation(bone))
			await create_timer(3.0).timeout
			var count := 0
			for bone in preview.skeleton.get_bone_count():
				if not before[bone].is_equal_approx(preview.skeleton.get_bone_pose_rotation(bone)): count += 1
			check(count > 5, "Live autoplay body remained frozen")
			preview.voice.seek(12.0)
			await create_timer(0.1).timeout
			check(preview.animation.assigned_animation == "mie/pointing", "Live intro pointing missing")
			await photo("live_pointing")
			print("ANGELASTRI_LIVE_BODY_TEST changed=", count, " failures=", failures)
			quit(0 if failures == 0 else 1)
			return
		var saw_dance := false
		var saw_second := false
		var saw_rest := false
		var saw_looking := false
		var presentation_start := Time.get_ticks_msec()
		var complete_duration: float = preview.voice.stream.get_length() + preview.dance_start_delay + preview.dance_duration() + 16.0
		var seen_clips: Dictionary = {}
		while Time.get_ticks_msec() - presentation_start < complete_duration * 1000.0:
			await process_frame
			if preview.presentation_stage == "dance": seen_clips[preview.animation.assigned_animation] = true
			saw_dance = saw_dance or preview.presentation_stage == "dance"
			saw_second = saw_second or preview.animation.assigned_animation == "mie/thrller_2"
			saw_rest = saw_rest or preview.presentation_stage == "rest"
			saw_looking = saw_looking or (preview.presentation_stage == "rest" and preview.animation.assigned_animation == "mie/looking")
		check(saw_dance and saw_second and saw_rest and saw_looking, "Autonomous complete sequence did not reach every stage")
		for dance in preview.DANCES: check(seen_clips.has(String(dance)), "Full presentation missed " + String(dance))
		await photo("automatic_rest")
		print("ANGELASTRI_AUTOMATIC_TEST failures=", failures)
		quit(0 if failures == 0 else 1)
		return
	preview.closeup = true
	check(preview.component.ready_for_mouth, "Component not ready")
	if not preview.component.ready_for_mouth:
		quit(1)
		return
	check(preview.head.mesh.get_blend_shape_count() == 3, "Missing expressions")
	check(preview.head.mesh.get_surface_count() == 3, "Missing skin/cavity/teeth surfaces")
	check(preview.head.transform.is_equal_approx(preview.original.transform), "Original head transform changed")
	check(preview.head.get_active_material(0) == preview.original.get_active_material(0), "Original exterior material changed")
	check(preview.head.get_blend_shape_value(0) == 0 and preview.head.get_blend_shape_value(1) == 0 and preview.head.get_blend_shape_value(2) == 0, "Initial pose not closed")
	check(preview.head.get_active_material(2).albedo_texture != null, "Teeth texture missing")
	check(AudioServer.bus_count == buses + 1, "Voice capture bus missing")
	await photo("closed_front")
	key(preview, KEY_M)
	await process_frame
	await process_frame
	check(is_equal_approx(preview.head.get_blend_shape_value(0), 0.72), "Manual opening failed")
	await photo("open_front")
	key(preview, KEY_2)
	await photo("open_quarter")
	key(preview, KEY_3)
	await photo("round")
	check(preview.head.get_blend_shape_value(1) > 0.6, "Rounded expression failed")
	key(preview, KEY_3)
	key(preview, KEY_4)
	await photo("smile")
	check(preview.head.get_blend_shape_value(2) > 0.8, "Smile expression failed")
	key(preview, KEY_M)
	check(preview.head.get_blend_shape_value(0) == 0, "Manual stop failed")
	key(preview, KEY_O)
	check(preview.original.visible and not preview.head.visible, "Original comparison failed")
	key(preview, KEY_O)
	var names: PackedStringArray = preview.animation.get_animation_list()
	check(preview.clip_names.size() >= 33 and names.has("mie/scream") and names.has("mie/talk_to_combat") and names.has("mie/thrller_4") and names.has("mie/talking_secret"), "Original and new animations not preserved")
	preview.animation.play(&"mie/talk_to_combat")
	key(preview, KEY_SPACE)
	var peak := 0.0
	var start := Time.get_ticks_msec()
	while Time.get_ticks_msec() - start < 6500:
		await process_frame
		peak = maxf(peak, preview.head.get_blend_shape_value(0))
	check(peak > 0.02 and peak <= 0.721, "Real Angelastri voice did not animate or exceeded max")
	preview.voice.stream_paused = true
	await create_timer(0.7).timeout
	check(preview.head.get_blend_shape_value(0) < 0.001, "Paused voice did not close")
	preview.voice.stream_paused = false
	paused = true
	await create_timer(0.7).timeout
	check(preview.head.get_blend_shape_value(0) < 0.001, "Tree pause did not close")
	paused = false
	preview.stop_voice()
	check(preview.head.get_blend_shape_value(0) == 0, "Stop did not close")
	check(preview.head.transform.is_equal_approx(preview.original.transform), "Animation changed local head transform")
	preview.audio_index = 3
	preview.start_sequence()
	check(preview.music.playing and not preview.voice.playing, "Music should not drive mouth")
	check(preview.music.stream.loop == (preview.dance_start_delay + preview.dance_duration() > preview.music.stream.get_length()) and not load(preview.AUDIO_ROOT + preview.AUDIO_FILES[3]).loop, "Music loop modified original or did not match track duration")
	preview.sync_sequence(0.5)
	check(preview.animation.assigned_animation == "mie/looking" and preview.music.playing, "Dance began during musical lead-in")
	preview.sync_sequence(preview.dance_start_delay + 0.5)
	check(preview.animation.assigned_animation == "mie/thrller_1", "First dance missing")
	var first: float = preview.animation.get_animation("mie/thrller_1").length
	preview.sync_sequence(preview.dance_start_delay + first + 0.5)
	check(preview.animation.assigned_animation == "mie/thrller_2" and absf(preview.animation.current_animation_position - 0.5) < 0.02, "Dance transition not aligned to audio clock")
	preview.closeup = false
	await photo("full_body_dance")
	preview.stop_sequence()
	preview.start_presentation()
	check(preview.presentation_stage == "intro" and preview.voice.playing and not preview.music.playing, "Full presentation did not start with voice")
	preview.advance_presentation()
	check(preview.presentation_stage == "dance" and preview.music.playing and not preview.voice.playing, "Intro did not hand over to uninterrupted music")
	preview.sync_sequence(preview.dance_start_delay + first + 0.5)
	check(preview.animation.assigned_animation == "mie/thrller_2", "Presentation second dance missing")
	var offset: float = preview.dance_start_delay
	for dance in preview.DANCES:
		preview.sync_sequence(offset + 0.5)
		check(preview.animation.assigned_animation == dance, "Dance order missing " + String(dance))
		offset += preview.animation.get_animation(dance).length
	var dance_end: float = preview.dance_start_delay + preview.dance_duration()
	print("ANGELASTRI_DANCE_DURATION ", dance_end, " music=", preview.music.stream.get_length())
	preview.sync_sequence(dance_end - 0.5)
	check(preview.music.volume_db < -5.0, "Final music fade missing")
	preview.sync_sequence(dance_end)
	check(preview.presentation_stage == "rest" and not preview.music.playing and preview.animation.assigned_animation == "mie/looking", "Dance did not finish in looking")
	await check_rest_blends(preview)
	await check_singing(preview, buses)
	preview.stop_sequence()
	check(not preview.music.playing and not preview.voice.playing, "Sequence stop failed")
	preview.audio_index = 1
	preview.voice.stream = load(preview.AUDIO_ROOT + preview.AUDIO_FILES[1])
	preview.start_sequence()
	preview.sync_sequence(21.5)
	check(preview.animation.assigned_animation == "mie/salute", "Draft phrase gesture missing")
	preview.stop_sequence()
	preview.audio_index = 3
	preview.sync_sequence(preview.dance_start_delay + 1.0)
	await process_frame
	var body_pose: Array[Quaternion] = []
	for bone in preview.skeleton.get_bone_count(): body_pose.append(preview.skeleton.get_bone_pose_rotation(bone))
	preview.sync_sequence(preview.dance_start_delay + 5.0)
	await process_frame
	var changed_bones := 0
	for bone in preview.skeleton.get_bone_count():
		if not body_pose[bone].is_equal_approx(preview.skeleton.get_bone_pose_rotation(bone)): changed_bones += 1
	print("ANGELASTRI_BODY_CHANGED_BONES ", changed_bones)
	check(changed_bones > 5, "Audio-clock animation changed time but did not move body bones")
	var dance_offset: float = preview.dance_start_delay
	for dance in preview.DANCES:
		preview.sync_sequence(dance_offset + 1.0)
		await photo("moving_" + String(dance).trim_prefix("mie/") + "_a")
		body_pose.clear()
		for bone in preview.skeleton.get_bone_count(): body_pose.append(preview.skeleton.get_bone_pose_rotation(bone))
		preview.sync_sequence(dance_offset + 5.0)
		await photo("moving_" + String(dance).trim_prefix("mie/") + "_b")
		changed_bones = 0
		for bone in preview.skeleton.get_bone_count():
			if not body_pose[bone].is_equal_approx(preview.skeleton.get_bone_pose_rotation(bone)): changed_bones += 1
		check(changed_bones > 5, "Body frozen in " + String(dance))
		print("ANGELASTRI_DANCE_BODY ", dance, " changed=", changed_bones)
		dance_offset += preview.animation.get_animation(dance).length
	preview.audio_index = 0
	preview.sync_sequence(11.5)
	check(preview.animation.assigned_animation != "mie/pointing", "Wall gesture still starts too early")
	preview.sync_sequence(preview.intro_pointing_time + 1.0)
	check(preview.animation.assigned_animation == "mie/pointing", "Wall phrase does not use pointing")
	await photo("intro_wall_pointing")
	preview.sync_sequence(15.0)
	check(preview.animation.assigned_animation == "mie/pointing", "Pointing lost in wall/meters/asphalt passage")
	preview.sync_sequence(preview.intro_pointing_time + preview.animation.get_animation("mie/pointing").length + 0.2)
	check(preview.animation.assigned_animation == "mie/pointing2", "Second indication should use pointing2")
	await photo("intro_second_pointing")
	for clip in preview.clip_names:
		preview.animation.play(clip)
		preview.animation.seek(preview.animation.get_animation(clip).length * 0.5, true)
		preview.animation.pause()
		await photo("clip_" + String(clip).trim_prefix("mie/"))
	print("ANGELASTRI_MOUTH_METRICS peak=", peak, " animations=", names.size())
	preview.queue_free()
	await process_frame
	await process_frame
	check(AudioServer.bus_count == buses, "Capture bus leaked")
	var official: Node = load("res://scenes/enemies/angelastri.tscn").instantiate()
	root.add_child(official)
	await process_frame
	await process_frame
	var mouth: Node = official.get_node("MouthPresentation")
	check(mouth.ready_for_mouth and mouth.motion == null, "Official scene requires a voice even for static mouth")
	check(AudioServer.bus_count == buses and mouth.head.get_blend_shape_value(0) == 0, "Official scene started audio/opened without voice")
	official.queue_free()
	await process_frame
	await process_frame
	print("ANGELASTRI_MOUTH_TEST failures=", failures)
	quit(0 if failures == 0 else 1)

func rotations(preview: Node) -> Array[Quaternion]:
	var values: Array[Quaternion] = []
	for bone in preview.skeleton.get_bone_count(): values.append(preview.skeleton.get_bone_pose_rotation(bone))
	return values

func max_pose_angle(preview: Node, before: Array[Quaternion]) -> float:
	var angle := 0.0
	for bone in preview.skeleton.get_bone_count():
		angle = maxf(angle, before[bone].angle_to(preview.skeleton.get_bone_pose_rotation(bone)))
	return angle

func check_rest_blends(preview: Node) -> void:
	preview.start_presentation()
	preview.advance_presentation()
	var end_time: float = preview.dance_start_delay + preview.dance_duration()
	preview.sync_sequence(end_time - 0.01)
	preview.animation.advance(0.0)
	var before := rotations(preview)
	preview.sync_sequence(end_time)
	preview.animation.advance(0.0)
	var switch_angle := max_pose_angle(preview, before)
	check(switch_angle < 0.03, "Dance to looking jumps at the start of the blend")
	check(preview.animation.is_playing(), "Looking should play continuously for blending")
	await create_timer(0.3).timeout
	check(max_pose_angle(preview, before) > 0.005, "Looking blend remains frozen")
	await photo("rest_blend_to_looking")
	preview.toggle_presentation_pause()
	var position: float = preview.animation.current_animation_position
	await create_timer(0.2).timeout
	check(is_equal_approx(position, preview.animation.current_animation_position), "Rest animation advances during pause")
	preview.toggle_presentation_pause()
	await create_timer(0.7).timeout
	check(preview.animation.current_animation_position > position, "Looking did not resume")
	preview.animation.advance(preview.animation.get_animation("mie/looking").length + 0.5)
	check(preview.animation.is_playing() and preview.animation.assigned_animation == "mie/looking", "Looking did not loop or fell back to combat idle")
	await photo("rest_looking_loop")
	print("ANGELASTRI_REST_BLEND start_angle=", switch_angle)

func check_singing(preview: Node, buses: int) -> void:
	preview.start_presentation()
	preview.advance_presentation()
	preview.music.seek(preview.singing_start_seconds - 1.0)
	await create_timer(0.3).timeout
	check(preview.component.voice == preview.voice and preview.head.get_blend_shape_value(0) < 0.001, "Mouth opens before user-supplied singing cue")
	preview.music.seek(preview.singing_start_seconds + 0.2)
	var peak := 0.0
	var minimum := 1.0
	var closures := 0
	var previously_closed := false
	var start := Time.get_ticks_msec()
	while Time.get_ticks_msec() - start < 2200:
		await process_frame
		var value: float = preview.head.get_blend_shape_value(0)
		peak = maxf(peak, value)
		if Time.get_ticks_msec() - start > 300:
			minimum = minf(minimum, value)
			var closed := value < 0.06
			if closed and not previously_closed: closures += 1
			previously_closed = closed
	check(preview.component.voice == preview.music and peak > 0.02, "Song audio did not drive mouth after singing cue")
	check(peak - minimum > 0.15 and minimum < 0.06 and closures >= 3, "Singing mouth stays open instead of articulating")
	check(preview.voice.bus == &"SFX" and preview.music.bus != &"Music" and AudioServer.bus_count == buses + 1, "Song capture changed voice bus or created additional buses")
	var capture := AudioServer.get_bus_index(preview.music.bus)
	check(AudioServer.get_bus_send(capture) == &"Music", "Singing lost Music routing")
	await photo("singing")
	preview.toggle_presentation_pause()
	await create_timer(0.7).timeout
	check(preview.head.get_blend_shape_value(0) < 0.001, "Singing mouth did not close on pause")
	preview.toggle_presentation_pause()
	preview.sync_sequence(preview.dance_start_delay + preview.dance_duration())
	check(preview.component.voice == preview.voice and preview.music.bus == &"Music" and preview.head.get_blend_shape_value(0) == 0, "End of song did not restore routing/close mouth")
	preview.start_presentation()
	check(preview.component.voice == preview.voice and preview.voice.playing and not preview.music.playing, "Replay did not restore intro mouth")
	preview.stop_sequence()
	print("ANGELASTRI_SINGING_TEST cue=", preview.singing_start_seconds, " peak=", peak, " minimum=", minimum, " closures=", closures)
