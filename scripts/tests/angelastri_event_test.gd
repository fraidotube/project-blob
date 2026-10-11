extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var script: Script = load("res://scripts/cinematics/angelastri_encounter.gd")
	assert(script != null and script.can_instantiate())
	var event = load("res://scripts/systems/angelastri_event_state.gd").new()
	event.arm(10.0)
	event.arm(1.0)
	assert(event.remaining == 10.0)
	assert(not event.tick(20.0, false, true))
	assert(not event.tick(20.0, true, false))
	for count in [1, 2, 3]:
		assert(event.tick(20.0, true, true))
		assert(event.blackout_count == count)
		assert(not event.crossed(false, 6.0))
		if count < 3:
			assert(not event.crossed(true, 6.0))
			event.power_changed(true)
			assert(not event.tick(20.0, false, true))
			event.crossed(false, 6.0)
			assert(event.stage == "countdown" and event.remaining == 6.0)
		else:
			assert(event.crossed(true, 6.0))
			assert(not event.crossed(true, 6.0))
	event.stage = "waiting"
	var saved: Dictionary = event.snapshot()
	event.restore(saved)
	assert(event.stage == "waiting" and event.blackout_count == 3)
	event.restore({})
	assert(not event.armed and event.stage == "dormant")
	print("ANGELASTRI_EVENT_TEST passed")
	quit()
