extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var source := FileAccess.get_file_as_string("res://scenes/maps/map_test.tscn")
	for name in ["Contatori_Sx_SportelloDx", "Contatori_Sx_SportelloSx"]:
		var start := source.find('[node name="' + name + '"')
		assert(start >= 0, "Meter door missing")
		var stop := source.find("\n[node ", start + 1)
		assert(source.substr(start, stop - start).contains("close_sound_at_start = true"), "Meter door override missing")
	var world := Node3D.new()
	root.add_child(world)
	current_scene = world
	var stream := load("res://assets/audio/interactions/door/contatore_door_open.wav") as AudioStream
	assert(stream != null, "Meter door audio missing")
	for early in [false, true]:
		var door: Node3D = load("res://scripts/interactables/door.gd").new()
		var body := AnimatableBody3D.new()
		body.name = "DoorBody"
		door.add_child(body)
		var area := Area3D.new()
		area.name = "Area3D"
		door.add_child(area)
		door.open_sound = stream
		door.close_sound = stream
		door.close_sound_at_start = early
		world.add_child(door)
		door.set_physics_process(false)
		door.open_door()
		assert(door.door_audio.playing, "Opening sound did not start immediately")
		door.rotation.y = deg_to_rad(door.open_angle)
		door.door_audio.stop()
		door.close_door()
		assert(door.door_audio.playing == early, "Closing audio started at wrong time")
		assert(door.close_sound_pending == not early, "Closing sound pending state incorrect")
		for i in range(160): door._physics_process(1.0 / 60.0)
		assert(not door.close_sound_pending, "Closing sound remained pending at closed position")
		assert(door.door_audio.playing, "Closing sound missing")
		door.queue_free()
	world.queue_free()
	await process_frame
	await process_frame
	print("DOOR_AUDIO_TIMING_TEST passed: immediate meter audio, default closing impact retained")
	quit()
