extends Node
## Prima introduzione nella zona magazzino. Secondo dialogo e combattimento non avviati.

signal introduction_finished(actor_pose: Transform3D)

@export_group("Collegamenti")
## Marker dell'utente vicino a Porta Produzione; non viene spostato dallo script.
@export var spawn: Marker3D
## Punto X/Z di arresto camera nel corridoio; l'altezza viene presa dalla camera FPS.
@export var camera_stop_marker: Marker3D
## Interruttore di avvio: nella mappa e il Lampadario Magazzino, non il corridoio.
@export var trigger_switch: Node3D
## La luce ingresso deve essere accesa prima del comando del lampadario.
@export var entrance_switch: Node3D
## Circuito del corridoio da accendere quando inizia la cinematica.
@export var corridor_lights_switch: Node3D
## Player FPS da bloccare durante la cinematica.
@export var player: CharacterBody3D
## HUD da nascondere temporaneamente, conservando lo stato precedente.
@export var hud: CanvasLayer
## Percorso del puzzle porta aliena, relativo a questo controller; richiede state.unlocked.
@export var alien_puzzle_path := NodePath("../RegiaIntegration/NetworkPuzzle")
## Presentazione condivisa con lo studio, in modalita mappa senza ambiente/camera/UI di prova.
@export var presentation_scene: PackedScene = preload("res://scenes/cinematics/broccolo_map_presentation.tscn")

@export_group("Posizionamento e movimento")
## Rotazione aggiuntiva rispetto al marker: 90 gradi porta il percorso lungo il corridoio (+X).
@export_range(-180.0, 180.0, 1.0) var actor_yaw_degrees := -90.0
## Correzione del fronte visivo del modello importato quando guarda il player nella seconda cinematic.
@export_range(-180.0, 180.0, 1.0) var actor_facing_offset_degrees := 180.0
## Cerca una piccola correzione della direzione per evitare scaffali/pareti, senza spostare il marker.
@export var avoid_route_obstacles := true
## Raggio di sicurezza per campionare il percorso del corpo (m).
@export_range(0.2, 0.6, 0.01) var route_clearance := 0.32
## Massimo assestamento laterale dello spawn per trovare una corsia libera (m), marker intatto.
@export_range(0.0, 0.8, 0.05) var max_lane_adjustment := 0.6
## Appoggia l'origine ai piedi sul pavimento sotto il marker, mantenendo X/Z.
@export var snap_to_floor := true
## Offset verticale rispetto al pavimento (m), per eventuale correzione dei piedi.
@export_range(-0.5, 0.5, 0.01) var floor_offset := 0.0
## Scala dei soli spostamenti root-motion; 1 conserva le distanze delle clip.
@export_range(0.1, 1.5, 0.05) var motion_scale := 1.0
## Riduce le sole deviazioni laterali della traiettoria nello stretto corridoio; avanti/indietro invariati.
@export_range(0.0, 1.0, 0.05) var lateral_motion_scale := 0.2
## Scala uniformemente il moto root delle tre clip di danza; la durata e i gesti restano invariati.
@export_range(0.1, 1.0, 0.05) var dance_motion_scale := 0.5
## Raggio della capsula che impedisce alla danza di compenetrare pareti/arredi (m).
@export_range(0.2, 0.8, 0.01) var dance_collision_radius := 0.4
## Altezza della capsula per il controllo del percorso di danza (m).
@export_range(1.0, 2.1, 0.05) var dance_collision_height := 1.6
## Sposta tutta la coreografia verso sinistra nell'inquadratura, lontano dalla parete destra.
@export_range(0.0, 0.75, 0.05) var dance_screen_left_offset := 0.05
## Sposta Broccolo a destra nell'inquadratura prima del secondo discorso, se la posa e' libera.
@export_range(0.0, 0.8, 0.05) var second_presentation_screen_right_offset := 0.0
## Collider del mobile da disattivare solo durante la seconda cinematic e ripristinare al ritorno FPS.
@export var dance_obstacle_collision_path := NodePath("../connesi_building_test2_addon_1/ScaffaleMagazzino/StaticBody3D")
## Numero di cicli walking dopo il lancio; default approvato nello studio: tre.
@export_range(1, 10, 1) var walk_cycles := 3

@export_group("Tempi e voce")
## Anticipo del gesto di risposta rispetto alla voce (secondi).
@export_range(0.0, 5.0, 0.1) var answer_seconds := 3.5
## Secondo della voce al quale sospenderla per il lancio del telefono.
@export_range(0.0, 60.0, 0.1) var throw_voice_seconds := 23.0
## Durata della sfumatura tra gesti (secondi).
@export_range(0.1, 1.5, 0.05) var animation_blend_seconds := 0.55
## Volume della voce in dB sul bus SFX.
@export_range(-30.0, 12.0, 0.5) var voice_volume_db := 0.0

@export_group("Suoneria telefono")
## Audio della chiamata avviato quando il giocatore accende il lampadario.
@export var ringtone_stream: AudioStream = preload("res://assets/models/enemies/broccolo/zenghera_suoneria.mp3")
## Secondo della suoneria in cui Broccolo interrompe lo squillo e risponde.
@export_range(0.0, 22.9, 0.1) var answer_at_ringtone_seconds := 13.5
## Volume della suoneria sul bus SFX.
@export_range(-30.0, 12.0, 0.5) var ringtone_volume_db := 0.0
## Sincronizza l'inizio della risposta e l'arrivo del dolly ai cue della suoneria.
@export var synchronize_camera_to_ringtone_answer := true

@export_group("Invito interruttore")
## Distanza alla quale il comando del lampadario emette il bagliore viola pulsante (m).
@export_range(1.0, 8.0, 0.1) var switch_glow_distance := 4.0
## Portata della luce viola sul corpo dell'interruttore (m).
@export_range(0.5, 5.0, 0.1) var switch_glow_range := 2.6
## Energia massima del bagliore, modulata dal battito.
@export_range(0.1, 4.0, 0.1) var switch_glow_energy := 1.8
## Velocita del battito della luce (cicli al secondo).
@export_range(0.1, 3.0, 0.1) var switch_glow_pulse_hz := 1.1

