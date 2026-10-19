extends SceneTree

var failures := 0
var encounter: Node
var world: Node3D
var map_mode := false
var mouth_peak := 0.0
var contacts := 0
var camera_contacts := 0
var maximum_step := 0.0
var captured: Dictionary = {}
var cinematic_only := false
var dance_obstacle: CollisionObject3D
var dance_obstacle_original_layer := 0

class FakePuzzle extends Node:
	var state := {"unlocked":false}

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func fixture() -> Node3D:
	var scene := Node3D.new()
	scene.name = "BroccoloFixture"
	var player: Node3D = load("res://scenes/player/player.tscn").instantiate()
	player.name = "Player"
	player.position = Vector3(7, 0.9, 0)
	scene.add_child(player)
	var hud := CanvasLayer.new()
	hud.name = "HUD"
	scene.add_child(hud)
	var power: Node = load("res://scripts/interactables/connesi_power.gd").new()
	power.name = "ConnesiPower"
	scene.add_child(power)
	for name in ["Entrance", "Corridor", "Chandelier"]:
		var switch := MeshInstance3D.new()
		switch.name = name
		switch.mesh = BoxMesh.new()
		switch.set_script(load("res://scripts/interactables/zone_light_switch.gd"))
		switch.power_system = power
		switch.position = Vector3(10, 1, 3) if name == "Entrance" else Vector3(10, 1, 0)
		scene.add_child(switch)
	var marker := Marker3D.new()
	marker.name = "BroccoloSpawn"
	scene.add_child(marker)
	var puzzle := FakePuzzle.new()
	puzzle.name = "AlienPuzzle"
	scene.add_child(puzzle)
	var floor_body := StaticBody3D.new()
	var floor_collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(30, .2, 10)
	floor_collision.shape = shape
	floor_body.position.y = -.1
	floor_body.add_child(floor_collision)
	scene.add_child(floor_body)
	if DisplayServer.get_name() != "headless":
		# Render isolato: solo un corridoio neutro, non una ricostruzione della mappa.
		var environment := WorldEnvironment.new()
		environment.environment = Environment.new()
		environment.environment.background_mode = Environment.BG_COLOR
		environment.environment.background_color = Color("24242c")
		environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		environment.environment.ambient_light_color = Color.WHITE
		environment.environment.ambient_light_energy = .6
		scene.add_child(environment)
		var lamp := OmniLight3D.new()
		lamp.position = Vector3(3, 2.5, 0)
		lamp.light_energy = 2.0
		lamp.omni_range = 12
		scene.add_child(lamp)
		for geometry in [Vector4(3, -.12, 0, 0), Vector4(3, 1.2, -.95, 1), Vector4(3, 1.2, .95, 1)]:
			var mesh := MeshInstance3D.new()
			var box := BoxMesh.new()
			box.size = Vector3(15, .2, 3) if geometry.w == 0 else Vector3(15, 2.4, .1)
			mesh.mesh = box
			mesh.position = Vector3(geometry.x, geometry.y, geometry.z)
			scene.add_child(mesh)
	encounter = load("res://scripts/cinematics/broccolo_encounter.gd").new()
	encounter.name = "BroccoloEncounter"
	encounter.spawn = marker
	encounter.trigger_switch = scene.get_node("Chandelier")
	encounter.entrance_switch = scene.get_node("Entrance")
	encounter.player = player
	encounter.hud = hud
	encounter.alien_puzzle_path = NodePath("../AlienPuzzle")
	scene.add_child(encounter)
	return scene

