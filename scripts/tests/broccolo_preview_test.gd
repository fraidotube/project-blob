extends SceneTree

var failures := 0
func check(ok:bool,message:String) -> void:
	if not ok:
		failures+=1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var studio=load("res://scenes/levels/broccolo_animation_test.tscn").instantiate()
	root.add_child(studio)
	while not studio.ready_for_preview:await process_frame
	check(studio.component.ready_for_mouth,"Mouth setup failed")
	check(studio.head.mesh.get_blend_shape_count()==3,"Missing mouth shapes")
	check(studio.clip_names.size()==28,"Unexpected clip count")
	check(studio.voice_stream.get_length()>1,"Intro missing")
	var original_transform:Transform3D=studio.head.transform
	for name in studio.clip_names:
		studio.play_clip(name)
		var clip:Animation=studio.animation.get_animation(name)
		studio.animation.seek(clip.length*.5,true)
		studio._update_motion()
		check(studio.actor.position.is_finite(),"Invalid movement: "+String(name))
		check(studio.head.transform==original_transform,"Head attachment changed")
	studio.play_clip(&"mie/idle")
	studio.closeup=true
	studio.component.set_expression(0)
	await create_timer(.3).timeout
	await capture("closed")
	studio.component.set_expression(.72)
	await create_timer(.2).timeout
	await capture("open")
	studio.play_voice()
	var peak:=0.0
	for sample in range(90):
		await create_timer(.04).timeout
		peak=maxf(peak,studio.head.get_blend_shape_value(0))
	check(peak>.02,"Intro did not animate mouth")
	studio.toggle_pause()
	await create_timer(.4).timeout
	check(studio.head.get_blend_shape_value(0)<.02,"Paused speech mouth not closed")
	studio.toggle_pause()
	studio.start_dance()
	check(studio.sequence and studio.music.playing,"Standalone music dance did not start")
	studio.closeup=false
	studio.music.seek(studio.animation.get_animation(studio.DANCES[0]).length+.5)
	await create_timer(.4).timeout
	check(studio.dance_index==1,"Dance clip transition failed")
	await capture("dance")
	studio._finish_dance()
	await create_timer(2.3).timeout
	check(absf(studio.standing_height*studio.actor.scale.y-.2)<.001,"Height is not 20 cm")
	await capture("miniature")
	studio.reset_preview()
	check(studio.actor.scale.is_equal_approx(Vector3.ONE),"Reset scale failed")
	check(studio.component.motion==null,"Voice capture not released")
	print("BROCCOLO_PREVIEW_TEST failures=",failures," clips=",studio.clip_names.size()," mouth_peak=",peak," intro_seconds=",studio.voice_stream.get_length())
	studio.queue_free()
	await process_frame
	quit(failures)

func capture(label:String) -> void:
	if DisplayServer.get_name()=="headless":return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/broccolo_preview_"+label+".png")