@export_group("Regia e fine introduzione")
## Distanza orizzontale finale tra la camera e il punto osservato su Broccolo (m).
@export_range(1.5, 8.0, 0.1) var camera_distance := 3.8
## Quota del punto osservato sopra i piedi (m).
@export_range(0.5, 2.0, 0.05) var camera_target_height := 1.1
## Altezza camera sopra il punto osservato (m).
@export_range(-0.5, 1.0, 0.05) var camera_height := 0.35
## Punto di riferimento della seconda regia, mantenuto al valore storico (m).
@export_range(0.5, 6.0, 0.1) var second_camera_retreat_anchor_distance := 2.8
## Campo visivo della camera cinematica (gradi).
@export_range(35.0, 85.0, 1.0) var cinematic_fov := 60.0
## Durata ingresso/ritorno della camera (secondi).
@export_range(0.1, 3.0, 0.1) var camera_blend_seconds := 1.0
## Durata del dolly quando la sincronizzazione con la suoneria e' disattivata (secondi).
@export_range(2.0, 22.0, 0.25) var camera_path_seconds := 9.0
## Distanza dal Broccolo fermo che avvia il secondo discorso (m).
@export_range(1.0, 6.0, 0.1) var approach_trigger_distance := 2.4
## Raggio della sfera usata per tenere la camera fuori da muri e oggetti (m).
@export_range(0.05, 0.6, 0.01) var camera_collision_radius := 0.32
## Velocita' di rotazione della camera nella seconda cinematic (1/s).
@export_range(0.5, 8.0, 0.1) var camera_rotation_smoothing := 1.8
## Velocita' di inseguimento durante danza e animazioni della seconda cinematic (1/s).
@export_range(0.5, 8.0, 0.1) var camera_position_smoothing := 3.0
## Arretramento della camera durante la danza; il player segue lo stesso spostamento in sicurezza.
@export_range(0.5, 12.0, 0.1) var dance_camera_retreat_distance := 6.0
## Tempo per arretrare mentre Broccolo esegue la sequenza di danza.
@export_range(1.0, 12.0, 0.25) var dance_camera_retreat_seconds := 7.5
## Per questa prova torna al player, lasciando Broccolo in idle senza avviare il secondo discorso.
@export var return_control_after_intro := true
## Identificatore unico e stabile dello stato dell'incontro nei checkpoint.
@export var persistent_id: StringName = &"main.broccolo.encounter"

var presentation: Node3D
var camera: Camera3D
var player_camera: Camera3D
var configured := false
var cinematic := false
var returning := false
var intro_completed := false
var second_presentation_started := false
var presentation_cue_started := false
var presentation_reveal_started := false
var second_presentation := false
var combat_pending := false
var final_pose := Transform3D.IDENTITY
var lock_state: Dictionary = {}
var camera_time := 0.0
var camera_from := Transform3D.IDENTITY
var camera_path_start := Vector3.ZERO
var camera_path_turn := Vector3.ZERO
var camera_intro_turn_progress := 0.5
var intro_camera_turn_position := Vector3.ZERO
var camera_path_end := Vector3.ZERO
var camera_collision_shape := SphereShape3D.new()
var camera_corridor_axis := Vector3.RIGHT
var camera_travel_axis := Vector3.BACK
var camera_left_axis := Vector3.LEFT
var dance_camera_retreat_started := false
var dance_camera_retreat_elapsed := 0.0
var dance_camera_retreat_origin := Vector3.ZERO
var dance_camera_retreat_axis := Vector3.ZERO
var dance_camera_retreat_safe_distance := 0.0
var dance_camera_retreat_path: Array[Vector3] = []
var dance_camera_retreat_path_length := 0.0
var dance_obstacle_collision: CollisionObject3D
var dance_obstacle_original_layer := 0
var dance_obstacle_collision_disabled := false
var pending_idle_facing := false
var bars: CanvasLayer
var route_ready := false
var resolved_yaw_degrees := 90.0
var saved_phone: Dictionary = {}
var ringtone_player: AudioStreamPlayer
var ring_answer_position := -1.0
var switch_approach_light: OmniLight3D
var switch_glow_elapsed := 0.0

func _ready() -> void:
	process_priority = 35
	_setup.call_deferred()

func _setup() -> void:
	if spawn == null or trigger_switch == null or entrance_switch == null or player == null or hud == null or presentation_scene == null or persistent_id.is_empty():
		push_error("BroccoloEncounter: collegare spawn, interruttori lampadario/ingresso, player, HUD e scena presentazione.")
		return
	player_camera = player.get_node("Head/Camera3D")
	if not trigger_switch.has_signal("player_toggled"):
		push_error("BroccoloEncounter: il comando di avvio richiede zone_light_switch.gd.")
		return
	if corridor_lights_switch != null and not corridor_lights_switch.has_method("set_lights_on"):
		push_error("BroccoloEncounter: il circuito del corridoio richiede zone_light_switch.gd.")
		return
	camera_collision_shape.radius = camera_collision_radius
	trigger_switch.player_toggled.connect(_trigger_toggled)
	_setup_switch_approach_glow()
	SaveManager.register_object(persistent_id, self)
	configured = true
	# Preparato prima del comando, cosi la pressione E non deve importare il modello.
	presentation = presentation_scene.instantiate()
	presentation.hide()
	add_child(presentation)
	_place_at_spawn()
	presentation.phone_walk_cycles = walk_cycles
	presentation.phone_answer_seconds = answer_seconds
	presentation.phone_throw_seconds = throw_voice_seconds
	presentation.presentation_blend_seconds = animation_blend_seconds
	presentation.world_motion_scale = motion_scale
	presentation.lateral_motion_scale = lateral_motion_scale
	presentation.dance_motion_scale = dance_motion_scale
	while is_inside_tree() and not presentation.ready_for_preview:
		await get_tree().process_frame
	if not is_inside_tree():return
	presentation.voice.volume_db = voice_volume_db
	if ringtone_stream != null:
		ringtone_player = AudioStreamPlayer.new()
		ringtone_player.name = "BroccoloPhoneRingtone"
		ringtone_player.bus = &"SFX"
		ringtone_player.stream = ringtone_stream
		ringtone_player.volume_db = ringtone_volume_db
		add_child(ringtone_player)
	else:
		push_warning("BroccoloEncounter: assegna ringtone_stream per sincronizzare la risposta al telefono.")
	# La pausa globale di AudioStreamPlayer non deve annullare la pausa speciale del lancio.
	presentation.voice.process_mode = Node.PROCESS_MODE_ALWAYS
	presentation.music.process_mode = Node.PROCESS_MODE_ALWAYS
	presentation.presentation.intro_ready.connect(_intro_finished)
	presentation.presentation.combat_ready.connect(_combat_ready)
	presentation.presentation.stage_changed.connect(_on_presentation_stage_changed)
	route_ready = _plan_route()
	_cache_camera_corridor_axis()
	presentation.map_dance_motion_axis = camera_corridor_axis
	presentation.map_dance_collision_radius = dance_collision_radius
	presentation.map_dance_collision_height = dance_collision_height
	presentation.map_dance_collision_exclusions.clear()
	presentation.map_dance_collision_exclusions.append(player.get_rid())
	if intro_completed:_restore_idle()
	print("BROCCOLO_ENCOUNTER_READY spawn=", presentation.global_position)

