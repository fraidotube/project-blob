extends SceneTree

var failures := 0
var scene: Node
var adapter: Node

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, label: String) -> void:
	if not value:
		failures += 1
		push_error("Mouth integration: " + label)

func sample(label: String, seconds: float = 2.0) -> void:
	var peak := 0.0
	var start := Time.get_ticks_msec()
	while Time.get_ticks_msec() - start < seconds * 1000:
		await process_frame
		peak = maxf(peak, adapter.head.get_blend_shape_value(0))
	check(peak > 0.01, label + " did not animate")
	print("MOUTH_INTEGRATION_SAMPLE ", label, " peak=", peak)

func run() -> void:
	var buses := AudioServer.bus_count
	change_scene_to_file("res://scenes/maps/map_test.tscn")
	await process_frame
	await process_frame
	await process_frame
	scene = current_scene
	var boss = scene.get_node("BrunoBuozzi")
	adapter = boss.get_node("MouthIntegration")
	check(adapter.motion != null, "Adapter not initialized in real map")
	if adapter.motion == null:
		quit(1)
		return
	boss.set_process(false)
	boss.set_physics_process(false)
	var camera := Camera3D.new()
	scene.add_child(camera)
	camera.global_position = boss.global_position + Vector3(0, 1.5, 2)
	camera.current = true
	var intro = scene.get_node("BrunoIntroController")
	intro._play_dialogue_part1()
	await sample("cinematic_part1")
	intro.dialogue_player.stop()
	intro._play_dialogue_part2()
	await sample("cinematic_part2")
	intro.dialogue_player.stop()
	boss._play_boss_voice(boss.normal_ball_voice_streams[0], "MOUTH_TEST")
	await sample("combat_phrase")
	boss._play_damage_voice()
	await sample("damage")
	check(not adapter.motion.expressive_speech, "Damage must not smile")
	boss._play_phase_fall_voice(2)
	await sample("phase_fall")
	boss.boss_voice_player.stop()
	var death = boss.get_node("BrunoDeathAudio")
	death.stream = load("res://assets/models/enemies/bruno_buozzi/morteBruno.mp3")
	death.bus = &"Master"
	death.play()
	await sample("defeat", 3.0)
	check(adapter.motion.voice == death, "Death voice priority")
	death.stop()
	await create_timer(1.5).timeout
	check(adapter.head.get_blend_shape_value(0) < 0.001, "Stopped mouth not closed")
	check(adapter.head.get_blend_shape_value(2) < 0.001, "Stopped smile not closed")
	scene.queue_free()
	await process_frame
	await process_frame
	check(AudioServer.bus_count == buses, "Bus leaked after map exit")
	print("BRUNO_MOUTH_INTEGRATION_TEST failures=", failures)
	quit(0 if failures == 0 else 1)
