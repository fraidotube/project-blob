extends SceneTree

var failures := 0
var studio: Node
var elapsed := 0.0
var last_stage := ""
var max_step := 0.0
var last_position := Vector3.ZERO
var mouth_peak := 0.0
var paused_throw_tested := false

func _initialize() -> void:
	call_deferred("run")

func check(ok:bool,message:String) -> void:
	if not ok:
		failures+=1
		push_error(message)

func run() -> void:
	studio=load("res://scenes/levels/broccolo_animation_test.tscn").instantiate()
	root.add_child(studio)
	while not studio.ready_for_preview:await process_frame
	check(studio.clip_names.size()==28,"Expected 28 clips")
	for name in studio.clip_names:
		var clip:Animation=studio.animation.get_animation(name)
		for track in clip.get_track_count():
			var path:=clip.track_get_path(track)
			check(path.get_subname_count()==1 and studio.skeleton.find_bone(path.get_subname(0))>=0,"Unresolved bone in "+String(name))
	for name in ["talk1","talk2","talk3","talk4"]:
		var original:Animation=load("res://assets/models/enemies/broccolo/animation/"+name+".res")
		var corrected:Animation=load("res://assets/models/enemies/broccolo/animation_compatibili/in_place/"+name+".res")
		check(is_equal_approx(original.length,corrected.length),"Talk timing changed")
		for track in original.get_track_count():
			if original.track_get_type(track)!=Animation.TYPE_POSITION_3D:
				check(original.track_get_key_value(track,0)==corrected.track_get_key_value(track,0),"Talk rotation changed")
	studio.start_introduction()
	check(not studio.music.playing,"Phone intro has unexpected music")
	last_position=studio.actor.position
	while studio.presentation.stage!="intro_ready" and elapsed<45:
		await process_frame
		elapsed+=studio.get_process_delta_time()
		mouth_peak=maxf(mouth_peak,studio.head.get_blend_shape_value(0))
		max_step=maxf(max_step,studio.actor.position.distance_to(last_position))
		last_position=studio.actor.position
		if studio.presentation.stage!=last_stage:
			last_stage=studio.presentation.stage
			await capture("phone_"+last_stage)
		if studio.presentation.stage=="throw" and not paused_throw_tested:
			paused_throw_tested=true
			check(studio.voice.stream_paused,"Audio not suspended during throw")
			var time:float=studio.voice.get_playback_position()
			studio.toggle_pause()
			await create_timer(.35).timeout
			check(absf(studio.voice.get_playback_position()-time)<.04,"Audio moved while paused")
			studio.toggle_pause()
			check(studio.voice.stream_paused,"Resuming preview resumed speech during throw")
	check(studio.presentation.stage=="intro_ready","Phone sequence timeout")
	check(paused_throw_tested,"Throw not visited")
	check(studio.presentation.walk_cycles==3 and studio.presentation.walk_distance>3,"Walk shorter than requested")
	check(mouth_peak>.02,"Real intro did not drive mouth")
	check(max_step<.25,"Position discontinuity during phone handoff")
	studio.start_discourse()
	check(studio.voice.stream==studio.presentation.discourse,"Wrong discourse audio")
	check(studio.music.playing and studio.music.volume_db==-16,"Background music missing")
	var arm:int=studio.skeleton.find_bone("mixamorig1_RightArm")
	var initial:Quaternion=studio.skeleton.get_bone_pose_rotation(arm)
	var arm_change:=0.0
	elapsed=0
	last_stage=""
	var dance_order:Array[String]=[]
	var last_dance:=""
	var dance_entry:=-1.0
	while studio.presentation.stage!="combat_ready" and elapsed<45:
		await process_frame
		elapsed+=studio.get_process_delta_time()
		arm_change=maxf(arm_change,initial.angle_to(studio.skeleton.get_bone_pose_rotation(arm)))
		if studio.presentation.stage=="dance":
			if dance_entry<0:dance_entry=studio.voice.get_playback_position()
			var current:=String(studio.animation.assigned_animation)
			if current!=last_dance:
				dance_order.append(current)
				last_dance=current
		if studio.presentation.stage!=last_stage:
			last_stage=studio.presentation.stage
			await capture("discourse_"+last_stage)
	check(studio.presentation.stage=="combat_ready","Discourse sequence timeout")
	check(absf(dance_entry-21)<.12,"Demi-plie cue not at 21 seconds")
	check(dance_order==["mie/dancing3","mie/dancing2","mie/dancing"],"Wrong dance order")
	check(arm_change>.1,"Talking arms did not move")
	check(absf(studio.standing_height*studio.actor.scale.y-.2)<.001,"Final height not 20 cm")
	check(not studio.music.playing and studio.component.motion==null,"Audio capture or music left active")
	studio.reset_preview()
	check(not studio.presentation.active(),"Reset did not cancel presentation")
	print("BROCCOLO_PRESENTATION_TEST failures=",failures," mouth_peak=",mouth_peak," walk_m=",studio.presentation.walk_distance," max_step=",max_step," dance_entry=",dance_entry," order=",dance_order)
	studio.queue_free()
	await process_frame
	quit(failures)

func capture(label:String) -> void:
	if DisplayServer.get_name()=="headless":return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/broccolo_presentation_"+label+".png")