func _setup_switch_approach_glow() -> void:
	if not is_instance_valid(trigger_switch):return
	switch_approach_light = OmniLight3D.new()
	switch_approach_light.name = "BroccoloSwitchInvitationGlow"
	switch_approach_light.light_color = Color(0.58, 0.2, 1.0)
	switch_approach_light.light_energy = 0.0
	switch_approach_light.omni_range = switch_glow_range
	switch_approach_light.shadow_enabled = false
	switch_approach_light.position = Vector3(0.0, 0.04, 0.0)
	switch_approach_light.visible = false
	trigger_switch.add_child(switch_approach_light)

func _update_switch_approach_glow(delta: float) -> void:
	if not is_instance_valid(switch_approach_light) or not is_instance_valid(player) or not is_instance_valid(trigger_switch):return
	switch_glow_elapsed += delta
	if intro_completed or bool(trigger_switch.get("lights_on")):
		switch_approach_light.visible = false
		return
	var distance := player.global_position.distance_to(trigger_switch.global_position)
	if distance > switch_glow_distance:
		switch_approach_light.visible = false
		return
	var proximity := 1.0 - smoothstep(switch_glow_distance * 0.65, switch_glow_distance, distance)
	var pulse := 0.58 + 0.42 * (0.5 + 0.5 * sin(switch_glow_elapsed * TAU * switch_glow_pulse_hz))
	switch_approach_light.visible = true
	switch_approach_light.light_energy = switch_glow_energy * pulse * proximity

func _notification(what: int) -> void:
	if not is_instance_valid(presentation) or not presentation.ready_for_preview:return
	if what == NOTIFICATION_PAUSED:
		presentation.voice.stream_paused = true
		presentation.music.stream_paused = true
	elif what == NOTIFICATION_UNPAUSED:
		presentation.voice.stream_paused = presentation.presentation.stage == "throw"
		presentation.music.stream_paused = false

func _place_at_spawn() -> void:
	presentation.global_transform = spawn.global_transform
	presentation.rotate_y(deg_to_rad(actor_yaw_degrees))
	if snap_to_floor:
		var p := presentation.global_position
		var query := PhysicsRayQueryParameters3D.create(p + Vector3.UP * 1.5, p - Vector3.UP * 3.0, 1)
		query.exclude = [player.get_rid()]
		var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
		if not hit.is_empty():presentation.global_position.y = hit.position.y + floor_offset

func _trigger_toggled(enabled: bool) -> void:
	if not enabled or not configured or cinematic or intro_completed or SaveManager.restoring or get_tree().paused:return
	var puzzle := get_node_or_null(alien_puzzle_path)
	if puzzle == null or not puzzle.state.unlocked or not entrance_switch.lights_on:return
	if player.is_dead or not player.is_physics_processing() or GameplayUI.input_blocked():return
	start_introduction()

func start_introduction() -> void:
	if cinematic or intro_completed or not is_instance_valid(presentation):return
	cinematic = true
	returning = false
	if corridor_lights_switch != null and not corridor_lights_switch.call("set_lights_on", true):
		push_warning("BroccoloEncounter: impossibile accendere il circuito del corridoio.")
	_lock_player()
	while is_inside_tree() and not presentation.ready_for_preview:
		await get_tree().process_frame
	if not is_inside_tree() or not cinematic:return
	if not route_ready:
		_release_camera()
		GameplayUI.notify("Il passaggio e occupato.")
		return
	if is_instance_valid(ringtone_player):
		ringtone_player.play()
		print("BROCCOLO_RINGTONE_STARTED target_answer=", answer_at_ringtone_seconds)
	_start_intro_idle_loop()
	presentation.show()
	camera = Camera3D.new()
	camera.name = "BroccoloCinematicCamera"
	camera.near = 0.05
	camera.fov = player_camera.fov
	add_child(camera)
	camera.global_transform = player_camera.global_transform
	# Parte dalla posa FPS esatta per evitare scatti e cambi di posizione iniziali.
	camera_from = camera.global_transform
	camera_time = 0.0
	camera_path_start = camera.global_position
	if not _plan_intro_camera_path():
		push_error("Broccolo: nessun percorso camera libero con visuale diretta sul personaggio.")
		_abort()
		return
	# La seconda cinematic riusa il riferimento lungo la corsia, non il marker di ripresa.
	intro_camera_turn_position = camera_path_start + camera_travel_axis * second_camera_retreat_anchor_distance
	intro_camera_turn_position.y = camera_path_start.y
	camera.make_current()
	_make_bars()
	presentation_cue_started = false
	presentation_reveal_started = false
	print("BROCCOLO_CINEMATIC_STARTED")

func _start_intro_idle_loop() -> void:
	if not is_instance_valid(presentation) or not presentation.ready_for_preview:return
	presentation.reset_preview()
	var idle_clip: Animation = presentation.animation.get_animation(&"mie/idle")
	if idle_clip == null:
		push_error("BroccoloEncounter: animazione mie/idle non disponibile durante l'avvicinamento.")
		return
	idle_clip.loop_mode = Animation.LOOP_LINEAR
	presentation.animation.stop()
	presentation.animation.play(&"mie/idle", 0.0)
	presentation.animation.seek(0.0, true)
	presentation.animation.advance(0.0)

