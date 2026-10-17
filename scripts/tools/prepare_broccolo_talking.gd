extends SceneTree

const SOURCE := "res://assets/models/enemies/Angelastri/Animation/"
const OUTPUT := "res://assets/models/enemies/broccolo/animation_compatibili/"
const NAMES := ["talking", "talking2", "talking3"]

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var source_model=load("res://scenes/enemies/angelastri.tscn").instantiate()
	var target_model=load("res://assets/models/enemies/broccolo/Broccolo.glb").instantiate()
	var source:Skeleton3D=source_model.get_node("sgt_Angelastri/Armature/GeneralSkeleton")
	var target:Skeleton3D=target_model.get_node("Armature/GeneralSkeleton")
	var source_anchor:=source.get_bone_rest(source.find_bone("mixamorig_Hips")).origin
	var target_anchor:=target.get_bone_rest(target.find_bone("mixamorig1_Hips")).origin
	var ratio:=target_anchor.y/source_anchor.y
	var report := {"hip_ratio":ratio,"clips":[]}
	for mode in ["in_place","con_spostamento"]:
		DirAccess.make_dir_recursive_absolute(OUTPUT+mode)
		for name in NAMES:
			var original:Animation=load(SOURCE+name+".res")
			var clip:=original.duplicate(true) as Animation
			for track in clip.get_track_count():
				var path:=clip.track_get_path(track)
				assert(path.get_subname_count()==1 and String(path.get_subname(0)).begins_with("mixamorig_"),"Unexpected source bone path")
				var source_name:=String(path.get_subname(0))
				var target_name:=source_name.replace("mixamorig_","mixamorig1_")
				var sb:=source.find_bone(source_name)
				var tb:=target.find_bone(target_name)
				assert(sb>=0 and tb>=0,"Bone missing: "+target_name)
				clip.track_set_path(track,NodePath("%GeneralSkeleton:"+target_name))
				if clip.track_get_type(track)==Animation.TYPE_ROTATION_3D:
					var sp:=source.get_bone_parent(sb)
					var tp:=target.get_bone_parent(tb)
					var source_parent:=Quaternion.IDENTITY if sp<0 else source.get_bone_global_rest(sp).basis.get_rotation_quaternion()
					var target_parent:=Quaternion.IDENTITY if tp<0 else target.get_bone_global_rest(tp).basis.get_rotation_quaternion()
					var before:=target_parent.inverse()*source_parent
					var after:=source.get_bone_global_rest(sb).basis.get_rotation_quaternion().inverse()*target.get_bone_global_rest(tb).basis.get_rotation_quaternion()
					for key in clip.track_get_key_count(track):
						var rotation:Quaternion=clip.track_get_key_value(track,key)
						clip.track_set_key_value(track,key,(before*rotation*after).normalized())
				elif clip.track_get_type(track)==Animation.TYPE_POSITION_3D:
					assert(source_name=="mixamorig_Hips","Unexpected non-root translation")
					var first:Vector3=clip.track_get_key_value(track,0)
					for key in clip.track_get_key_count(track):
						var value:Vector3=clip.track_get_key_value(track,key)
						var converted:=target_anchor+(value-source_anchor)*ratio
						converted.x=target_anchor.x if mode=="in_place" else target_anchor.x+(value.x-first.x)*ratio
						converted.z=target_anchor.z if mode=="in_place" else target_anchor.z+(value.z-first.z)*ratio
						clip.track_set_key_value(track,key,converted)
				else:assert(false,"Unsupported source track type")
			clip.resource_path=""
			assert(ResourceSaver.save(clip,OUTPUT+mode+"/"+name+".res")==OK)
			report.clips.append({"name":name,"mode":mode,"length":clip.length,"tracks":clip.get_track_count()})
	source_model.free()
	target_model.free()
	var file:=FileAccess.open("res://.godot/broccolo_talking_conversion.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	print("BROCCOLO_TALKING_PREPARED copies=",report.clips.size()," hip_ratio=",ratio)
	quit()
