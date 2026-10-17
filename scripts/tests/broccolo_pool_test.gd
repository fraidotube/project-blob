extends SceneTree
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func run() -> void:
	var world = load("res://scenes/levels/broccolo_combat_test.tscn").instantiate()
	world.auto_combat = false
	world.start_in_fps = false
	root.add_child(world)
	current_scene = world
	while not world.ready_for_test: await process_frame
	check(world.reserve.size() == 3, "Pool incompleto")
	var mouth = world.boss.get_node("MouthPresentation")
	check(mouth.head_load_count == 1, "GLB bocca riletto per copia")
	var actor = world.emit_copy()
	check(actor != null, "Emissione fallita")
	if actor != null:
		var identity: int = actor.get_instance_id()
		var other = world.reserve[1].get_node("MouthPresentation")
		var component = actor.get_node("MouthPresentation")
		component.set_expression(0.8)
		check(is_equal_approx(other.head.get_blend_shape_value(0), 0.0), "Espressioni condivise fra istanze")
		actor.health = 0
		actor.recovery = 10
		world.retire_actor(actor)
		var recycled = world.emit_copy()
		check(recycled != null and recycled.get_instance_id() == identity, "Copia ricreata anziche riusata")
		check(recycled.health == 2 and recycled.recovery == 0 and recycled.visible, "Reset copia incompleto")
	for index in 60: await physics_frame
	print("BROCCOLO_POOL failures=", failures, " spawn_ms=", world.spawn_times_ms)
	world.queue_free()
	for index in 3: await process_frame
	quit(0 if failures == 0 else 1)