func _plan_route() -> bool:
	if not avoid_route_obstacles:
		resolved_yaw_degrees = actor_yaw_degrees
		return true
	var points: Array[Vector3] = []
	var phone_end := minf(presentation.animation.get_animation(&"mie/phone_answer_talk").length, answer_seconds + throw_voice_seconds)
	for i in range(101):points.append(presentation._root_offset(&"mie/phone_answer_talk", phone_end * i / 100.0))
	var origin: Vector3 = points.back()
	var walk_length: float = presentation.animation.get_animation(&"mie/walking").length
	for cycle in walk_cycles:
		for i in range(33):points.append(origin + presentation._root_offset(&"mie/walking", walk_length * i / 32.0))
		origin += presentation._root_offset(&"mie/walking", walk_length)
	var shape := CapsuleShape3D.new()
	shape.radius = route_clearance
	shape.height = 1.6
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.collision_mask = 1
	query.exclude = [player.get_rid()]
	var base := presentation.global_basis
	var destination := spawn.global_position
	for lane in [0.0, .15, -.15, .3, -.3, .45, -.45, .6, -.6, .75, -.75]:
		if absf(lane) > max_lane_adjustment:continue
		for correction in [0.0, 3.0, -3.0, 6.0, -6.0, 9.0, -9.0, 12.0, -12.0, 15.0, -15.0]:
			var basis := base.rotated(Vector3.UP, deg_to_rad(correction))
			var adjusted: Vector3 = destination - basis * points.back() + spawn.global_basis * Vector3(0,0,lane)
			var clear := true
			for point: Vector3 in points:
				query.transform.origin = adjusted + basis * point + Vector3.UP * .9
				var hits := player.get_world_3d().direct_space_state.intersect_shape(query)
				if not hits.is_empty():
					if correction == 0.0:print("BROCCOLO_ROUTE_BLOCK lane=",lane," point=",query.transform.origin," collider=",hits[0].collider.get_path())
					clear = false
					break
			if clear:
				presentation.global_basis = basis
				presentation.global_position = adjusted
				if snap_to_floor:
					var ray := PhysicsRayQueryParameters3D.create(adjusted + Vector3.UP * 1.5, adjusted - Vector3.UP * 3.0, 1)
					ray.exclude = [player.get_rid()]
					var floor_hit := player.get_world_3d().direct_space_state.intersect_ray(ray)
					if not floor_hit.is_empty():presentation.global_position.y = floor_hit.position.y + floor_offset
				resolved_yaw_degrees = actor_yaw_degrees + correction
				print("BROCCOLO_ROUTE_READY yaw=", resolved_yaw_degrees," lane=",lane," samples=",points.size())
				return true
	push_warning("Broccolo: nessun percorso libero vicino alla direzione configurata.")
	return false

func _lock_player() -> void:
	GameplayUI.close_immediately()
	var weapon: Node3D = player.get_node("Head/Camera3D/WeaponHolder")
	var interaction := player.get_node("InteractionSystem")
	lock_state = {"physics":player.is_physics_processing(), "input":player.is_processing_unhandled_input(),
		"weapon_process":weapon.is_processing(), "weapon_physics":weapon.is_physics_processing(),
		"weapon_visible":weapon.visible, "hud":hud.visible, "interaction":interaction.is_processing()}
	player.velocity = Vector3.ZERO
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	weapon.set_process(false)
	weapon.set_physics_process(false)
	weapon.hide()
	interaction._clear_focus()
	interaction.set_process(false)
	player.footstep_timer.stop()
	player.sprint_breath_timer.stop()
	player.sprint_breath_audio.stop()
	hud.hide()

func _unlock_player() -> void:
	if lock_state.is_empty() or not is_instance_valid(player):return
	var weapon: Node3D = player.get_node("Head/Camera3D/WeaponHolder")
	player.set_physics_process(lock_state.physics)
	player.set_process_unhandled_input(lock_state.input)
	weapon.set_process(lock_state.weapon_process)
	weapon.set_physics_process(lock_state.weapon_physics)
	weapon.visible = lock_state.weapon_visible
	player.get_node("InteractionSystem").set_process(lock_state.interaction)
	if is_instance_valid(hud):hud.visible = lock_state.hud
	lock_state.clear()

func _make_bars() -> void:
	bars = CanvasLayer.new()
	bars.layer = 80
	add_child(bars)
	for top in [true, false]:
		var bar := ColorRect.new()
		bar.color = Color.BLACK
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bars.add_child(bar)
		bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE if top else Control.PRESET_BOTTOM_WIDE)
		if top:bar.offset_bottom = 65
		else:bar.offset_top = -65

func _cache_camera_corridor_axis() -> void:
	camera_corridor_axis = presentation.global_basis.z
	camera_corridor_axis.y = 0.0
	if camera_corridor_axis.length_squared() < 0.001:camera_corridor_axis = Vector3.RIGHT
	camera_corridor_axis = camera_corridor_axis.normalized()
	var corridor_direction := trigger_switch.global_position - entrance_switch.global_position
	corridor_direction.y = 0.0
	if corridor_direction.length_squared() < 0.01:
		camera_travel_axis = camera_corridor_axis
	else:
		camera_travel_axis = corridor_direction.normalized()
	camera_left_axis = Vector3.UP.cross(camera_travel_axis).normalized()
	if camera_left_axis.length_squared() < 0.001:
		camera_left_axis = Vector3.LEFT

func _camera_path_position(progress: float) -> Vector3:
	if second_presentation:return camera_path_start
	return camera_path_start.lerp(camera_path_end, clampf(progress, 0.0, 1.0))

