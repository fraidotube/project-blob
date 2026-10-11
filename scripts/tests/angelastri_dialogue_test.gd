extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("ANGELASTRI_DIALOGUE: " + message)

func run() -> void:
	var buses := AudioServer.bus_count
	var inspect_only := OS.get_cmdline_user_args().has("--inspect-talk")
	var fixture: Node = load("res://scenes/levels/angelastri_dialogue_test.tscn").instantiate()
	fixture.automatic_preview = not inspect_only
	root.add_child(fixture)
	current_scene = fixture
	await process_frame
	await process_frame
	await process_frame
	var preview: Node = current_scene
	check(preview.animation.get_animation("mie/talking") != load("res://assets/models/enemies/Angelastri/Animation/talking.res"), "Stationary dialogue modified a shared original animation")
	if inspect_only:
		for clip in ["talking", "talking2", "talking3", "talking_secret", "idle_new", "idle_new_breathing"]:
			var name: String = "mie/" + clip
			check(preview.animation.has_animation(name), "Missing " + name)
			var length: float = preview.animation.get_animation(name).length
			print("ANGELASTRI_TALK_CLIP ", clip, " duration=", length)
			for sample in [0.25, 0.65]:
				preview.animation.play(name, 0.0)
				preview.animation.seek(length * sample, true)
				preview.animation.pause()
				await process_frame
				await process_frame
				if DisplayServer.get_name() != "headless":
					await RenderingServer.frame_post_draw
					root.get_texture().get_image().save_png("res://.godot/angelastri_" + clip + "_" + str(int(sample * 100)) + ".png")
		print("ANGELASTRI_TALK_INSPECT failures=", failures)
		quit(0 if failures == 0 else 1)
		return
	check(preview.presentation_stage == "main_dialogue" and preview.voice.playing and not preview.music.playing, "Main dialogue did not autoplay alone")
	check(preview.voice.stream.resource_path.ends_with("Angelastri_discorso_principale_vampire.mp3"), "Wrong voice")
	var duration: float = preview.voice.stream.get_length()
	var seen: Dictionary = {}
	var peak := 0.0
	var paused_once := false
	var initial_pose: Array[Quaternion] = []
	for bone in preview.skeleton.get_bone_count(): initial_pose.append(preview.skeleton.get_bone_pose_rotation(bone))
	var changed := false
	var previous_pose: Array[Quaternion] = initial_pose.duplicate()
	var root_anchor: Vector3 = preview.skeleton.get_bone_pose_position(0)
	var maximum_jump := 0.0
	var maximum_drift := 0.0
	var previous_clip: String = preview.animation.assigned_animation
	var previous_position: float = preview.animation.current_animation_position
	var previous_stage: String = preview.presentation_stage
	var previous_ticks := Time.get_ticks_msec()
	var stages: Dictionary = {}
	var combat_events := [0]
	var completed_clip := [""]
	preview.animation.animation_finished.connect(func(name: StringName): completed_clip[0] = String(name))
	preview.combat_preview_ready.connect(func(): combat_events[0] += 1)
	var start := Time.get_ticks_msec()
	var total_duration: float = duration + preview.animation.get_animation("mie/idle_new").length + preview.animation.get_animation("mie/talk_to_combat").length + 3.0
	while Time.get_ticks_msec() - start < total_duration * 1000.0:
		await process_frame
		var elapsed := maxf(float(Time.get_ticks_msec() - previous_ticks) / 1000.0, 0.001)
		previous_ticks = Time.get_ticks_msec()
		stages[preview.presentation_stage] = true
		var current_clip: String = preview.animation.assigned_animation
		if previous_clip != current_clip and previous_stage == "main_dialogue" and preview.presentation_stage == "main_dialogue":
			check(completed_clip[0] == previous_clip or previous_position >= preview.animation.get_animation(previous_clip).length - 0.12, "Gesture cut before completion: " + previous_clip)
			completed_clip[0] = ""
		var root_position: Vector3 = preview.skeleton.get_bone_pose_position(0)
		maximum_drift = maxf(maximum_drift, Vector2(root_position.x - root_anchor.x, root_position.z - root_anchor.z).length())
		for bone in preview.skeleton.get_bone_count():
			var rotation: Quaternion = preview.skeleton.get_bone_pose_rotation(bone)
			var angle := previous_pose[bone].angle_to(rotation)
			if angle > 0.35: print("ANGELASTRI_LIVE_JUMP dt=", elapsed, " stage=", preview.presentation_stage, " clip=", current_clip, " bone=", bone, " angle=", angle)
			maximum_jump = maxf(maximum_jump, angle)
			previous_pose[bone] = rotation
		previous_clip = current_clip
		previous_position = preview.animation.current_animation_position
		previous_stage = preview.presentation_stage
		if preview.presentation_stage == "main_dialogue":
			seen[preview.animation.assigned_animation] = true
			peak = maxf(peak, preview.head.get_blend_shape_value(0))
			if preview.animation.assigned_animation == "mie/talking_secret" and preview.voice.playing:
				var position: float = preview.voice.get_playback_position()
				check(position >= preview.main_secret_start - 0.1 and position < preview.main_secret_end + 0.1, "Secret used outside whispered ending")
			for bone in preview.skeleton.get_bone_count():
				changed = changed or not initial_pose[bone].is_equal_approx(preview.skeleton.get_bone_pose_rotation(bone))
			if not paused_once and preview.voice.get_playback_position() > 3.0:
				preview.toggle_presentation_pause()
				var time: float = preview.voice.get_playback_position()
				await create_timer(0.7).timeout
				check(absf(preview.voice.get_playback_position() - time) < 0.1 and preview.head.get_blend_shape_value(0) < 0.001, "Dialogue pause did not freeze audio/close mouth")
				preview.toggle_presentation_pause()
				paused_once = true
		check(not preview.music.playing and preview.animation.assigned_animation != "mie/idle", "Main preview started music or combat idle")
	check(changed and peak > 0.02, "Body or mouth did not animate")
	for cue: Array in preview.draft_cues[1]:
		check(seen.has("mie/" + String(cue[1])), "Gesture not observed: " + String(cue[1]))
	for clip in ["talking", "talking2", "talking3", "talking_secret"]:
		check(seen.has("mie/" + clip), "New talking animation unused: " + clip)
	for cue: Array in preview.draft_cues[0]: check(cue[1] != "talking_secret", "Secret leaked into intro")
	check(stages.has("finish_idle") and stages.has("prepare_combat") and preview.presentation_stage == "combat_ready" and preview.animation.assigned_animation == "mie/talk_to_combat", "Missing new idle then talk_to_combat ending")
	check(combat_events[0] == 1 and not preview.voice.playing, "Combat handoff was missing/repeated or preceded voice completion")
	check(maximum_drift < 0.001, "Dialogue clips changed horizontal position")
	check(maximum_jump < 0.35, "Body pose snaps between frames")
	check(preview.head.get_blend_shape_value(0) < 0.001, "Mouth not closed after dialogue")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/angelastri_main_dialogue_end.png")
	preview.start_presentation()
	check(preview.presentation_stage == "main_dialogue" and preview.voice.playing and not preview.music.playing, "Replay did not restart main dialogue")
	preview.queue_free()
	await process_frame
	await process_frame
	check(AudioServer.bus_count == buses, "Capture bus leaked")
	print("ANGELASTRI_DIALOGUE_TEST duration=", duration, " peak=", peak, " gestures=", seen.size(), " max_jump=", maximum_jump, " drift=", maximum_drift, " failures=", failures)
	quit(0 if failures == 0 else 1)