func run() -> void:
	map_mode = OS.get_cmdline_user_args().has("--map")
	cinematic_only = OS.get_cmdline_user_args().has("--cinematic-only")
	var saves := root.get_node("SaveManager")
	saves.save_path = "res://.godot/broccolo_encounter_test_slot.cfg"
	if map_mode:
		change_scene_to_file("res://scenes/maps/map_test.tscn")
		await scene_changed
		world = current_scene
		encounter = world.get_node("BroccoloEncounter")
	else:
		world = fixture()
		root.add_child(world)
		current_scene = world
	var deadline := Time.get_ticks_msec() + 40000
	while (not encounter.configured or not is_instance_valid(encounter.presentation) or not encounter.presentation.ready_for_preview or not encounter.presentation.presentation.intro_ready.is_connected(encounter._intro_finished)) and Time.get_ticks_msec() < deadline:
		await process_frame
	if not encounter.configured or not is_instance_valid(encounter.presentation) or not encounter.presentation.ready_for_preview:
		check(false, "Broccolo setup timeout")
		quit(1)
		return
	var player: CharacterBody3D = encounter.player
	var interaction: Node = player.get_node("InteractionSystem")
	var weapon: Node = player.get_node("Head/Camera3D/WeaponHolder")
	if map_mode:
		var combat_component: Node = world.get_node("BroccoloEncounter/BroccoloMinionSpawner")
		var combat_deadline := Time.get_ticks_msec() + 60000
		while not combat_component.ready_for_test and Time.get_ticks_msec() < combat_deadline:
			await process_frame
		check(combat_component.ready_for_test, "Preparazione Broccolo in mappa completata")
		check(combat_component.burn_status == player.get_node("BroccoloBurnStatus"), "Bruciatura collegata al player reale della mappa")
		check(combat_component.get_node("MainBroccolo").power_fx != null and not combat_component.reserve.is_empty() and combat_component.reserve[0].power_fx != null,
			"Aura principale e copie della mappa usano gli effetti approvati")
		check(combat_component.energy_visual_scene != null, "La sfera usa la grafica approvata anche in mappa")
		world.get_node("AngelastriEncounter").set_process(false)
		world.get_node("BrunoBuozzi").set_physics_process(false)
		# Posizione libera accanto al lampadario che avvia la cinematica.
		player.global_position = Vector3(7.0, .9, -3.8)
	var power: Node = world.get_node("ConnesiPower")
	var trigger: Node = encounter.trigger_switch
	var corridor: Node = world.get_node("Interruttore Luce Corridoio Magazzino" if map_mode else "Corridor")
	var entrance: Node = encounter.entrance_switch
	var puzzle: Node = encounter.get_node(encounter.alien_puzzle_path)
	check(not encounter.presentation.visible and not encounter.cinematic, "Attore e cinema inattivi prima del trigger")
	check(encounter.presentation.get_children().filter(func(n):return n is WorldEnvironment or n is Camera3D or n is DirectionalLight3D).is_empty(), "Nessun ambiente o camera dello studio nella mappa")
	trigger.try_toggle_lights()
	check(not encounter.cinematic, "Niente trigger senza corrente")
	power.turn_on()
	trigger.try_toggle_lights()
	check(not encounter.cinematic, "Niente trigger prima dello sblocco alieno")
	puzzle.state.unlocked = true
	trigger.try_toggle_lights()
	trigger.try_toggle_lights()
	check(not encounter.cinematic, "Luce ingresso ancora spenta non avvia la cinematica")
	entrance.try_toggle_lights()
	check(not encounter.cinematic, "Luce ingresso non e il trigger")
	corridor.try_toggle_lights()
	check(not encounter.cinematic, "Il vecchio interruttore corridoio non avvia Broccolo")
	trigger.apply_persistent_state({"lights_on":true})
	check(not encounter.cinematic, "Restore luci non avvia la cinematica")
	trigger.try_toggle_lights()
	var player_pose := player.global_transform
	var fov: float = encounter.player_camera.fov
	var player_camera_pose: Transform3D = encounter.player_camera.global_transform
	trigger.try_toggle_lights()
	check(encounter.cinematic and not player.is_physics_processing() and not player.is_processing_unhandled_input(), "Accensione lampadario blocca il player")
	if not is_instance_valid(encounter.camera):
		quit(maxi(failures, 1))
		return
	check(is_instance_valid(encounter.ringtone_player) and encounter.ringtone_player.playing,
		"La suoneria parte subito quando il comando luce avvia la cinematica")
	check(encounter.answer_at_ringtone_seconds > encounter.answer_seconds and encounter.synchronize_camera_to_ringtone_answer,
		"La regia usa il cue della suoneria come orologio comune per animazione e camera")
	check(encounter.camera.global_transform.is_equal_approx(player_camera_pose), "La camera parte dalla posa FPS esatta")
	var expected_corridor_axis: Vector3 = (trigger.global_position - entrance.global_position).normalized()
	check(encounter.camera_travel_axis.dot(expected_corridor_axis) > 0.99, "La camera usa l'asse ingresso-lampadario come direzione del corridoio")
	var quarter_camera_sample: Vector3 = encounter._camera_path_position(0.25)
	var halfway_camera_sample: Vector3 = encounter._camera_path_position(0.5)
	var turn_camera_sample: Vector3 = encounter._camera_path_position(1.0)
	check(quarter_camera_sample.distance_to(encounter.camera_path_start) > 0.01 and turn_camera_sample.is_equal_approx(encounter.camera_path_end),
		"Il dolly rettilineo collega la visuale FPS al marker di arresto")
	if map_mode:
		check(encounter.camera_stop_marker != null and is_equal_approx(encounter.camera_path_end.x, encounter.camera_stop_marker.global_position.x) and
			is_equal_approx(encounter.camera_path_end.z, encounter.camera_stop_marker.global_position.z),
			"La camera termina esattamente sul marker utente in X/Z")
	var route_axis: Vector3 = (encounter.camera_path_end - encounter.camera_path_start).normalized()
	check((halfway_camera_sample - encounter.camera_path_start).cross(route_axis).length() < 0.01,
		"La camera segue una linea retta fino al marker")
	check(encounter._smooth_cinematic(0.1) < 0.02 and encounter._smooth_cinematic(0.9) > 0.98,
		"La curva parte e termina senza scatti di velocita'")
	check(encounter.camera_path_end.distance_to(encounter.presentation.actor.global_position) > 1.0,
		"La posa finale della camera resta separata dal corpo di Broccolo")
	var turn_camera_forward: Vector3 = encounter._camera_path_forward(1.0, turn_camera_sample)
	var turn_target_direction: Vector3 = (encounter._shot_target() - turn_camera_sample).normalized()
	check(turn_camera_forward.dot(turn_target_direction) > 0.85,
		"La camera completa la svolta orientandosi verso Broccolo")
	var initial_forward: Vector3 = -player_camera_pose.basis.z
	var final_rotation_angle := rad_to_deg(initial_forward.angle_to(turn_camera_forward))
	var halfway_forward: Vector3 = encounter._camera_path_forward(0.5, halfway_camera_sample)
	check(final_rotation_angle > 15.0 and initial_forward.angle_to(halfway_forward) > 0.01,
		"La rotazione verso Broccolo comincia durante l'avanzamento e completa al marker")
	check(not weapon.is_processing() and not weapon.visible and not encounter.hud.visible and not interaction.is_processing(), "Armi HUD interazione bloccati")
	check(encounter.blocks_saving(), "Salvataggio bloccato durante introduzione")
	var studio: Node = encounter.presentation
	var phone: Node = studio.phone
	check(studio.animation.assigned_animation == &"mie/idle" and studio.animation.is_playing() and
		studio.animation.get_animation(&"mie/idle").loop_mode == Animation.LOOP_LINEAR,
		"Broccolo resta in idle ciclico durante l'avvicinamento della camera")
	phone.thrown_phone_floor_contacted.connect(func(): captured["phone_ground_contact"] = true)
	var cue_wait := 0.0
	var idle_advanced := false
	while studio.presentation.stage != "answer" and cue_wait < 12.0:
		await process_frame
		cue_wait += encounter.get_process_delta_time()
		if studio.animation.assigned_animation == &"mie/idle" and studio.animation.current_animation_position > 0.1:
			idle_advanced = true
	check(idle_advanced, "L'idle continua ad animarsi mentre la camera percorre il corridoio")
	check(studio.presentation.stage == "answer" and encounter.presentation_reveal_started,
		"L'animazione di risposta parte sul cue anticipato della suoneria")
	check(studio.animation.assigned_animation == &"mie/phone_answer_talk",
		"Il cue della suoneria interrompe l'idle e avvia la risposta")
	if studio.presentation.stage == "answer":
		var answer_animation_cue: float = encounter.ringtone_player.get_playback_position()
		check(absf(answer_animation_cue - (encounter.answer_at_ringtone_seconds - encounter.answer_seconds)) < 0.35,
			"L'animazione inizia con l'anticipo configurato rispetto alla risposta telefonica")
		check(encounter._camera_sees_broccolo(), "Quando parte la risposta Broccolo e' gia' inquadrato con visuale libera")
	for clip_name: StringName in [&"mie/phone_answer_talk", &"mie/trow2", &"mie/walking"]:
		var source_clip: Animation = studio.curves[clip_name]
		var runtime_clip: Animation = studio.animation.get_animation(clip_name)
		for track in runtime_clip.get_track_count():
			var track_path := runtime_clip.track_get_path(track)
			if runtime_clip.track_get_type(track) != Animation.TYPE_POSITION_3D or track_path.get_subname_count() == 0 or track_path.get_subname(0) != &"mixamorig1_Hips":continue
			var source_start: Vector3 = source_clip.position_track_interpolate(track, 0.0)
			var runtime_start: Vector3 = runtime_clip.position_track_interpolate(track, 0.0)
			check(source_start.is_equal_approx(runtime_start), "Root motion conserva la posa iniziale delle anche in " + String(clip_name))
	var original_phone_mesh: Transform3D = phone.phone_visual.get_node("Object_2").transform
	var original_phone_parent: Node = phone.phone_visual.get_parent()
	var original_phone_transform: Transform3D = phone.phone_visual.transform
	check(phone.phone_visual.visible, "Telefono visibile nella mano durante la risposta")
	if not encounter.route_ready:
		check(false, "Nessun percorso sicuro preparato")
		quit(1)
		return
	var elapsed := 0.0
	var last_position: Vector3 = studio.actor.global_position
	var first_position := last_position
	var camera_shape := SphereShape3D.new()
	camera_shape.radius = encounter.camera_collision_radius
	var camera_query := PhysicsShapeQueryParameters3D.new()
	camera_query.shape = camera_shape
	camera_query.collision_mask = 1
	var seen_throw := false
	var paused := false
	var throw_audio_valid := true
	var hidden_at_throw := false
	var launched_copy: Node3D
	var launched_copy_origin := Vector3.ZERO
	var launched_copy_moved := false
	var launched_copy_at := -1.0
	var checked_throw_visibility := false
	var ring_answer_checked := false
	check(phone.throw_lifetime_seconds >= 8.0, "Il lancio mantiene un failsafe se non raggiunge il pavimento")
	while not encounter.intro_completed and elapsed < 45:
		await process_frame
		elapsed += encounter.get_process_delta_time()
		mouth_peak = maxf(mouth_peak, studio.head.get_blend_shape_value(0))
		maximum_step = maxf(maximum_step, studio.actor.global_position.distance_to(last_position))
		last_position = studio.actor.global_position
		if map_mode:
			var shape := CapsuleShape3D.new()
			shape.radius = .28
			shape.height = 1.6
			var query := PhysicsShapeQueryParameters3D.new()
			query.shape = shape
			query.transform.origin = last_position + Vector3.UP * .9
			query.collision_mask = 1
			query.exclude = [player.get_rid()]
			var hit := player.get_world_3d().direct_space_state.intersect_shape(query)
			if not hit.is_empty():
				contacts += 1
				if contacts < 4:print("BROCCOLO_ROUTE_CONTACT ", last_position," ",hit[0].collider.get_path())
			if is_instance_valid(encounter.camera):
				camera_query.transform = Transform3D(Basis.IDENTITY, encounter.camera.global_position)
				camera_query.exclude = encounter._camera_exclusions()
				var camera_hits := player.get_world_3d().direct_space_state.intersect_shape(camera_query, 1)
				if not camera_hits.is_empty():
					camera_contacts += 1
					if camera_contacts < 4:
						print("BROCCOLO_CAMERA_CONTACT ", encounter.camera.global_position," ",camera_hits[0].collider.get_path())
		if studio.presentation.stage == "phone" and not ring_answer_checked:
			ring_answer_checked = true
			check(encounter.camera.global_position.distance_to(encounter.camera_path_end) < 0.15,
				"La camera arriva al marker insieme al cue di risposta della suoneria")
			check(not encounter.ringtone_player.playing,
				"La suoneria si interrompe quando Broccolo risponde")
			check(absf(encounter.ring_answer_position - encounter.answer_at_ringtone_seconds) < 0.75,
				"La risposta avviene vicino al cue configurato nella suoneria")
			check(studio.voice.playing and studio.voice.get_playback_position() < 0.5,
				"La voce di Broccolo parte insieme alla risposta al telefono")
			await capture("phone")
		if studio.presentation.stage == "answer" and not captured.has("first_camera_sightline"):
			captured["first_camera_sightline"] = true
			var camera_target: Vector3 = encounter._shot_target()
			var sightline := PhysicsRayQueryParameters3D.create(encounter.camera.global_position, camera_target, 1)
			sightline.exclude = encounter._camera_exclusions()
			check(player.get_world_3d().direct_space_state.intersect_ray(sightline).is_empty(),
				"Dopo la svolta a sinistra la camera ha visuale libera su Broccolo")
		if studio.presentation.stage == "throw":
			seen_throw = true
			check(studio.voice.get_playback_position() >= 23.0, "Pausa voce spostata a23secondi")
			throw_audio_valid = throw_audio_valid and studio.voice.stream_paused
			if studio.animation.current_animation_position < phone.hide_at_throw_seconds:
				check(phone.phone_visual.visible, "Telefono resta in mano prima del gesto di lancio")
			elif not hidden_at_throw:
				hidden_at_throw = true
				check(not phone.phone_visual.visible, "Telefono nascosto al momento del lancio")
				check(phone.phone_visual.get_parent() == original_phone_parent and phone.phone_visual.transform.is_equal_approx(original_phone_transform), "Telefono originale resta agganciato e invariato")
				launched_copy = phone.thrown_phone
				check(is_instance_valid(launched_copy), "La copia separata appare al lancio")
				if is_instance_valid(launched_copy):
					launched_copy_at = elapsed
					launched_copy_origin = launched_copy.global_position
				check(phone.throw_direction_from_hand, "La direzione del lancio segue il gesto della mano")
				check(launched_copy.linear_velocity.dot(phone.last_throw_direction) > 0.0 and launched_copy.linear_velocity.y > 0.0, "Il telefono parte nella direzione del gesto e verso l'alto")
		if is_instance_valid(launched_copy) and launched_copy.global_position.distance_to(launched_copy_origin) > 0.05:
			launched_copy_moved = true
			if not paused:
				paused = true
				var before: float = studio.voice.get_playback_position()
				var actor_before: Vector3 = studio.actor.global_position
				get_tree_pause(true)
				await create_timer(.25, true).timeout
				check(absf(studio.voice.get_playback_position() - before) < .06 and studio.actor.global_position.is_equal_approx(actor_before), "Pausa congela voce e movimento")
				get_tree_pause(false)
		if launched_copy_at >= 0.0 and not checked_throw_visibility and elapsed - launched_copy_at >= 0.3:
			checked_throw_visibility = true
			check(is_instance_valid(launched_copy), "La copia resta visibile durante il volo")
			if is_instance_valid(launched_copy):
				check(launched_copy.global_position.y > 0.05, "La copia resta sopra il pavimento durante il volo visibile")
		if studio.presentation.stage == "walk" and not captured.has("walk"):await capture("walk")
	check(encounter.intro_completed and seen_throw, "Telefonata lancio camminata completati")
	check(ring_answer_checked, "La telefonata raggiunge il cue di risposta sincronizzato")
	check(captured.has("first_camera_sightline"), "La prima camera viene verificata con una linea di vista libera")
	check(hidden_at_throw and not phone.phone_visual.visible, "Telefono resta nascosto dopo il gesto")
	check(checked_throw_visibility, "Il test ha verificato la durata visibile del lancio")
	check(captured.has("phone_ground_contact"), "Il telefono urta il pavimento prima di sparire")
	check(launched_copy_moved, "La copia del telefono si muove lungo la traiettoria di lancio")
	check(not is_instance_valid(launched_copy), "La copia lanciata scompare dopo il volo breve")
	check(phone.phone_visual.get_parent() == original_phone_parent and phone.phone_visual.transform.is_equal_approx(original_phone_transform), "Telefono mantiene aggancio e trasformazione della scena")
	check(phone.phone_visual.get_node("Object_2").transform.is_equal_approx(original_phone_mesh), "Scala e allineamento salvati dell'utente restano invariati")
	check(throw_audio_valid, "Voce sospesa durante tutto il lancio, anche dopo pausa globale")
	check(mouth_peak > .02, "Voce reale muove la bocca")
	check(maximum_step < .3, "Continuita root motion tra clip")
	check(studio.actor.global_position.distance_to(first_position) > 3.0, "Movimento reale nel corridoio")
	check(contacts == 0, "Percorso libero da pareti e porte della mappa")
	if map_mode:check(camera_contacts == 0, "La camera resta fuori dagli ostacoli della mappa durante il dolly")
	check(player.global_transform.is_equal_approx(player_pose), "Cinematica conserva trasformazione del player bloccato")
	await create_timer(1.2).timeout
	check(not encounter.cinematic and player.is_physics_processing() and player.is_processing_unhandled_input(), "Controlli restituiti dopo intro")
	check(studio.animation.assigned_animation == &"mie/idle" and studio.animation.is_playing(), "Broccolo passa subito a idle loop prima di restituire il controllo")
	var idle_direction_to_player: Vector3 = encounter.player_camera.global_position - studio.actor.global_position
	idle_direction_to_player.y = 0.0
	check(encounter.pending_idle_facing or studio.actor.global_basis.z.dot(idle_direction_to_player.normalized()) > 0.95,
		"Broccolo si riallinea solo dopo essere uscito dall'inquadratura, senza scatto visibile")
	check(weapon.visible and weapon.is_processing() and encounter.hud.visible and interaction.is_processing(), "HUD armi interazione ripristinati")
	check(encounter.player_camera.current and is_equal_approx(encounter.player_camera.fov,fov), "Camera FPS ripristinata")
	# Dopo lo sblocco il solver puo correggere un punto di test vicino a un muro.
	print("BROCCOLO_PLAYER_RETURN before=",player_pose.origin," after=",player.global_position)
	await capture("final")
	var state: Dictionary = encounter.get_persistent_state()
	var final: Transform3D = studio.actor.global_transform
	trigger.try_toggle_lights()
	trigger.try_toggle_lights()
	check(not encounter.cinematic, "Intro avviene una sola volta")
	encounter.apply_persistent_state(state)
	await process_frame
	check(not phone.phone_visual.visible, "Checkpoint conserva il telefono nascosto senza riapparire in mano")
	check(studio.visible and studio.actor.global_transform.is_equal_approx(final) and not studio.voice.playing, "Restore completato conserva posizione idle senza rigiocare voce")
	check(studio.presentation.stage == "" and not studio.music.playing, "Secondo dialogo danza e battaglia non partono")
	encounter.apply_persistent_state({"intro_completed":false})
	trigger.try_toggle_lights()
	trigger.try_toggle_lights()
	check(encounter.cinematic, "Stato non completato puo riattivare la prima intro")
	encounter.apply_persistent_state({"intro_completed":false})
	check(not encounter.cinematic and player.is_physics_processing() and weapon.visible and not studio.visible, "Interruzione/restore in corso rilascia i controlli e nasconde l'attore")
	encounter.apply_persistent_state(state)
	player.global_position = studio.actor.global_position + Vector3(2.0, 0.9, 0.0)
	encounter.player_camera.look_at(studio.actor.global_position + Vector3.UP * encounter.camera_target_height, Vector3.UP)
	await process_frame
	check(encounter.second_presentation_started and encounter.cinematic, "Avvicinarsi a Broccolo avvia la seconda cinematica e blocca il player")
	var second_camera_position: Vector3 = encounter.camera.global_position
	var second_actor_position: Vector3 = studio.actor.global_position
	check(encounter.camera_path_start.is_equal_approx(encounter.camera_path_turn) and encounter.camera_path_start.is_equal_approx(encounter.camera_path_end),
		"La seconda cinematica conserva la posizione del giocatore invece di avviare il dolly a sinistra")
	check(encounter._camera_path_position(0.5).is_equal_approx(second_camera_position), "La camera del secondo incontro non attraversa la corsia")
	var discourse_wait := 0.0
	while studio.presentation.stage != "dialogue" and discourse_wait < 5.0:
		await process_frame
		discourse_wait += encounter.get_process_delta_time()
	check(studio.presentation.stage == "dialogue", "Il secondo discorso parte dopo che la camera lo inquadra")
	check(discourse_wait <= 0.1, "Il dialogo parte insieme alla camera, senza idle d'attesa")
	if studio.presentation.stage == "dialogue":
		var target_direction: Vector3 = (studio.actor.global_position + Vector3.UP * encounter.camera_target_height - encounter.camera.global_position).normalized()
		check((-encounter.camera.global_basis.z).dot(target_direction) > 0.9, "La seconda camera punta direttamente a Broccolo")
		var toward_player: Vector3 = encounter.player_camera.global_position - studio.actor.global_position
		toward_player.y = 0.0
		check(studio.actor.global_basis.z.dot(toward_player.normalized()) > 0.95, "Il fronte +Z del modello Broccolo guarda il giocatore prima del discorso")
		await create_timer(1.5).timeout
		var toward_player_after_animation: Vector3 = encounter.player_camera.global_position - studio.actor.global_position
		toward_player_after_animation.y = 0.0
		check(studio.actor.global_basis.z.dot(toward_player_after_animation.normalized()) > 0.95, "Il fronte di Broccolo resta rivolto al giocatore durante il discorso")
		var transition_wait := 0.0
		while studio.animation.assigned_animation != &"mie/talk2" and transition_wait < 5.0:
			await process_frame
			transition_wait += encounter.get_process_delta_time()
		check(studio.animation.assigned_animation == &"mie/talk2", "La sequenza passa da talk1 a talk2")
		check(studio.animation.assigned_animation != &"mie/talk3", "La sequenza dialogo esclude talk3")
		check(encounter.camera.global_position.distance_to(second_camera_position) < 0.01, "La camera del secondo incontro resta nella posizione iniziale")
		var player_camera_start: Vector3 = encounter.player_camera.global_position
		var dance_start_position: Vector3 = studio.actor.global_position
		if map_mode:
			dance_obstacle = encounter.get_node_or_null(encounter.dance_obstacle_collision_path) as CollisionObject3D
			if is_instance_valid(dance_obstacle):dance_obstacle_original_layer = dance_obstacle.collision_layer
		var camera_left: Vector3 = -encounter.camera.global_basis.x
		camera_left.y = 0.0
		camera_left = camera_left.normalized()
		studio.presentation._begin_dance()
		var dance_side_step: Vector3 = studio.actor.global_position - dance_start_position
		check(dance_side_step.dot(camera_left) >= encounter.dance_screen_left_offset * 0.9,
			"Broccolo si sposta leggermente verso sinistra nell'inquadratura prima della danza")
		await process_frame
		if map_mode:
			check(is_instance_valid(dance_obstacle), "Il collider dello scaffale coreografico esiste nella mappa")
			if is_instance_valid(dance_obstacle):
				check(encounter.dance_obstacle_collision_disabled and dance_obstacle.collision_layer == 0,
					"Durante la danza viene disattivato temporaneamente il collider dello scaffale")
				check(encounter._camera_exclusions().has(dance_obstacle.get_rid()),
					"La camera esclude solo lo scaffale disattivato e continua a verificare gli altri ostacoli")
		var dance_sample_elapsed := 0.0
		var dance_path_contacts := 0
		var dance_path_length := 0.0
		var dance_path_previous: Vector3 = studio.actor.global_position
		var pre_jump_position := dance_start_position
		var saw_dancing3 := false
		var saw_dancing2 := false
		var saw_dancing := false
		var dance_contact_name := ""
		var dance_capsule := CapsuleShape3D.new()
		dance_capsule.radius = 0.4
		dance_capsule.height = 1.6
		var path_query := PhysicsShapeQueryParameters3D.new()
		path_query.shape = dance_capsule
		path_query.collision_mask = 1
		path_query.exclude = [player.get_rid(), studio.actor.get_rid()]
		# Esegue la coreografia nell'ordine del sequencer: dancing3, dancing2, dancing.
		# Si ferma alla fine dello stage, prima di eventuale rimpicciolimento/combat.
		while studio.presentation.stage == "dance" and dance_sample_elapsed < 45.0:
			await process_frame
			dance_sample_elapsed += encounter.get_process_delta_time()
			var clip_name := StringName(studio.animation.assigned_animation)
			if clip_name == &"mie/dancing3":saw_dancing3 = true
			elif clip_name == &"mie/dancing2":saw_dancing2 = true
			elif clip_name == &"mie/dancing":
				if not saw_dancing:pre_jump_position = studio.actor.global_position
				saw_dancing = true
			dance_path_length += studio.actor.global_position.distance_to(dance_path_previous)
			dance_path_previous = studio.actor.global_position
			if map_mode:
				path_query.transform.origin = studio.actor.global_position + Vector3.UP * 0.9
				var contacts := player.get_world_3d().direct_space_state.intersect_shape(path_query, 1)
				if not contacts.is_empty():
					dance_path_contacts += 1
					if dance_contact_name.is_empty():dance_contact_name = String(contacts[0].collider.name)
		check(saw_dancing3 and saw_dancing2 and saw_dancing, "La coreografia esegue le tre clip previste in ordine")
		check(pre_jump_position.distance_to(dance_start_position) > 0.2,
			"Broccolo percorre spazio durante dancing3/dancing2, prima del salto finale")
		check(dance_path_length > 2.5 and dance_path_length < 4.1,
			"La danza conserva un avanzamento proporzionato al corridoio senza percorrere tutti i 7 metri originali")
		print("BROCCOLO_DANCE_ROOT_MOTION distance=", dance_path_length, " pre_jump=", pre_jump_position.distance_to(dance_start_position), " contacts=", dance_path_contacts, " first_collider=", dance_contact_name)
		if map_mode:check(dance_path_contacts == 0, "Il percorso completo delle tre danze resta libero da armadio e scaffali")
		check(encounter.camera.global_position.distance_to(second_camera_position) > 0.02,
			"Durante la danza la seconda camera arretra gradualmente da Broccolo")
		check(encounter.dance_camera_retreat_path.size() == 2,
			"La camera segue un unico tratto rettilineo, senza curve o waypoint laterali")
		if encounter.dance_camera_retreat_path.size() == 2:
			var retreat_direction: Vector3 = (encounter.dance_camera_retreat_path[1] - encounter.dance_camera_retreat_path[0]).normalized()
			var direct_direction: Vector3 = encounter.intro_camera_turn_position - second_camera_position
			direct_direction.y = 0.0
			check(retreat_direction.dot(direct_direction.normalized()) > 0.98,
				"Il retreat segue in linea retta il corridoio fino alla svolta iniziale")
		check(encounter.camera.global_position.distance_to(studio.actor.global_position) > 2.0,
			"La camera mantiene spazio da Broccolo alla fine della coreografia")
		check(encounter.player_camera.global_position.distance_to(encounter.camera.global_position) < 0.05,
			"Il player arretra insieme alla camera e resta nella sua posa")
		var retreat_target: Vector3 = (encounter._shot_target() - encounter.camera.global_position).normalized()
		check((-encounter.camera.global_basis.z).dot(retreat_target) > 0.85,
			"La camera arretrata continua a inquadrare Broccolo mentre avanza")
		if map_mode:
			var retreat_camera_shape := SphereShape3D.new()
			retreat_camera_shape.radius = encounter.camera_collision_radius
			var retreat_camera_query := PhysicsShapeQueryParameters3D.new()
			retreat_camera_query.shape = retreat_camera_shape
			retreat_camera_query.transform = Transform3D(Basis.IDENTITY, encounter.camera.global_position)
			retreat_camera_query.collision_mask = encounter._camera_collision_mask()
			retreat_camera_query.exclude = encounter._camera_exclusions()
			check(player.get_world_3d().direct_space_state.intersect_shape(retreat_camera_query, 1).is_empty(),
				"La camera resta fuori da pareti e arredi durante l'arretramento")
			var final_dance_query := PhysicsShapeQueryParameters3D.new()
			var final_dance_capsule := CapsuleShape3D.new()
			final_dance_capsule.radius = 0.4
			final_dance_capsule.height = 1.6
			final_dance_query.shape = final_dance_capsule
			final_dance_query.collision_mask = 1
			final_dance_query.exclude = [player.get_rid(), studio.actor.get_rid()]
			final_dance_query.transform.origin = studio.actor.global_position + Vector3.UP * 0.9
			var dance_hits := player.get_world_3d().direct_space_state.intersect_shape(final_dance_query, 1)
			if not dance_hits.is_empty():print("BROCCOLO_DANCE_CONTACT position=", studio.actor.global_position, " collider=", dance_hits[0].collider.get_path())
			check(dance_hits.is_empty(),
				"La posa raggiunta dalla danza resta libera dagli ostacoli della mappa")
	if cinematic_only:
		# Simula il termine della coreografia: camera e player devono aver completato
		# lo stesso arretramento prima di restituire i controlli.
		encounter.dance_camera_retreat_elapsed = encounter.dance_camera_retreat_seconds
		var retreat_wait := 0.0
		var retreat_endpoint: Vector3 = encounter.dance_camera_retreat_path.back() if not encounter.dance_camera_retreat_path.is_empty() else encounter.dance_camera_retreat_origin
		while encounter.camera.global_position.distance_to(retreat_endpoint) > 0.02 and retreat_wait < 2.5:
			await process_frame
			retreat_wait += encounter.get_process_delta_time()
		var final_camera_position: Vector3 = encounter.camera.global_position
		var completed_retreat := (final_camera_position - second_camera_position).dot(encounter.dance_camera_retreat_axis)
		check(completed_retreat > 1.5, "Camera e player arretrano lasciando spazio alla danza senza superare l'angolo")
		print("BROCCOLO_CAMERA_RETREAT_RESULT distance=", completed_retreat, " actor_gap=", final_camera_position.distance_to(studio.actor.global_position), " camera=", final_camera_position, " actor=", studio.actor.global_position)
		if map_mode:check(final_camera_position.distance_to(studio.actor.global_position) > 2.0,
			"L'endpoint della cinematic lascia aria tra camera e Broccolo")
		if map_mode:
			var final_camera_shape := SphereShape3D.new()
			final_camera_shape.radius = encounter.camera_collision_radius
			var final_camera_query := PhysicsShapeQueryParameters3D.new()
			final_camera_query.shape = final_camera_shape
			final_camera_query.transform = Transform3D(Basis.IDENTITY, final_camera_position)
			final_camera_query.collision_mask = encounter._camera_collision_mask()
			final_camera_query.exclude = encounter._camera_exclusions()
			check(player.get_world_3d().direct_space_state.intersect_shape(final_camera_query, 1).is_empty(),
				"La posizione finale arretrata della camera resta libera dagli ostacoli")
		var player_position_before_return: Vector3 = player.global_position
		encounter.release_after_intro()
		await create_timer(encounter.camera_blend_seconds + 0.2).timeout
		var player_camera_return_position: Vector3 = encounter.player_camera.global_position
		player_camera_return_position.y = 0.0
		var final_camera_horizontal := final_camera_position
		final_camera_horizontal.y = 0.0
		var player_root_return_delta: Vector3 = player.global_position - player_position_before_return
		player_root_return_delta.y = 0.0
		check(not encounter.cinematic and encounter.player_camera.current,
			"A fine regia viene ripristinata la camera del player")
		check(player_camera_return_position.distance_to(final_camera_horizontal) < 0.05,
			"A fine regia il player rimane dove si era ritirata la camera")
		var total_player_retreat: Vector3 = player.global_position - player_pose.origin
		total_player_retreat.y = 0.0
		check(total_player_retreat.length() > 0.1,
			"Il player compie fisicamente l'arretramento della seconda cinematica")
		check(player_root_return_delta.length() < 0.01,
			"Il rientro alla visuale FPS non sposta di nuovo il player")
		if map_mode and is_instance_valid(dance_obstacle):
			check(not encounter.dance_obstacle_collision_disabled and dance_obstacle.collision_layer == dance_obstacle_original_layer,
				"Il layer di collisione dello scaffale viene ripristinato al ritorno del controllo")
		print("BROCCOLO_CINEMATIC_ONLY failures=", failures, " map=", map_mode)
		quit(failures)
		return
	encounter._combat_ready()
	var spawner := encounter.get_node_or_null("BroccoloMinionSpawner")
	if map_mode and is_instance_valid(spawner):
		var combat_start_deadline := Time.get_ticks_msec() + 60000
		while not spawner.started and Time.get_ticks_msec() < combat_start_deadline:
			await process_frame
		check(spawner.started, "La configurazione della lotta mappa completa l'handoff")
		var main_boss: Node = spawner.boss
		check(main_boss.state == "shrink", "Il corpo principale avvia la sua unica riduzione prima della lotta")
		await physics_frame
		check(main_boss.power_fx.visible and main_boss.power_fx.transforming,
			"L'aura approvata si accende durante la riduzione in mappa")
		var shrink_deadline := Time.get_ticks_msec() + 5000
		while main_boss.state == "shrink" and Time.get_ticks_msec() < shrink_deadline:
			await process_frame
		check(main_boss.state == "chase" and is_equal_approx(main_boss.visual.scale.x, main_boss.miniature_scale),
			"Il boss termina la trasformazione alla scala di combattimento")
		var wave_deadline := Time.get_ticks_msec() + 8000
		while spawner.active_minions.size() < 2 and Time.get_ticks_msec() < wave_deadline:
			await process_frame
	else:
		await create_timer(1.3).timeout
	check(not encounter.cinematic and is_instance_valid(spawner), "Dopo la danza il controllo ritorna e si attiva lo spawner")
	if is_instance_valid(spawner):
		var minions: Array = spawner.active_minions
		check(minions.size() >= 2 and minions.size() <= 3, "La prima ondata contiene due o tre minion")
		if not minions.is_empty():
			var minion: CharacterBody3D = minions[0]
			check(minion.has_method("take_bullet_hit") and minion.has_method("take_damage"), "I minion ricevono i colpi con l'interfaccia delle armi")
			check(is_equal_approx(minion.get_node("Broccolo").scale.x, minion.miniature_scale), "Il clone usa la scala configurata dal profilo")
			minion.take_damage(99)
	print("BROCCOLO_ENCOUNTER_TEST failures=", failures," map=",map_mode," contacts=",contacts," camera_contacts=",camera_contacts," max_step=",maximum_step," final=",final.origin," mouth=",mouth_peak)
	quit(failures)

func get_tree_pause(value: bool) -> void:
	paused = value

func capture(name: String) -> void:
	captured[name] = true
	if DisplayServer.get_name() == "headless":return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/broccolo_map_"+name+".png")