func _plan_intro_camera_path() -> bool:
	var focus := _shot_target()
	if is_instance_valid(camera_stop_marker):
		camera_path_end = camera_stop_marker.global_position
		camera_path_end.y = camera_path_start.y
		camera_path_turn = camera_path_start.lerp(camera_path_end, 0.68)
		camera_path_turn.y = camera_path_start.y
		camera_intro_turn_progress = 0.68
		var line_clear := _intro_camera_route_is_clear(camera_path_end, focus)
		if line_clear:
			print("BROCCOLO_CAMERA_ROUTE marker_start=", camera_path_start, " turn_start=", camera_path_turn, " stop=", camera_path_end)
		return line_clear
	var offsets := [0.0, 0.35, -0.35, 0.7, -0.7, 1.0, -1.0]
	var distances: Array[float] = []
	var distance := camera_distance
	while distance >= 1.4:
		distances.append(distance)
		distance -= 0.3
	if distances.is_empty():distances.append(camera_distance)
	var best_position := Vector3.ZERO
	var best_score := INF
	var found := false
	var advance_distance := 2.8
	while advance_distance >= 1.0 and not found:
		camera_path_turn = camera_path_start + camera_travel_axis * advance_distance
		camera_path_turn.y = camera_path_start.y
		for candidate_distance: float in distances:
			for corridor_offset: float in offsets:
				var candidate := focus - camera_left_axis * candidate_distance + camera_travel_axis * corridor_offset
				candidate.y = focus.y + camera_height
				var turn_to_candidate := candidate - camera_path_turn
				turn_to_candidate.y = 0.0
				if turn_to_candidate.dot(camera_left_axis) <= 0.1:continue
				if not _intro_camera_route_is_clear(candidate, focus):continue
				var score := absf(candidate_distance - camera_distance) + absf(corridor_offset) * 0.4
				if score < best_score:
					best_score = score
					best_position = candidate
					found = true
			if found:break
		advance_distance -= 0.2
	if not found:return false
	camera_path_end = best_position
	var first_leg := camera_path_start.distance_to(camera_path_turn)
	var second_leg := camera_path_turn.distance_to(camera_path_end)
	camera_intro_turn_progress = first_leg / maxf(first_leg + second_leg, 0.001)
	print("BROCCOLO_CAMERA_ROUTE start=", camera_path_start, " advance=", camera_path_turn, " left_shot=", camera_path_end, " turn_progress=", camera_intro_turn_progress)
	return true

func _intro_camera_route_is_clear(endpoint: Vector3, focus: Vector3) -> bool:
	var radius_shape := SphereShape3D.new()
	radius_shape.radius = camera_collision_radius
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = radius_shape
	query.collision_mask = _camera_collision_mask()
	query.exclude = _camera_exclusions()
	var space := player.get_world_3d().direct_space_state
	var previous := camera_path_start
	for i in range(1, 49):
		var point := _intro_camera_path_candidate_point(endpoint, float(i) / 48.0)
		query.transform = Transform3D(Basis.IDENTITY, previous)
		query.motion = point - previous
		var travel := space.cast_motion(query)
		if not travel.is_empty() and travel[0] < 0.995:return false
		previous = point
	var sightline := PhysicsRayQueryParameters3D.create(endpoint, focus, _camera_collision_mask())
	sightline.exclude = _camera_exclusions()
	return space.intersect_ray(sightline).is_empty()

func _intro_camera_path_candidate_point(endpoint: Vector3, progress: float) -> Vector3:
	return camera_path_start.lerp(endpoint, clampf(progress, 0.0, 1.0))

func _camera_sees_broccolo() -> bool:
	if not is_instance_valid(camera) or not is_instance_valid(presentation):return false
	var focus := _shot_target()
	var to_focus := focus - camera.global_position
	if to_focus.length_squared() < 0.001:return false
	var camera_forward := -camera.global_basis.z
	var half_fov_cos := cos(deg_to_rad(camera.fov * 0.42))
	if camera_forward.dot(to_focus.normalized()) < half_fov_cos:return false
	var sightline := PhysicsRayQueryParameters3D.create(camera.global_position, focus, _camera_collision_mask())
	sightline.exclude = _camera_exclusions()
	return player.get_world_3d().direct_space_state.intersect_ray(sightline).is_empty()

func _camera_path_forward(progress: float, camera_position: Vector3) -> Vector3:
	if second_presentation:
		var direct_target := _shot_target() - camera_position
		if direct_target.length_squared() > 0.0001:return direct_target.normalized()
		return camera_travel_axis
	var target_direction := _shot_target() - camera_position
	if target_direction.length_squared() < 0.0001:
		return -camera_from.basis.z
	# La direzione del percorso evolve dal corridoio verso Broccolo; anche il
	# raccordo dalla posa iniziale usa il progresso del dolly, evitando una
	# rotazione percepibile mentre la camera è ancora quasi ferma.
	return target_direction.normalized()

func _shot_target() -> Vector3:
	return presentation.actor.global_position + Vector3.UP * camera_target_height

func _camera_exclusions() -> Array[RID]:
	var exclusions: Array[RID] = [player.get_rid()]
	if is_instance_valid(presentation) and presentation.actor is CollisionObject3D:
		exclusions.append((presentation.actor as CollisionObject3D).get_rid())
	if dance_obstacle_collision_disabled and is_instance_valid(dance_obstacle_collision):
		exclusions.append(dance_obstacle_collision.get_rid())
	return exclusions

func _camera_collision_mask() -> int:
	return 1

func _plan_dance_camera_retreat() -> float:
	var start := camera.global_position
	var corridor_target := intro_camera_turn_position
	corridor_target.y = start.y
	var retreat_delta := corridor_target - start
	retreat_delta.y = 0.0
	if retreat_delta.length_squared() < 0.0025:return 0.0
	var backward_axis := retreat_delta.normalized()
	var corridor_limit_distance := retreat_delta.length()
	var desired_distance := minf(dance_camera_retreat_distance, corridor_limit_distance)
	if desired_distance < 0.05:return 0.0
	var space := player.get_world_3d().direct_space_state
	var camera_query := PhysicsShapeQueryParameters3D.new()
	camera_query.shape = camera_collision_shape
	camera_query.collision_mask = _camera_collision_mask()
	camera_query.exclude = _camera_exclusions()
	camera_query.transform = Transform3D(Basis.IDENTITY, start)
	camera_query.motion = backward_axis * desired_distance
	var fractions := space.cast_motion(camera_query)
	var safe_fraction := fractions[0] if not fractions.is_empty() else 1.0
	var safe_distance := desired_distance * safe_fraction
	if safe_fraction < 1.0:safe_distance = maxf(0.0, safe_distance - 0.12)
	if safe_distance < 0.05:return 0.0
	dance_camera_retreat_path.clear()
	dance_camera_retreat_path.append(start)
	dance_camera_retreat_path.append(start + backward_axis * safe_distance)
	dance_camera_retreat_path_length = safe_distance
	dance_camera_retreat_axis = backward_axis
	print("BROCCOLO_DANCE_CAMERA_RETREAT axis=", backward_axis, " distance=", safe_distance, " corridor_limit=", corridor_limit_distance, " target=", corridor_target)
	return dance_camera_retreat_path_length

