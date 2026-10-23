extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var transition = root.get_node("SceneTransition")
	var audio = root.get_node("AudioManager")
	var original_mute := AudioServer.is_bus_mute(0)
	AudioServer.set_bus_mute(0, false)
	var boot = load("res://scenes/ui/boot.tscn").instantiate()
	# Run both real logo sequences and their real handoff, with shorter holds only.
	boot.fraidosoft_hold_time = 0.05
	boot.project_blob_hold_time = 0.05
	boot.fade_in_time = 0.05
	boot.fade_out_time = 0.05
	root.add_child(boot)
	current_scene = boot
	audio.ensure_menu_music()
	var player: AudioStreamPlayer = audio.music_player
	var saw_transition := false
	var previous_position := player.get_playback_position()
	var deadline := Time.get_ticks_msec() + 15000
	while current_scene == boot or transition._busy:
		await process_frame
		assert(Time.get_ticks_msec() < deadline, "Boot non termina")
		assert(not AudioServer.is_bus_mute(0), "Musica silenziata durante intro/menu")
		assert(audio.music_player == player and player.playing and not player.stream_paused, "Player musicale fermato o ricreato")
		var position := player.get_playback_position()
		assert(position + 0.05 >= previous_position, "Musica riavviata")
		previous_position = position
		saw_transition = saw_transition or transition._busy
	assert(saw_transition and current_scene.scene_file_path == "res://scenes/ui/main_menu.tscn")
	# Gameplay loading still mutes, then restores the user's previous mute setting.
	for initially_muted in [false, true]:
		AudioServer.set_bus_mute(0, initially_muted)
		var packed: PackedScene = await transition.load_scene("res://scenes/levels/inventory_save_test.tscn", "TEST")
		assert(packed != null and AudioServer.is_bus_mute(0))
		transition.cancel_loading()
		assert(AudioServer.is_bus_mute(0) == initially_muted)
	AudioServer.set_bus_mute(0, original_mute)
	print("BOOT_MUSIC_CONTINUITY_TEST_OK")
	quit()
