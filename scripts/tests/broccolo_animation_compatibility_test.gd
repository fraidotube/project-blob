extends SceneTree

const SOURCE := "res://assets/models/enemies/broccolo/animation/"
const FIXED := "res://assets/models/enemies/broccolo/animation_compatibili/"

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var model: Node3D = load("res://assets/models/enemies/broccolo/Broccolo.glb").instantiate()
	root.add_child(model)
	model.position = Vector3(12, 0, -8)
	var skeleton := model.get_node("Armature/GeneralSkeleton") as Skeleton3D
	var bone := skeleton.find_bone("mixamorig1_Hips")
	var anchor := skeleton.get_bone_rest(bone).origin
	var player := AnimationPlayer.new()
	model.add_child(player)
	player.owner = model
	player.root_node = NodePath("..")
	var library := AnimationLibrary.new()
	player.add_animation_library(&"",library)
	var original_idle: Animation = load(SOURCE + "idle.res")
	library.add_animation(&"original_idle",original_idle)
	player.play(&"original_idle")
	player.advance(0)
	assert(skeleton.get_bone_pose_position(bone).y < 2.0, "Original mismatch not reproduced")
	var count := 0
	for mode in ["in_place","con_spostamento"]:
		for filename in DirAccess.get_files_at(SOURCE):
			if not filename.ends_with(".res"): continue
			var original: Animation = load(SOURCE + filename)
			var fixed: Animation = load(FIXED + mode + "/" + filename)
			assert(original.length == fixed.length and original.get_track_count() == fixed.get_track_count())
			for track in original.get_track_count():
				assert(original.track_get_path(track) == fixed.track_get_path(track))
				assert(original.track_get_key_count(track) == fixed.track_get_key_count(track))
				for key in original.track_get_key_count(track):
					assert(original.track_get_key_time(track,key)==fixed.track_get_key_time(track,key))
					if original.track_get_type(track)!=Animation.TYPE_POSITION_3D:
						assert(original.track_get_key_value(track,key)==fixed.track_get_key_value(track,key),"Rotation/scale changed")
			var name := StringName(mode + "_" + filename.trim_suffix(".res"))
			library.add_animation(name,fixed)
			player.play(name)
			player.advance(0)
			for sample in range(31):
				var time := fixed.length * sample / 30.0
				player.seek(time,true)
				var pose := skeleton.get_bone_pose_position(bone)
				var expected: Vector3 = fixed.position_track_interpolate(0,time)
				assert(pose.is_equal_approx(expected),"Animation failed to bind root bone")
				var source_pose: Vector3 = original.position_track_interpolate(0,time)
				assert(absf(pose.y-source_pose.y*100.0)<.01,"Vertical motion scaled incorrectly")
				if mode=="in_place":
					assert(absf(pose.x-anchor.x)<.001 and absf(pose.z-anchor.z)<.001,"In-place root drift")
				assert(model.position.is_equal_approx(Vector3(12,0,-8)),"Scene position changed")
			count+=1
	model.queue_free()
	await process_frame
	print("BROCCOLO_ANIMATION_COMPATIBILITY_TEST passed clips=",count," samples=",count*31," original_origin_bug_reproduced=true")
	quit()
