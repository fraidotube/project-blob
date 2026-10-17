extends SceneTree

const SOURCE := "res://assets/models/enemies/broccolo/animation/"
const OUTPUT := "res://assets/models/enemies/broccolo/animation_compatibili/"

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var selected := OS.get_cmdline_user_args()
	for filename in selected:
		assert(filename == filename.get_file() and filename.ends_with(".res") and FileAccess.file_exists(SOURCE + filename), "Invalid source animation")
	var packed: PackedScene = load("res://assets/models/enemies/broccolo/Broccolo.glb")
	var model := packed.instantiate()
	root.add_child(model)
	var skeleton := model.get_node("Armature/GeneralSkeleton") as Skeleton3D
	var scale := skeleton.global_basis.get_scale()
	assert(scale.is_equal_approx(Vector3.ONE * 0.01), "Unexpected rig scale; stop conversion")
	var factor := 1.0 / scale.x
	var root_bone := skeleton.find_bone("mixamorig1_Hips")
	assert(root_bone >= 0 and skeleton.get_bone_parent(root_bone) == -1)
	var anchor := skeleton.get_bone_rest(root_bone).origin
	var manifest := {"factor": factor, "anchor": str(anchor), "clips": []}
	for mode in ["in_place", "con_spostamento"]:
		DirAccess.make_dir_recursive_absolute(OUTPUT + mode)
		for filename in DirAccess.get_files_at(SOURCE):
			if not filename.ends_with(".res"): continue
			if not selected.is_empty() and not selected.has(filename): continue
			var original: Animation = load(SOURCE + filename)
			var clip := original.duplicate(true) as Animation
			var converted := 0
			for track in clip.get_track_count():
				var path := clip.track_get_path(track)
				if clip.track_get_type(track) != Animation.TYPE_POSITION_3D: continue
				assert(path.get_subname_count() == 1 and path.get_subname(0) == "mixamorig1_Hips", "Unexpected translation track")
				var first: Vector3 = clip.track_get_key_value(track, 0)
				for key in clip.track_get_key_count(track):
					var value: Vector3 = clip.track_get_key_value(track, key) * factor
					if mode == "in_place":
						value.x = anchor.x
						value.z = anchor.z
					else:
						value.x += anchor.x - first.x * factor
						value.z += anchor.z - first.z * factor
					clip.track_set_key_value(track, key, value)
				converted += 1
			assert(converted == 1, "Root position track not found")
			clip.resource_path = ""
			assert(ResourceSaver.save(clip, OUTPUT + mode + "/" + filename) == OK)
			manifest.clips.append({"file": filename, "mode": mode, "length":clip.length,"tracks":clip.get_track_count()})
	var report := "broccolo_animation_conversion.json" if selected.is_empty() else "broccolo_animation_conversion_selected.json"
	var file := FileAccess.open("res://.godot/" + report,FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest,"\t"))
	model.queue_free()
	await process_frame
	print("BROCCOLO_ANIMATIONS_PREPARED ", manifest.clips.size())
	quit()