func _dance_camera_retreat_position(progress: float) -> Vector3:
	if dance_camera_retreat_path.size() < 2:return dance_camera_retreat_origin
	var distance := minf(dance_camera_retreat_path_length * clampf(progress, 0.0, 1.0), dance_camera_retreat_distance)
	for i in range(1, dance_camera_retreat_path.size()):
		var segment := dance_camera_retreat_path[i - 1].distance_to(dance_camera_retreat_path[i])
		if distance <= segment:
			return dance_camera_retreat_path[i - 1].lerp(dance_camera_retreat_path[i], distance / maxf(segment, 0.001))
		distance -= segment
	return dance_camera_retreat_path.back()

func _move_camera_safely(destination: Vector3) -> Vector3:
	var origin := camera.global_position
	var motion := destination - origin
	if motion.length_squared() < 0.000001:return destination
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = camera_collision_shape
	query.transform = Transform3D(Basis.IDENTITY, origin)
	query.collision_mask = _camera_collision_mask()
	query.exclude = _camera_exclusions()
	var space := player.get_world_3d().direct_space_state
	if not space.intersect_shape(query, 1).is_empty():return origin
	query.motion = motion
	var fractions := space.cast_motion(query)
	if fractions.size() >= 1 and fractions[0] < 1.0:
		var clearance_fraction := 0.12 / motion.length()
		var safe_fraction := maxf(fractions[0] - clearance_fraction, 0.0)
		for attempt in 6:
			var candidate: Vector3 = origin + motion * safe_fraction
			query.transform.origin = candidate
			query.motion = Vector3.ZERO
			if space.intersect_shape(query, 1).is_empty():return candidate
			safe_fraction = maxf(safe_fraction - clearance_fraction, 0.0)
		return origin
	return destination

func _process(delta: float) -> void:
	_update_switch_approach_glow(delta)
	if pending_idle_facing and _player_no_longer_sees_broccolo():
		_face_broccolo_to_player()
		pending_idle_facing = false
	if not cinematic:
		if intro_completed and not second_presentation_started and is_instance_valid(player) and is_instance_valid(presentation):
			var actor_position: Vector3 = presentation.actor.global_position
			if player.global_position.distance_to(actor_position) <= approach_trigger_distance:
				_start_second_presentation()
		return
	if player.is_dead:
		_abort()
		return
	if not is_instance_valid(camera):return
	camera_time += delta
	if returning:
		camera.global_transform = camera_from.interpolate_with(player_camera.global_transform, smoothstep(0, camera_blend_seconds, camera_time))
		camera.fov = lerpf(cinematic_fov, player_camera.fov, smoothstep(0, camera_blend_seconds, camera_time))
		if camera_time >= camera_blend_seconds:_release_camera()
	else:
		var path_progress := clampf(camera_time / camera_path_seconds, 0.0, 1.0)
		if not second_presentation and synchronize_camera_to_ringtone_answer and is_instance_valid(ringtone_player) and ringtone_player.playing:
			path_progress = clampf(ringtone_player.get_playback_position() / maxf(answer_at_ringtone_seconds, 0.1), 0.0, 1.0)
		var eased_progress := _smooth_cinematic(path_progress)
		var desired_position := _camera_path_position(eased_progress)
		if second_presentation and presentation.presentation.stage == "dance":
			if not dance_camera_retreat_started:
				dance_camera_retreat_started = true
				dance_camera_retreat_origin = camera.global_position
				dance_camera_retreat_elapsed = 0.0
				dance_camera_retreat_axis = camera.global_position - presentation.actor.global_position
				dance_camera_retreat_axis.y = 0.0
				if dance_camera_retreat_axis.length_squared() < 0.001:
					dance_camera_retreat_axis = camera.global_basis.z
					dance_camera_retreat_axis.y = 0.0
				dance_camera_retreat_axis = dance_camera_retreat_axis.normalized()
				_disable_dance_obstacle_collision()
				dance_camera_retreat_safe_distance = _plan_dance_camera_retreat()
		if second_presentation and dance_camera_retreat_started:
			if presentation.presentation.stage == "dance":dance_camera_retreat_elapsed += delta
			var retreat_progress := clampf(dance_camera_retreat_elapsed / dance_camera_retreat_seconds, 0.0, 1.0)
			desired_position = _dance_camera_retreat_position(smoothstep(0.0, 1.0, retreat_progress))
		var smoothed_position := desired_position
		if second_presentation:
			var position_weight := 1.0 - exp(-camera_position_smoothing * delta)
			smoothed_position = camera.global_position.lerp(desired_position, position_weight)
		var safe_position := _move_camera_safely(smoothed_position) if second_presentation else smoothed_position
		if second_presentation and dance_camera_retreat_started and not returning:
			# Il player compie lo stesso passo all'indietro della camera; CharacterBody
			# limita il movimento se lo spazio non basta e preserva la collisione reale.
			var player_position_before := player.global_position
			player.move_and_collide(safe_position - camera.global_position)
			camera.global_position += player.global_position - player_position_before
		else:
			camera.global_position = safe_position
		var direction := _camera_path_forward(path_progress, camera.global_position)
		if direction.length_squared() > 0.0001:
			var desired_basis := Basis.looking_at(direction, Vector3.UP)
			if second_presentation:
				camera.global_basis = camera.global_basis.slerp(desired_basis, 1.0 - exp(-camera_rotation_smoothing * delta))
			else:
				camera.global_basis = camera_from.basis.slerp(desired_basis, eased_progress)
		camera.fov = lerpf(player_camera.fov, cinematic_fov, smoothstep(0, camera_blend_seconds, camera_time))
		var intro_cue_reached := path_progress >= 1.0
		if not second_presentation and synchronize_camera_to_ringtone_answer and is_instance_valid(ringtone_player):
			intro_cue_reached = ringtone_player.get_playback_position() >= maxf(answer_at_ringtone_seconds - answer_seconds, 0.0)
		if not presentation_cue_started and (intro_cue_reached if not second_presentation else path_progress >= 0.0):
			presentation_cue_started = true
			if second_presentation:
				presentation.start_discourse(true)
				# start_discourse resetta la posa del presenter: applicare il facing dopo il reset.
				_face_broccolo_to_player()
				# Nella mappa le clip restano ferme; il presenter applica solo il breve
				# avanzamento in avanti nel salto della danza finale.
				presentation.travel = false
			else:
				presentation_reveal_started = true
				presentation.phone_answer_seconds = answer_seconds
				presentation.start_introduction()

