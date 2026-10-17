extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var packed: PackedScene = load("res://assets/models/enemies/broccolo/Broccolo.glb")
	var model := packed.instantiate()
	root.add_child(model)
	var report := {"nodes": [], "clips": []}
	for node in [model] + model.find_children("*", "Node3D", true, false):
		if node is Node3D:
			report.nodes.append({"path": String(model.get_path_to(node)), "class": node.get_class(), "position": str(node.position), "scale": str(node.scale)})
	for skeleton in model.find_children("*", "Skeleton3D", true, false):
		for bone in skeleton.get_bone_count():
			if skeleton.get_bone_parent(bone) < 0:
				report.nodes.append({"root_bone": skeleton.get_bone_name(bone), "rest": str(skeleton.get_bone_rest(bone)), "pose": str(skeleton.get_bone_pose_position(bone))})
	for filename in DirAccess.get_files_at("res://assets/models/enemies/broccolo/animation"):
		if not filename.ends_with(".res"): continue
		var clip: Animation = load("res://assets/models/enemies/broccolo/animation/" + filename)
		var data := {"file": filename, "length": clip.length, "tracks": []}
		for track in clip.get_track_count():
			var path := clip.track_get_path(track)
			var type := clip.track_get_type(track)
			if type != Animation.TYPE_POSITION_3D and type != Animation.TYPE_SCALE_3D: continue
			var count := clip.track_get_key_count(track)
			data.tracks.append({"index":track,"path":String(path),"type":type,"keys":count,"first":str(clip.track_get_key_value(track,0)) if count else "", "last":str(clip.track_get_key_value(track,count-1)) if count else ""})
		report.clips.append(data)
	var file := FileAccess.open("res://.godot/broccolo_animation_audit.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	print("BROCCOLO_ANIMATION_AUDIT ",JSON.stringify(report))
	model.queue_free()
	await process_frame
	quit()
