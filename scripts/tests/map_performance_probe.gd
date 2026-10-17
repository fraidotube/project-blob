extends SceneTree

# Isolated measurement: never writes user saves/settings or scene resources.
var report := {}
var camera: Camera3D

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.get_node("SaveManager").save_path = "res://.godot/performance_fixture.cfg"
	Engine.max_fps = 0
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1920, 1080)
	report["renderer"] = RenderingServer.get_video_adapter_name()
	report["headless"] = DisplayServer.get_name() == "headless"
	report["render_scale"] = root.scaling_3d_scale
	var start := Time.get_ticks_usec()
	var packed := load("res://scenes/maps/map_test.tscn") as PackedScene
	report["resource_load_ms"] = (Time.get_ticks_usec() - start) / 1000.0
	print("PERFORMANCE_LOAD_MS ", report["resource_load_ms"])
	start = Time.get_ticks_usec()
	var map := packed.instantiate()
	report["instantiate_ms"] = (Time.get_ticks_usec() - start) / 1000.0
	print("PERFORMANCE_INSTANTIATE_MS ", report["instantiate_ms"])
	start = Time.get_ticks_usec()
	root.add_child(map)
	current_scene = map
	report["add_ready_ms"] = (Time.get_ticks_usec() - start) / 1000.0
	print("PERFORMANCE_READY_MS ", report["add_ready_ms"])
	camera = map.get_node("Player/Head/Camera3D")
	await sample("initial", 180, false)
	await sample("stationary", 240, false)
	await sample("turn_first", 360, true)
	await sample("turn_repeat", 360, true)
	paused = true
	await sample("paused_turn", 360, true)
	paused = false
	var shadow_lights: Array[Light3D] = []
	for light in map.find_children("*", "Light3D", true, false):
		if light.shadow_enabled:
			shadow_lights.append(light)
			light.shadow_enabled = false
	await sample("no_shadows_turn", 360, true)
	for light in shadow_lights: light.shadow_enabled = true
	report["shadow_lights"] = shadow_lights.size()
	root.scaling_3d_scale = 0.5
	await sample("half_resolution_turn", 360, true)
	root.disable_3d = true
	await sample("no_render", 240, false)
	root.disable_3d = false
	report["memory_static_mib"] = Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0
	report["video_memory_mib"] = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0
	report["texture_memory_mib"] = Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1048576.0
	var mesh_rows: Array = []
	for node in map.find_children("*", "MeshInstance3D", true, false):
		if not node.mesh is ArrayMesh: continue
		var triangles := 0
		for surface in range(node.mesh.get_surface_count()):
			if node.mesh.surface_get_primitive_type(surface) != Mesh.PRIMITIVE_TRIANGLES: continue
			var count: int = node.mesh.surface_get_array_index_len(surface)
			if count == 0: count = node.mesh.surface_get_array_len(surface)
			triangles += count / 3
		mesh_rows.append({"path": str(map.get_path_to(node)), "triangles": triangles})
	mesh_rows.sort_custom(func(a, b): return a.triangles > b.triangles)
	report["mesh_instances"] = mesh_rows.size()
	report["largest_meshes"] = mesh_rows.slice(0, 25)
	var output := FileAccess.open("res://.godot/map_performance_report.json", FileAccess.WRITE)
	output.store_string(JSON.stringify(report, "\t"))
	print("PERFORMANCE_REPORT ", JSON.stringify(report))
	quit()

func sample(label: String, frames: int, turn: bool) -> void:
	var times: Array[float] = []
	var process_sum := 0.0
	var physics_sum := 0.0
	var max_primitives := 0.0
	var max_draws := 0.0
	var original := camera.rotation
	var previous := Time.get_ticks_usec()
	for frame in range(frames):
		if turn: camera.rotation.y = original.y + TAU * float(frame) / frames
		await process_frame
		var now := Time.get_ticks_usec()
		times.append((now - previous) / 1000.0)
		previous = now
		process_sum += Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
		physics_sum += Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
		max_primitives = maxf(max_primitives, Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
		max_draws = maxf(max_draws, Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	camera.rotation = original
	times.sort()
	var total := 0.0
	var hitches := 0
	for value in times:
		total += value
		if value > 50.0: hitches += 1
	report[label] = {"mean_ms": total / frames, "p95_ms": times[int(frames * 0.95)], "p99_ms": times[int(frames * 0.99)], "max_ms": times.back(), "over_50ms": hitches, "process_ms": process_sum / frames, "physics_ms": physics_sum / frames, "max_primitives": max_primitives, "max_draw_calls": max_draws}
	print("PERFORMANCE_PHASE ", label, " ", JSON.stringify(report[label]))
