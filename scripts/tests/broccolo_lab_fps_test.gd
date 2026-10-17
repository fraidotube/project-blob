extends SceneTree
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func frames(count: int) -> void:
	for index in count: await physics_frame
func shoot() -> void:
	var event := InputEventAction.new()
	event.action = &"fire"
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = InputEventAction.new()
	event.action = &"fire"
	event.pressed = false
	Input.parse_input_event(event)
func run() -> void:
	var world = load("res://scenes/levels/broccolo_combat_test.tscn").instantiate()
	root.add_child(world)
	current_scene = world
	while not world.ready_for_test: await process_frame
	check(not world.overview and world.combat, "Default FPS/combat startup disabled")
	check(world.player.is_physics_processing() and world.player.is_processing_unhandled_input(), "FPS player locked")
	await frames(300)
	check(world.copies.size() == world.max_copies, "Initial automatic wave missing")
	world.stop_combat()
	world.set_overview(false)
	var before: Vector3 = world.player.global_position
	Input.action_press(&"move_right")
	await frames(12)
	Input.action_release(&"move_right")
	check(world.player.global_position.x > before.x + 0.5, "Real movement input did not move player")
	for copy in world.copies:
		if is_instance_valid(copy): copy.queue_free()
	world.copies.clear()
	world.boss.global_position = Vector3(-6, 0.02, -6)
	var victim = world.actor_scene.instantiate()
	victim.principal = false
	victim.autonomous = false
	victim.position = world.player.global_position + Vector3(0, -0.88, -1.3)
	world.add_child(victim)
	await frames(5)
	victim.preview_clip(&"mie/idle")
	var camera: Camera3D = world.player.get_node("Head/Camera3D")
	camera.look_at(victim.global_position + Vector3.UP * 0.15)
	var weapon = world.player.get_node("Head/Camera3D/WeaponHolder")
	await frames(30)
	var ammo: int = weapon.magazine_ammo
	await shoot()
	await frames(45)
	check(weapon.magazine_ammo == ammo - 1, "FPS fire input did not consume ammunition")
	check(victim.health == 1, "Actual pistol ray did not hit copy")
	while victim.state == "hurt": await physics_frame
	await shoot()
	await frames(15)
	check(victim.health == 0 and victim.state == "dead", "Second actual pistol shot did not kill copy")
	# Let weapon animation coroutines and one-shot effects complete before teardown.
	await frames(120)
	print("BROCCOLO_LAB_FPS failures=", failures)
	world.queue_free()
	await frames(3)
	quit(0 if failures == 0 else 1)
