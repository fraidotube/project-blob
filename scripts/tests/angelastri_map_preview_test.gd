extends SceneTree

var failures := 0
var screenshots := false

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("ANGELASTRI_MAP_TEST: " + message)

func key(debug: Node, code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	debug._unhandled_input(event)

func ready_presentation(debug: Node) -> void:
	var start := Time.get_ticks_msec()
	while (debug.busy or not is_instance_valid(debug.presentation)) and Time.get_ticks_msec() - start < 30000:
		await process_frame
	check(is_instance_valid(debug.presentation) and not debug.busy, "Presentation did not load")

func photo(name: String, point: Vector3) -> void:
	if not screenshots: return
	var camera := Camera3D.new()
	current_scene.add_child(camera)
	camera.global_position = point + Vector3(3.0, 2.2, -3.0)
	camera.look_at(point + Vector3.UP * 1.0)
	camera.current = true
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/angelastri_map_" + name + ".png")
	camera.queue_free()
	await process_frame
	current_scene.get_node("Player/Head/Camera3D").current = true

func run() -> void:
	screenshots = DisplayServer.get_name() != "headless"
	if screenshots:
		root.mode = Window.MODE_WINDOWED
		root.size = Vector2i(1280, 720)
	root.get_node("SaveManager").save_path = "res://.godot/angelastri_map_fixture.cfg"
	change_scene_to_file("res://scenes/maps/map_test.tscn")
	await process_frame
	await process_frame
	await physics_frame
	var debug: Node = current_scene.get_node("AngelastriMapPreview")
	var player: Node3D = current_scene.get_node("Player")
	var player_camera: Camera3D = player.get_node("Head/Camera3D")
	var mouse := Input.mouse_mode
	var buses := AudioServer.bus_count
	var participants: int = root.get_node("SaveManager").participants.size()
	var bruno: Node = current_scene.get_node("BrunoBuozzi")
	var initial_bruno_ai: bool = bruno.ai_active
	check(debug.presentation == null, "Angelastri auto-spawned without test key")
	key(debug, KEY_F9)
	check(debug.presentation == null, "Debug captured Bruno F9")
	key(debug, KEY_F10)
	await ready_presentation(debug)
	var preview: Node3D = debug.presentation
	if OS.get_cmdline_user_args().has("--survey"):
		var meters: Node3D = current_scene.get_node("connesi_building_test2/ContatoriSx")
		var space: PhysicsDirectSpaceState3D = current_scene.get_world_3d().direct_space_state
		var shape := CapsuleShape3D.new()
		shape.radius = 0.55
		shape.height = 1.9
		for x in [-0.5, 1.3, 3.0]:
			for z in [4.5, 6.0, 7.5, 9.0]:
				var base := meters.global_position + Vector3(x, 0, z)
				var collisions := 0
				var hazard_contacts := 0
				var missing_floor := 0
				for i in range(161):
					var offset: Vector3 = preview.world_motion_offset(preview.dance_start_delay + preview.dance_duration() * i / 160.0)
					var point := base + Basis(Vector3.UP, PI / 2.0) * offset
					var ray := PhysicsRayQueryParameters3D.create(point + Vector3.UP * 2.0, point - Vector3.UP * 3.0, 1)
					ray.exclude = [player.get_rid()]
					var floor_hit := space.intersect_ray(ray)
					if floor_hit.is_empty():
						missing_floor += 1
						continue
					point.y = floor_hit.position.y
					var query := PhysicsShapeQueryParameters3D.new()
					query.shape = shape
					query.exclude = [player.get_rid()]
					query.collision_mask = 1
					query.transform.origin = point + Vector3.UP * 1.05
					if not space.intersect_shape(query).is_empty(): collisions += 1
					query.collide_with_bodies = false
					query.collide_with_areas = true
					query.collision_mask = 0xFFFFFFFF
					for contact in space.intersect_shape(query):
						var script: Script = contact.collider.get_script()
						if script != null and (script.resource_path.ends_with("fire_damage_zone.gd") or script.resource_path.ends_with("smoke_cough_zone.gd")): hazard_contacts += 1
				print("ANGELASTRI_ROUTE_CANDIDATE offset=", Vector2(x,z), " collisions=", collisions, " hazards=", hazard_contacts, " missing_floor=", missing_floor)
		debug.clear_preview()
		print("ANGELASTRI_ROUTE_SURVEY_DONE")
		quit()
		return
	check(preview.presentation_stage == "intro" and preview.voice.playing and not preview.music.playing, "F10 did not start intro")
	check(player_camera.current and Input.mouse_mode == mouse and player.is_physics_processing(), "Test changed FPS camera/input")
	check(preview.camera == null and preview.find_children("*", "WorldEnvironment", true, false).is_empty(), "Studio camera/environment leaked into map")
	await photo("spawn", preview.model.global_position)
	preview.advance_presentation()
	preview.sequence = false
	var first_position: Vector3 = preview.model.global_position
	var range_box := AABB(first_position, Vector3.ZERO)
	var previous_position := first_position
	var max_step := 0.0
	var occupied := 0
	var shape := CapsuleShape3D.new()
	shape.radius = 0.45
	shape.height = 1.8
	var space: PhysicsDirectSpaceState3D = current_scene.get_world_3d().direct_space_state
	var duration: float = preview.dance_start_delay + preview.dance_duration()
	for i in range(1, 401):
		var time := duration * i / 400.0
		preview.sync_sequence(time)
		var position: Vector3 = preview.model.global_position
		range_box = range_box.expand(position)
		max_step = maxf(max_step, position.distance_to(previous_position))
		previous_position = position
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = shape
		query.collision_mask = 1
		query.exclude = [player.get_rid()]
		query.transform.origin = position + Vector3.UP * 1.0
		var contacts := space.intersect_shape(query)
		if not contacts.is_empty():
			occupied += 1
			if occupied <= 5: print("ANGELASTRI_DANCE_OBSTACLE t=", time, " position=", position, " collider=", contacts[0].collider.get_path())
	check(range_box.size.x > 4.0, "Dancer did not move its actual node through world space")
	check(occupied == 0, "Chosen dance route intersects map obstacles")
	check(max_step < 0.9, "Dance route teleports between clips")
	check(preview.presentation_stage == "rest" and not preview.music.playing, "Dance did not finish correctly")
	await photo("dance_end", preview.model.global_position)
	var boundary: float = preview.dance_start_delay
	for clip in preview.DANCES:
		boundary += preview.animation.get_animation(clip).length
		var before: Vector3 = preview.world_motion_offset(boundary - 0.001)
		var after: Vector3 = preview.world_motion_offset(boundary + 0.001)
		check(before.distance_to(after) < 0.02, "Root motion discontinuity at " + String(clip))
	var end_position: Vector3 = preview.model.global_position
	key(debug, KEY_F11)
	await ready_presentation(debug)
	preview = debug.presentation
	check(preview.presentation_stage == "main_dialogue" and preview.voice.playing and not preview.music.playing, "F11 did not start second sequence")
	check(preview.global_position.distance_to(end_position) < 0.05, "Second sequence reset actor to spawn")
	check(player_camera.current and Input.mouse_mode == mouse, "Second sequence took player camera/input")
	await photo("dialogue", preview.model.global_position)
	paused = true
	await create_timer(0.3).timeout
	check(preview.head.get_blend_shape_value(0) < 0.001, "Mouth remains open in normal tree pause")
	paused = false
	key(debug, KEY_F12)
	await process_frame
	await process_frame
	check(debug.presentation == null and AudioServer.bus_count == buses, "Clear leaked actor/capture bus")
	check(root.get_node("SaveManager").participants.size() == participants, "Debug added gameplay persistence")
	check(bruno.ai_active == initial_bruno_ai, "Test changed Bruno")
	print("ANGELASTRI_MAP_TEST failures=", failures, " travel=", range_box.size, " max_step=", max_step, " occupied=", occupied)
	quit(0 if failures == 0 else 1)
