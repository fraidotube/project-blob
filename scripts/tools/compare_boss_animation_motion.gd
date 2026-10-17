extends SceneTree

func _initialize() -> void:
	for path in ["res://assets/models/enemies/Angelastri/Animation/idle.res", "res://assets/models/enemies/Angelastri/Animation/walking.res", "res://assets/models/enemies/Angelastri/Animation/thrller_1.res", "res://assets/models/enemies/broccolo/animation_compatibili/con_spostamento/idle.res", "res://assets/models/enemies/broccolo/animation_compatibili/con_spostamento/walking.res", "res://assets/models/enemies/broccolo/animation_compatibili/con_spostamento/dancing.res"]:
		var clip: Animation = load(path)
		for track in clip.get_track_count():
			if clip.track_get_type(track) != Animation.TYPE_POSITION_3D: continue
			var first: Vector3 = clip.track_get_key_value(track,0)
			var last: Vector3 = clip.track_get_key_value(track,clip.track_get_key_count(track)-1)
			print("BOSS_MOTION ",path," bone=",clip.track_get_path(track)," start=",first," travel=",last-first)
	quit()
