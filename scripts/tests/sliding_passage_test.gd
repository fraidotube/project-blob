extends SceneTree
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	change_scene_to_file("res://scenes/maps/map_test.tscn")
	await process_frame
	await process_frame
	await physics_frame
	var integration = current_scene.get_node("RegiaIntegration")
	var player = current_scene.get_node("Player")
	player.set_physics_process(false)
	player.set_process(false)
	var inventory := root.get_node("InventoryManager")
	inventory.add_item(&"bruno_key")
	for door in [integration.lab_door, integration.bathroom_door]:
		var closed_zone: CollisionShape3D = door.passage.get_child(0)
		var closed_parameters := PhysicsTestMotionParameters3D.new()
		closed_parameters.from = player.global_transform
		closed_parameters.from.origin = Vector3(closed_zone.global_position.x, 0.9, closed_zone.global_position.z + 0.55)
		closed_parameters.motion = Vector3(0, 0, -1.1)
		if not PhysicsServer3D.body_test_motion(player.get_rid(), closed_parameters):
			failures += 1
			push_error("Closed sliding door did not block the player: " + String(door.name))
		door.interact(player)
		await create_timer(1.0).timeout
		var zone: CollisionShape3D = door.passage.get_child(0)
		var center := zone.global_position
		for side in [1.0, -1.0]:
			var parameters := PhysicsTestMotionParameters3D.new()
			parameters.from = player.global_transform
			# Cross the doorway itself, without sweeping into the bathroom
			# vanity that stands farther behind it.
			parameters.from.origin = Vector3(center.x, 0.9, center.z + side * 0.55)
			parameters.motion = Vector3(0, 0, -side * 1.1)
			parameters.recovery_as_collision = true
			var result := PhysicsTestMotionResult3D.new()
			var blocked := PhysicsServer3D.body_test_motion(player.get_rid(), parameters, result)
			if blocked:
				failures += 1
				for index in result.get_collision_count():
					var collider = result.get_collider(index)
					print("SLIDING_PASSAGE_BLOCK ", door.name, " side=", side, " collider=", collider.get_path() if collider is Node else collider, " normal=", result.get_collision_normal(index), " point=", result.get_collision_point(index))
			else:
				print("SLIDING_PASSAGE_CLEAR ", door.name, " side=", side)
	print("SLIDING_PASSAGE_TEST failures=", failures)
	current_scene.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