func _smooth_cinematic(value: float) -> float:
	var t := clampf(value, 0.0, 1.0)
	return t * t * t * (t * (t * 6.0 - 15.0) + 10.0)

func _face_broccolo_to_player() -> void:
	if not is_instance_valid(presentation) or not is_instance_valid(player_camera):return
	var actor: Node3D = presentation.actor
	var look_target := player_camera.global_position
	look_target.y = actor.global_position.y
	if actor.global_position.distance_squared_to(look_target) > 0.0001:
		actor.look_at(look_target, Vector3.UP)
		# Il modello Broccolo ha il fronte visivo rivolto sul +Z locale; look_at
		# allinea invece il -Z standard di Godot, quindi compensiamo di 180 gradi.
		actor.rotate_y(deg_to_rad(actor_facing_offset_degrees))

func _offset_broccolo_for_second_presentation() -> void:
	if second_presentation_screen_right_offset <= 0.0 or not is_instance_valid(camera) or not is_instance_valid(presentation):return
	var screen_right := camera.global_basis.x
	screen_right.y = 0.0
	if screen_right.length_squared() < 0.001:return
	screen_right = screen_right.normalized()
	var shape := CapsuleShape3D.new()
	shape.radius = route_clearance
	shape.height = 1.6
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.collision_mask = 1
	query.exclude = [player.get_rid()]
	var origin := presentation.global_position
	# Cerca dal massimo verso una correzione piu' piccola e verifica la posa
	# finale: il personaggio puo' partire gia' a contatto col mobile.
	var steps := int(ceil(second_presentation_screen_right_offset / 0.05))
	for step in range(steps, 0, -1):
		var distance := minf(step * 0.05, second_presentation_screen_right_offset)
		var candidate := origin + screen_right * distance
		query.transform = Transform3D(Basis.IDENTITY, candidate + Vector3.UP * 0.9)
		if player.get_world_3d().direct_space_state.intersect_shape(query).is_empty():
			presentation.global_position = candidate
			print("BROCCOLO_SECOND_PRESENTATION_OFFSET right_m=", distance)
			return
	print("BROCCOLO_SECOND_PRESENTATION_OFFSET blocked")

func _on_presentation_stage_changed(stage: String) -> void:
	if stage == "phone" and is_instance_valid(ringtone_player):
		ring_answer_position = ringtone_player.get_playback_position()
		ringtone_player.stop()
		print("BROCCOLO_RINGTONE_ANSWERED at=", "%.3f" % ring_answer_position)
	if stage != "dance" or not second_presentation:return
	if not is_instance_valid(camera) or not is_instance_valid(presentation):return
	if dance_screen_left_offset <= 0.0:return
	var camera_left := -camera.global_basis.x
	camera_left.y = 0.0
	if camera_left.length_squared() < 0.001:return
	camera_left = camera_left.normalized()
	var local_offset: Vector3 = presentation.global_basis.inverse() * (camera_left * dance_screen_left_offset)
	local_offset.y = 0.0
	presentation.actor.position += local_offset

func _disable_dance_obstacle_collision() -> void:
	if dance_obstacle_collision_disabled:return
	var obstacle := get_node_or_null(dance_obstacle_collision_path) as CollisionObject3D
	if not is_instance_valid(obstacle):
		if presentation != null and presentation.get("map_presentation") == true:
			push_warning("BroccoloEncounter: collider del mobile coreografia non trovato: " + String(dance_obstacle_collision_path))
		return
	dance_obstacle_collision = obstacle
	dance_obstacle_original_layer = obstacle.collision_layer
	obstacle.collision_layer = 0
	dance_obstacle_collision_disabled = true
	print("BROCCOLO_DANCE_OBSTACLE_DISABLED path=", obstacle.get_path(), " layer=", dance_obstacle_original_layer, " camera_excluded=true")

func _restore_dance_obstacle_collision() -> void:
	if not dance_obstacle_collision_disabled:return
	if is_instance_valid(dance_obstacle_collision):
		dance_obstacle_collision.set_deferred("collision_layer", dance_obstacle_original_layer)
		print("BROCCOLO_DANCE_OBSTACLE_RESTORED path=", dance_obstacle_collision.get_path(), " layer=", dance_obstacle_original_layer)
	dance_obstacle_collision = null
	dance_obstacle_collision_disabled = false

func _intro_finished() -> void:
	intro_completed = true
	_prepare_idle_facing_player()
	final_pose = presentation.actor.global_transform
	print("BROCCOLO_INTRO_FINISHED position=", final_pose.origin)
	introduction_finished.emit(final_pose)
	if return_control_after_intro:release_after_intro()

func _prepare_idle_facing_player() -> void:
	if not is_instance_valid(presentation) or not presentation.ready_for_preview:return
	presentation.travel = false
	presentation.clip_prefix = presentation.actor.position
	presentation.animation.get_animation(&"mie/idle").loop_mode = Animation.LOOP_LINEAR
	presentation.animation.play(&"mie/idle", animation_blend_seconds)
	presentation.animation.advance(0.0)
	pending_idle_facing = true
	if _player_no_longer_sees_broccolo():
		_face_broccolo_to_player()
		pending_idle_facing = false

func _player_no_longer_sees_broccolo() -> bool:
	if not is_instance_valid(presentation):return true
	var view_camera: Camera3D = camera if cinematic and is_instance_valid(camera) else player_camera
	if not is_instance_valid(view_camera):return true
	var target: Vector3 = presentation.actor.global_position + Vector3.UP * camera_target_height
	var query := PhysicsRayQueryParameters3D.create(view_camera.global_position, target, 1)
	query.exclude = _camera_exclusions()
	var forward := -view_camera.global_basis.z.normalized()
	var to_target: Vector3 = (target - view_camera.global_position).normalized()
	var outside_view := forward.dot(to_target) < cos(deg_to_rad(view_camera.fov * 0.65))
	var occluded := not player.get_world_3d().direct_space_state.intersect_ray(query).is_empty()
	return outside_view or occluded

func _start_second_presentation() -> void:
	if second_presentation_started or not intro_completed or not is_instance_valid(presentation):return
	second_presentation_started = true
	second_presentation = true
	cinematic = true
	returning = false
	combat_pending = false
	dance_camera_retreat_started = false
	dance_camera_retreat_elapsed = 0.0
	dance_camera_retreat_safe_distance = 0.0
	_lock_player()
	camera = Camera3D.new()
	camera.name = "BroccoloDiscourseCamera"
	camera.near = 0.05
	camera.fov = player_camera.fov
	add_child(camera)
	camera.global_transform = player_camera.global_transform
	camera_time = 0.0
	camera_path_start = camera.global_position
	# Mantiene il punto di ripresa del giocatore e ruota direttamente verso Broccolo.
	camera_path_turn = camera_path_start
	camera_path_end = camera_path_start
	camera.make_current()
	_offset_broccolo_for_second_presentation()
	_make_bars()
	# Broccolo ha gia' visto il player: l'azione parte insieme alla camera,
	# senza lasciare qualche secondo di idle prima del cue del primo dolly.
	presentation_cue_started = true
	presentation.start_discourse(true)
	_face_broccolo_to_player()
	presentation.travel = false
	print("BROCCOLO_SECOND_PRESENTATION_STARTED")

func _combat_ready() -> void:
	combat_pending = true
	if cinematic and is_instance_valid(camera):
		release_after_intro()
	else:
		_begin_minion_fight()

func _begin_minion_fight() -> void:
	if not combat_pending:return
	combat_pending = false
	var spawner := get_node_or_null("BroccoloMinionSpawner")
	if spawner == null:
		spawner = Node.new()
		spawner.name = "BroccoloMinionSpawner"
		spawner.set_script(preload("res://scripts/enemies/broccolo_minion_spawner.gd"))
		add_child(spawner)
	spawner.configure(self, presentation.actor.global_position)

func release_after_intro() -> void:
	if not cinematic or returning or not is_instance_valid(camera):return
	if second_presentation and dance_camera_retreat_started:
		_align_player_view_to_camera()
	returning = true
	camera_time = 0
	camera_from = camera.global_transform

func _align_player_view_to_camera() -> void:
	if not is_instance_valid(player) or not is_instance_valid(camera):return
	var forward := -camera.global_basis.z.normalized()
	var horizontal := Vector3(forward.x, 0.0, forward.z)
	if horizontal.length_squared() > 0.001:
		player.global_rotation.y = atan2(-horizontal.x, -horizontal.z)
	var head: Node3D = player.get_node("Head")
	head.rotation.x = clampf(asin(clampf(forward.y, -1.0, 1.0)), deg_to_rad(-89.0), deg_to_rad(89.0))

func _release_camera() -> void:
	_restore_dance_obstacle_collision()
	if is_instance_valid(player_camera):player_camera.make_current()
	if is_instance_valid(camera):camera.queue_free()
	camera = null
	if intro_completed and not second_presentation and is_instance_valid(presentation):
		final_pose = presentation.actor.global_transform
	if is_instance_valid(bars):bars.queue_free()
	bars = null
	_unlock_player()
	cinematic = false
	returning = false
	if combat_pending:_begin_minion_fight()

func _abort() -> void:
	if is_instance_valid(ringtone_player):
		ringtone_player.stop()
	if is_instance_valid(presentation) and presentation.ready_for_preview:
		presentation.presentation.stop()
		presentation.voice.stop()
		presentation.component.bind_voice(null)
	_release_camera()

func blocks_saving() -> bool:
	return cinematic

func restore_priority() -> int:
	return 35

func get_persistent_state() -> Dictionary:
	var phone_state := saved_phone
	if is_instance_valid(presentation) and is_instance_valid(presentation.phone):phone_state = presentation.phone.get_save_state()
	return {"intro_completed":intro_completed, "actor_pose":final_pose, "phone":phone_state}

func apply_persistent_state(data: Dictionary) -> void:
	_abort()
	pending_idle_facing = false
	intro_completed = bool(data.get("intro_completed", false))
	final_pose = data.get("actor_pose", Transform3D.IDENTITY)
	saved_phone = data.get("phone", {"thrown":intro_completed}).duplicate(true)
	if is_instance_valid(presentation) and presentation.ready_for_preview:
		if intro_completed:_restore_idle()
		else:
			presentation.reset_preview()
			_place_at_spawn()
			route_ready = _plan_route()
			_cache_camera_corridor_axis()
			presentation.map_dance_motion_axis = camera_corridor_axis
			presentation.map_dance_collision_radius = dance_collision_radius
			presentation.map_dance_collision_height = dance_collision_height
			presentation.map_dance_collision_exclusions.clear()
			presentation.map_dance_collision_exclusions.append(player.get_rid())
			presentation.hide()

func _restore_idle() -> void:
	presentation.reset_preview()
	presentation.actor.global_transform = final_pose
	presentation.clip_prefix = presentation.actor.position
	presentation.animation.get_animation(&"mie/idle").loop_mode = Animation.LOOP_LINEAR
	presentation.animation.play(&"mie/idle", 0.0)
	if is_instance_valid(presentation.phone):presentation.phone.apply_save_state(saved_phone)
	presentation.show()

func _exit_tree() -> void:
	_abort()
	SaveManager.unregister_object(persistent_id, self)
