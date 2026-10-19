extends CharacterBody3D
## Corpo di combattimento condiviso dal laboratorio e dal componente mappa.

signal health_changed
signal died

@export_group("Corpo e salute")
## Il principale usa HP; le copie contano colpi utili e sono protette durante hurt.
@export var principal := true
## Energia iniziale del corpo principale.
@export_range(1, 500, 1) var max_health := 30
## Numero di colpi utili per una copia, anche con armi potenti.
@export_range(1, 10, 1) var copy_hits := 2
## Scala finale del modello (1 = altezza originale).
@export_range(0.05, 1.0, 0.01) var miniature_scale := 0.2
## Intensita bordo senza profilo prova; con PowerVFX si usa Copy Rim Strength.
@export_range(0.0, 0.5, 0.01) var copy_aura_strength := 0.08
## Colore bordo copie, indipendente dalla loro protezione durante hit.
@export var copy_aura_color := Color(1.0, 0.42, 0.08)
## Secondi della trasformazione luminosa iniziale.
@export_range(0.1, 5.0, 0.1) var shrink_seconds := 1.8
## Immunita aggiuntiva dopo la reazione a un colpo, secondi.
@export_range(0.0, 5.0, 0.1) var recovery_seconds := 1.0
@export_group("Prova effetti")
## Risorsa effetti da approvare nel laboratorio; null conserva la versione mappa.
## Collegare la stessa scena in mappa solo dopo approvazione, senza ricreare i VFX.
@export var preview_vfx_scene: PackedScene
@export_group("Locomozione")
## Velocita camminata in m/s.
@export_range(0.1, 4.0, 0.1) var walk_speed := 0.7
## Velocita inseguimento rapido in m/s.
@export_range(0.2, 6.0, 0.1) var run_speed := 2.4
## Distanza in metri oltre cui accelera.
@export_range(1.0, 10.0, 0.1) var run_distance := 2.5
## Clip ciclica della corsa, nelle copie private runtime.
@export var run_clip: StringName = &"mie/running"
## Partenza da fermo o camminata verso corsa.
@export var start_run_clip: StringName = &"mie/idle_to_run"
## Frenata prima di fermarsi o attaccare.
@export var stop_run_clip: StringName = &"mie/running_to_stop"
## Inversione di corsa; la rotazione del bacino viene trasferita al controller.
@export var turn_run_clip: StringName = &"mie/running_change_direction"
## Recupero dopo atterraggio del salto locomotorio.
@export var landing_clip: StringName = &"mie/running_jump_to_run"
## Soglia angolare per l'inversione animata, gradi.
@export_range(90.0, 175.0, 5.0) var turn_threshold_degrees := 120.0
## Pausa minima tra inversioni animate, secondi.
@export_range(0.5, 6.0, 0.1) var turn_cooldown := 2.5
## Durata della fuga iniziale delle copie in direzioni distinte, secondi.
@export_range(0.2, 2.0, 0.1) var scatter_seconds := 0.8
## Altezza massima ostacolo saltato in metri.
@export_range(0.05, 1.0, 0.05) var obstacle_height := 0.4
## Gravita m/s².
@export_range(1.0, 30.0, 0.5) var gravity := 12.0
## Intervallo minimo fra due attacchi, secondi.
@export_range(0.1, 5.0, 0.1) var attack_cooldown := 1.0
## Intervallo fra scenette vulnerabili, secondi.
@export_range(1.0, 20.0, 0.5) var show_interval := 6.0
## Passo laterale durante sneak vicino a una parete, m/s.
@export_range(0.0, 1.0, 0.05) var wall_sneak_speed := 0.25
@export_group("Boss e recupero ostacoli")
## Distanza preferita a salute piena, metri.
@export_range(1.0, 8.0, 0.1) var boss_initial_distance := 4.0
## Pausa attacchi del principale a salute piena, secondi.
@export_range(0.5, 10.0, 0.1) var boss_initial_attack_delay := 4.0
## Pausa attacchi del principale a salute quasi esaurita, secondi.
@export_range(0.1, 3.0, 0.05) var boss_final_attack_delay := 0.55
## Tempo senza avanzamento prima del tentativo di salto, secondi.
@export_range(0.2, 2.0, 0.1) var stuck_jump_seconds := 0.4
## Tempo senza avanzamento prima di cambiare rotta, secondi.
@export_range(0.6, 5.0, 0.1) var stuck_escape_seconds := 1.6
## Durata della deviazione per liberarsi, secondi.
@export_range(0.3, 3.0, 0.1) var escape_seconds := 0.9
@export_group("Collegamenti")
## Player bersaglio, collegato dalla scena di prova.
@export var target: CharacterBody3D

const FEEDBACK = preload("res://scripts/effects/melee_feedback.gd")
const ARC = preload("res://scripts/effects/zombie_attack_arc_3d.gd")
const BURST = preload("res://scripts/effects/broccolo_lab_burst.gd")
const ENERGY = preload("res://scripts/enemies/broccolo_lab_energy.gd")
var animation: AnimationPlayer
var visual: Node3D
var aura: ShaderMaterial
var health := 0
var state := "shrink"
var elapsed := 0.0
var duration := 0.0
var cooldown := 0.0
var show_timer := 0.0
var recovery := 0.0
var move: Node
var applied := false
var autonomous := true
var lab: Node
var moves: Array[Node] = []
var show_index := 0
var attack_index := 0
var jump_left := 0.0
var previews := false
var model_offset := Vector3.ZERO
var wall_tangent := Vector3.ZERO
var locomotion := "idle"
var locomotion_time := 0.0
var locomotion_duration := 0.0
var turn_wait := 0.0
var turn_from := 0.0
var turn_to := 0.0
var scatter_direction := Vector3.ZERO
var scatter_left := 0.0
var nominal_speeds: Dictionary = {}
var role: Node
var role_id: StringName = &""
var strategy := -1
var audio: Node
var flank_goal := Vector3.ZERO
var flank_left := 0.0
var stuck_time := 0.0
var stuck_jumps := 0
var escape_left := 0.0
var escape_direction := Vector3.ZERO
var throw_index := 0
var projectiles_fired := 0
var last_hit_clip: StringName = &""
var navigation_intent := Vector3.ZERO
var pool: Node
var gate: Node
var gate_requested := false
var gate_request_at := 0.28
var gate_retry := 0.0
var spawn_tween: Tween
var active_collision_layer := 1
var active_collision_mask := 1
var power_fx: Node3D
var emergence_distance := 0.0
var emergence_duration := 0.5

func _ready() -> void:
	active_collision_layer = collision_layer
	active_collision_mask = collision_mask
	add_to_group("broccolo_lab_actors")
	audio = get_node("LabAudio")
	if is_instance_valid(role):
		role_id = role.role_id
		strategy = role.strategy
		run_speed = role.run_speed
		attack_cooldown = role.attack_cooldown
		show_interval = role.show_interval
		flank_left = role.flank_seconds
	visual = get_node("Broccolo")
	model_offset = visual.position
	animation = get_node("Broccolo/AnimationPlayer")
	var phone := get_node("PhonePresentation")
	phone.set_process(false)
	phone.phone_visual.hide()
	var skeleton: Skeleton3D = get_node("Broccolo/Armature/GeneralSkeleton")
	skeleton.reset_bone_poses()
	# Private libraries AND private animations: shared .res files remain untouched.
	var library := AnimationLibrary.new()
	for clip_name in animation.get_animation_library(&"mie").get_animation_list():
		var path := "res://assets/models/enemies/broccolo/animation_compatibili/in_place/%s.res" % clip_name
		if not ResourceLoader.exists(path): continue
		var clip: Animation = load(path).duplicate(true)
		clip.loop_mode = Animation.LOOP_LINEAR if clip_name in [&"walking", &"walking_happy", &"walking_sneaky", &"idle", &"running"] else Animation.LOOP_NONE
		if StringName("mie/" + String(clip_name)) == turn_run_clip:
			_normalize_turn_yaw(clip)
		library.add_animation(clip_name, clip)
	animation.remove_animation_library(&"mie")
	animation.add_animation_library(&"mie", library)
	for clip in [run_clip, &"mie/walking"]:
		var source: Animation = load("res://assets/models/enemies/broccolo/animation_compatibili/con_spostamento/%s.res" % String(clip).trim_prefix("mie/"))
		for track in source.get_track_count():
			if source.track_get_type(track) == Animation.TYPE_POSITION_3D and String(source.track_get_path(track)).ends_with(":mixamorig1_Hips"):
				var travel := source.position_track_interpolate(track, source.length) - source.position_track_interpolate(track, 0)
				travel.y = 0
				nominal_speeds[clip] = travel.length() * 0.01 * miniature_scale / maxf(source.length, 0.01)
	moves.assign(get_node("Moves").get_children())
	for entry in moves:
		if not animation.has_animation(entry.clip): push_error("Broccolo lab: clip mancante " + String(entry.clip))
	aura = ShaderMaterial.new()
	aura.shader = preload("res://scripts/effects/broccolo_lab_aura.gdshader")
	if not principal: aura.set_shader_parameter("tint", copy_aura_color)
	for mesh in visual.find_children("*", "MeshInstance3D", true, false): mesh.material_overlay = aura
	health = max_health if principal else copy_hits
	visual.position = model_offset * (1.0 if principal else miniature_scale)
	visual.scale = Vector3.ONE * (1.0 if principal else miniature_scale)
	floor_snap_length = 0.12
	var body_shape: CollisionShape3D = get_node("BodyShape")
	body_shape.scale = Vector3.ONE * miniature_scale / 0.11
	body_shape.position.y = 0.12 * miniature_scale / 0.11
	show_timer = show_interval
	if preview_vfx_scene != null:
		power_fx = preview_vfx_scene.instantiate()
		add_child(power_fx)
		if not principal:
			aura.set_shader_parameter("edge_width", power_fx.copy_rim_width)
			aura.set_shader_parameter("glow_gain", power_fx.copy_rim_glow)
			aura.set_shader_parameter("pulse_floor", power_fx.copy_rim_pulse_floor)
	if not principal:
		state = "chase"
		burst(global_position + Vector3.UP * 0.1)
	play(&"mie/idle")

func vulnerable() -> bool:
	return state not in ["dead", "pooled"] and (state != "hurt" if not principal else (state == "show" and recovery <= 0.0))

func _physics_process(delta: float) -> void:
	elapsed += delta
	cooldown = maxf(0, cooldown - delta)
	recovery = maxf(0, recovery - delta)
	jump_left = maxf(0, jump_left - delta)
	turn_wait = maxf(0, turn_wait - delta)
	gate_retry = maxf(0, gate_retry - delta)
	locomotion_time += delta
	var rim_strength: float = power_fx.copy_rim_strength if power_fx != null else copy_aura_strength
	aura.set_shader_parameter("active", (1.0 if not vulnerable() else 0.0) if principal else rim_strength)
	if state == "shrink":
		visual.scale = Vector3.ONE * lerpf(1.0, miniature_scale, smoothstep(0, shrink_seconds, elapsed))
		visual.position = model_offset * visual.scale.x
		if power_fx != null: power_fx.charge(power_fx.reference_height * visual.scale.x)
		if elapsed >= shrink_seconds:
			burst(global_position + Vector3.UP * 0.1)
			state = "chase"
			elapsed = 0
		return
	velocity.x = 0
	velocity.z = 0
	navigation_intent = Vector3.ZERO
	if not is_on_floor(): velocity.y -= gravity * delta
	elif velocity.y <= 0: velocity.y = -0.2
	if state == "dead":
		move_and_slide()
		if elapsed >= duration:
			burst(global_position + Vector3.UP * 0.1)
			if is_instance_valid(pool): pool.retire_actor(self)
			else: queue_free()
		return
	if state == "preview":
		move_and_slide()
		return
	if state == "hurt":
		if elapsed >= duration: state = "chase"
	elif state == "gate":
		if not is_instance_valid(gate): state = "chase"
		else:
			if not gate_requested and elapsed >= gate_request_at:
				gate_requested = true
				gate.request_enemy_open(self)
			if elapsed > 0.5 and gate.is_open and absf(gate.rotation.y) > absf(deg_to_rad(gate.open_angle)) * 0.75:
				state = "chase"
				locomotion = "idle"
				gate_retry = 0.5
			elif elapsed > 4:
				state = "chase"
				gate_retry = 0.5
			elif not animation.is_playing(): play(&"mie/idle")
	elif state == "emerge":
		var progress := clampf(elapsed / emergence_duration, 0, 1)
		visual.scale = Vector3.ONE * miniature_scale * lerpf(0.15, 1, smoothstep(0, 1, progress))
		visual.position = model_offset * visual.scale.x
		velocity.x = scatter_direction.x * emergence_distance / emergence_duration
		velocity.z = scatter_direction.z * emergence_distance / emergence_duration
		if progress >= 1:
			state = "scatter"
			elapsed = 0
			locomotion = "idle"
	elif state == "scatter":
		scatter_left -= delta
		_update_locomotion(steer_scatter(scatter_direction), run_speed, delta)
		if scatter_left <= 0:
			state = "chase" if autonomous else "preview"
			if not autonomous: play(&"mie/idle")
	elif state in ["attack", "show", "throw"]:
		if state == "show" and wall_tangent.length_squared() > 0.01:
			velocity.x = wall_tangent.x * wall_sneak_speed
			velocity.z = wall_tangent.z * wall_sneak_speed
		if state == "attack" and not applied and elapsed >= duration * move.impact_fraction:
			applied = true
			emit_wave(move.reach)
			if is_instance_valid(target):
				var offset := target.global_position - global_position
				offset.y = 0
				if offset.length() <= move.reach and global_basis.z.dot(offset.normalized()) > 0.35 and clear_target():
					target.take_damage(move.damage)
					audio.action("hit")
		if state == "throw" and not applied and elapsed >= duration * move.impact_fraction:
			applied = true
			fire_energy()
		if state == "show" and not animation.is_playing() and elapsed < duration: animation.play(move.clip, 0.15)
		if state == "attack" and elapsed < duration * move.impact_fraction:
			velocity.x = global_basis.z.x * move.advance_speed
			velocity.z = global_basis.z.z * move.advance_speed
		if elapsed >= duration:
			state = "chase"
			locomotion = "idle"
			cooldown = lerpf(boss_initial_attack_delay, boss_final_attack_delay, rage()) if principal else attack_cooldown
			if strategy == 2:
				flank_left = role.flank_seconds
				flank_goal = Vector3.ZERO
	elif autonomous and is_instance_valid(target) and not target.get("is_dead"):
		if is_instance_valid(lab) and lab.try_gate(self):
			move_and_slide()
			audio.tick(delta)
			return
		show_timer -= delta
		var offset := target.global_position - global_position
		offset.y = 0
		var attacks := moves.filter(func(entry: Node) -> bool: return entry.kind == 0)
		if show_interval > 0 and show_timer <= 0:
			begin_show()
		elif strategy == 1:
			_update_ranged(offset, delta)
		elif not attacks.is_empty() and offset.length() < float(attacks[attack_index % attacks.size()].reach) and cooldown <= 0 and clear_target():
			if strategy != 0 and locomotion in ["run", "start", "turn", "land", "stop", "jump"]:
				_update_locomotion(Vector3.ZERO, 0.0, delta)
			else:
				rotation.y = atan2(offset.x, offset.z)
				begin_move(attacks[attack_index % attacks.size()])
				attack_index += 1
		elif offset.length() > 0.45:
			var goal := _chase_goal(delta)
			var heading: Vector3 = lab.route_direction(global_position, goal) if is_instance_valid(lab) else (goal - global_position).normalized()
			if strategy == 0 and clear_target(): heading = offset.normalized()
			var speed := run_speed if offset.length() > run_distance or strategy == 0 else walk_speed
			if principal and Vector2(global_position.x - goal.x, global_position.z - goal.z).length() < 0.45: speed = 0
			navigation_intent = heading * speed
			if escape_left > 0:
				escape_left -= delta
				heading = escape_direction
				speed = run_speed
			if heading.length_squared() > 0.001:
				if is_on_floor() and test_move(global_transform, heading * 0.25):
					var raised := global_transform
					raised.origin.y += obstacle_height
					if not test_move(global_transform, Vector3.UP * obstacle_height) and not test_move(raised, heading * 0.35):
						velocity.y = sqrt(2 * gravity * obstacle_height)
						jump_left = 0.6
						locomotion = "jump"
						play(&"mie/running_jump")
						audio.action("jump")
					else:
						heading = steer(heading)
			_update_locomotion(heading, speed, delta)
		else: _update_locomotion(Vector3.ZERO, 0.0, delta)
	var was_grounded := is_on_floor()
	move_and_slide()
	if not was_grounded and is_on_floor(): audio.action("land")
	if velocity.y <= 0: apply_floor_snap()
	_recover_stuck(delta)
	audio.tick(delta)

func rage() -> float:
	return clampf(1.0 - float(health) / max_health, 0, 1)

func _chase_goal(delta: float) -> Vector3:
	var away := global_position - target.global_position
	away.y = 0
	if away.length_squared() < 0.01: away = global_basis.z
	if principal:
		var distance := lerpf(boss_initial_distance, 0.55, minf(1, rage() * 1.7))
		return target.global_position + away.normalized() * distance
	if strategy == 2 and is_instance_valid(role):
		flank_left -= delta
		if flank_left > 0:
			if flank_goal == Vector3.ZERO:
				var side := 1.0 if scatter_direction.x >= 0 else -1.0
				flank_goal = target.global_position + away.normalized().rotated(Vector3.UP, side * PI * 0.5) * role.flank_radius
			if global_position.distance_to(flank_goal) > 0.4: return flank_goal
	return target.global_position

func _update_ranged(offset: Vector3, delta: float) -> void:
	var throws := moves.filter(func(entry: Node) -> bool: return entry.kind == 2)
	rotation.y = lerp_angle(rotation.y, atan2(offset.x, offset.z), minf(1, delta * 8))
	if cooldown <= 0 and offset.length() <= role.ranged_distance + 2 and clear_target() and not throws.is_empty():
		begin_move(throws[throw_index % throws.size()])
		throw_index += 1
	else:
		var goal: Vector3 = target.global_position + (-offset).normalized() * role.ranged_distance
		if absf(offset.length() - role.ranged_distance) < 0.6:
			_update_locomotion(Vector3.ZERO, 0, delta)
		else:
			var heading: Vector3 = lab.route_direction(global_position, goal) if is_instance_valid(lab) else (goal - global_position).normalized()
			if escape_left > 0:
				escape_left -= delta
				heading = escape_direction
			navigation_intent = heading * run_speed
			_update_locomotion(steer_scatter(heading), run_speed, delta)

func fire_energy() -> void:
	if not is_instance_valid(target): return
	audio.play_sphere_launch(move.clip)
	var projectile := ENERGY.new()
	projectile.shooter = self
	projectile.target = target
	if is_instance_valid(lab):
		projectile.visual_scene = lab.energy_visual_scene
		projectile.burn_status = lab.burn_status
	projectile.impact_audio = audio
	projectile.speed = move.projectile_speed
	projectile.radius = move.blast_radius
	projectile.damage = move.damage
	projectile.position = global_position + Vector3.UP * (0.9 * miniature_scale) + global_basis.z * 0.15
	projectile.direction = (target.global_position - projectile.position).normalized()
	get_parent().add_child(projectile)
	projectiles_fired += 1

func _recover_stuck(delta: float) -> void:
	if state not in ["chase", "scatter"] or navigation_intent.length() < 0.2:
		stuck_time = 0
		return
	var actual := get_real_velocity()
	if Vector2(actual.x, actual.z).length() > 0.15:
		stuck_time = 0
		stuck_jumps = 0
		return
	stuck_time += delta
	if stuck_time >= stuck_escape_seconds:
		for angle in [PI * 0.5, -PI * 0.5, PI]:
			var candidate := global_basis.z.rotated(Vector3.UP, angle)
			if not test_move(global_transform, candidate * 0.4):
				escape_direction = candidate
				escape_left = escape_seconds
				flank_goal = Vector3.ZERO
				break
		stuck_time = 0
		stuck_jumps = 0
	elif stuck_time >= stuck_jump_seconds * (stuck_jumps + 1) and is_on_floor() and stuck_jumps < 2 and not test_move(global_transform, Vector3.UP * obstacle_height):
		velocity.y = sqrt(2 * gravity * obstacle_height)
		jump_left = 0.6
		locomotion = "jump"
		play(&"mie/running_jump")
		audio.action("jump")
		stuck_jumps += 1

func _normalize_turn_yaw(clip: Animation) -> void:
	for track in clip.get_track_count():
		if clip.track_get_type(track) != Animation.TYPE_ROTATION_3D or not String(clip.track_get_path(track)).ends_with(":mixamorig1_Hips"): continue
		var first: Quaternion = clip.track_get_key_value(track, 0)
		var initial := first.get_euler().y
		var previous := initial
		var accumulated := 0.0
		for key in clip.track_get_key_count(track):
			var q: Quaternion = clip.track_get_key_value(track, key)
			var yaw := q.get_euler().y
			accumulated += wrapf(yaw - previous, -PI, PI)
			previous = yaw
			clip.track_set_key_value(track, key, Quaternion(Vector3.UP, -accumulated) * q)

func _loco(phase: String, clip: StringName) -> void:
	locomotion = phase
	locomotion_time = 0
	locomotion_duration = animation.get_animation(clip).length
	animation.speed_scale = 1
	animation.play(clip, 0.15)

func _update_locomotion(heading: Vector3, speed: float, delta: float) -> void:
	var moving := heading.length_squared() > 0.001 and speed > 0
	if locomotion == "jump":
		if is_on_floor() and jump_left <= 0:
			_loco("land", landing_clip)
	elif locomotion in ["start", "land", "turn", "stop"] and locomotion_time >= locomotion_duration:
		locomotion = "run" if moving and speed == run_speed else ("walk" if moving else "idle")
	if not moving:
		if locomotion == "jump": return
		if locomotion in ["run", "start", "turn", "land"]: _loco("stop", stop_run_clip)
		elif locomotion == "stop" and locomotion_time < locomotion_duration: return
		else:
			locomotion = "idle"
			play(&"mie/idle")
		return
	var yaw := atan2(heading.x, heading.z)
	if locomotion == "stop": locomotion = "idle"
	if speed == run_speed and locomotion in ["idle", "walk"]: _loco("start", start_run_clip)
	elif strategy != 0 and locomotion == "run" and turn_wait <= 0 and absf(angle_difference(rotation.y, yaw)) > deg_to_rad(turn_threshold_degrees):
		turn_from = rotation.y
		turn_to = yaw
		turn_wait = turn_cooldown
		_loco("turn", turn_run_clip)
	if locomotion == "turn":
		rotation.y = lerp_angle(turn_from, turn_to, smoothstep(0, locomotion_duration, locomotion_time))
		heading = global_basis.z
		speed *= 0.35
	else:
		rotation.y = lerp_angle(rotation.y, yaw, minf(1, delta * 9))
	if locomotion == "start": speed *= lerpf(0.15, 1, clampf(locomotion_time / locomotion_duration, 0, 1))
	if locomotion not in ["jump", "start", "turn", "land"]:
		locomotion = "run" if speed == run_speed else "walk"
		var clip: StringName = run_clip if locomotion == "run" else &"mie/walking"
		play(clip, clampf(speed / maxf(float(nominal_speeds.get(clip, speed)), 0.05), 0.5, 2.5))
	velocity.x = heading.x * speed
	velocity.z = heading.z * speed

func steer_scatter(heading: Vector3) -> Vector3:
	if not test_move(global_transform, heading * 0.3): return heading
	return steer(heading)

func steer(heading: Vector3) -> Vector3:
	for angle in [0.6, -0.6, 1.2, -1.2, 1.8, -1.8]:
		var candidate := heading.rotated(Vector3.UP, angle)
		if not test_move(global_transform, candidate * 0.3): return candidate
	return Vector3.ZERO

func clear_target() -> bool:
	if not is_instance_valid(target): return false
	var query := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP * 0.12, target.global_position, 1)
	query.exclude = [get_rid(), target.get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func begin_show() -> void:
	if state in ["dead", "pooled"]: return
	var shows := moves.filter(func(entry: Node) -> bool: return entry.kind == 1)
	if shows.is_empty(): return
	var entry: Node = shows[show_index % shows.size()]
	if show_index % 3 == 2:
		var dances := shows.filter(func(candidate: Node) -> bool: return String(candidate.clip).begins_with("mie/dancing"))
		if not dances.is_empty(): entry = dances[randi_range(0, dances.size() - 1)]
	wall_tangent = Vector3.ZERO
	if "cover_sneak" in String(entry.clip):
		for direction in [Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK]:
			var ray := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP * 0.12, global_position + Vector3.UP * 0.12 + direction * 0.5, 1)
			ray.exclude = [get_rid()]
			var hit := get_world_3d().direct_space_state.intersect_ray(ray)
			if not hit.is_empty() and absf(hit.normal.y) < 0.3:
				wall_tangent = Vector3.UP.cross(hit.normal).normalized()
				rotation.y = atan2(hit.normal.x, hit.normal.z)
				break
		if wall_tangent == Vector3.ZERO: entry = shows[0]
	begin_move(entry)
	if not is_instance_valid(lab) or lab.claim_voice(self):
		if audio.exclaim(): duration = maxf(duration, audio.voice.stream.get_length())
	show_index += 1
	show_timer = show_interval

func begin_move(entry: Node) -> void:
	if state in ["dead", "pooled"]: return
	_finish_emergence_visual()
	move = entry
	locomotion = "idle"
	state = "throw" if entry.kind == 2 else ("attack" if entry.kind == 0 else "show")
	elapsed = 0
	applied = false
	duration = animation.get_animation(entry.clip).length
	animation.speed_scale = 1.0
	animation.play(entry.clip, 0.12)
	if entry.kind == 0 and is_on_floor():
		velocity.y = entry.jump_speed
		if entry.jump_speed > 0: audio.action("jump")

func preview_clip(clip: StringName) -> void:
	if state in ["dead", "pooled"]: return
	_finish_emergence_visual()
	state = "preview"
	locomotion = "idle"
	visual.scale = Vector3.ONE * miniature_scale
	visual.position = model_offset * miniature_scale
	animation.speed_scale = 1.0
	animation.play(clip, 0.12)

func reset_for_spawn(at: Vector3) -> void:
	if power_fx != null:
		power_fx.stop()
		power_fx.set_paused(false)
	if spawn_tween != null:
		spawn_tween.kill()
		spawn_tween = null
	process_mode = Node.PROCESS_MODE_INHERIT
	set_physics_process(true)
	global_position = at
	rotation = Vector3.ZERO
	health = max_health if principal else copy_hits
	state = "chase"
	elapsed = 0
	duration = 0
	cooldown = 0
	recovery = 0
	show_timer = show_interval
	show_index = 0
	attack_index = 0
	throw_index = 0
	projectiles_fired = 0
	move = null
	applied = false
	velocity = Vector3.ZERO
	locomotion = "idle"
	locomotion_time = 0
	turn_wait = 0
	jump_left = 0
	scatter_left = 0
	flank_goal = Vector3.ZERO
	flank_left = role.flank_seconds if is_instance_valid(role) else 0
	stuck_time = 0
	stuck_jumps = 0
	escape_left = 0
	wall_tangent = Vector3.ZERO
	navigation_intent = Vector3.ZERO
	gate = null
	gate_requested = false
	gate_retry = 0
	collision_layer = active_collision_layer
	collision_mask = active_collision_mask
	visual.scale = Vector3.ONE * miniature_scale
	visual.position = model_offset * miniature_scale
	audio.stop_voice()
	audio.set_paused(false)
	audio.footsteps.stop()
	audio.effect.stop()
	audio.last_position = at
	audio.travel = 0
	audio.step_wait = 0
	animation.play(&"mie/idle", 0)
	animation.advance(0)
	show()

func begin_emergence(direction: Vector3, distance: float) -> void:
	scatter_direction = direction
	scatter_left = scatter_seconds
	emergence_distance = distance
	emergence_duration = power_fx.emergence_seconds
	state = "emerge"
	elapsed = 0
	rotation.y = atan2(direction.x, direction.z)
	visual.scale = Vector3.ONE * miniature_scale * 0.15
	visual.position = model_offset * visual.scale.x
	animation.play(&"mie/idle", 0)
	animation.advance(0)
	power_fx.emit_copy(power_fx.reference_height * miniature_scale, emergence_duration + 0.2, copy_aura_color)

func preview_transformation() -> void:
	if not principal or state in ["dead", "pooled"]: return
	state = "shrink"
	elapsed = 0
	velocity = Vector3.ZERO
	visual.scale = Vector3.ONE
	visual.position = model_offset
	play(&"mie/idle")
	if is_instance_valid(audio):audio.play_shrink_cue()
	if power_fx != null: power_fx.stop()

func _finish_emergence_visual() -> void:
	if state != "emerge": return
	visual.scale = Vector3.ONE * miniature_scale
	visual.position = model_offset * miniature_scale

func begin_gate(door: Node, height: float, request_at: float) -> void:
	gate = door
	gate_requested = false
	gate_request_at = request_at
	state = "gate"
	elapsed = 0
	locomotion = "jump"
	velocity.x = 0
	velocity.z = 0
	velocity.y = sqrt(2 * gravity * height)
	animation.play(&"mie/jump", 0.08)
	audio.action("jump")

func play(clip: StringName, speed: float = 1.0) -> void:
	if not animation.has_animation(clip): return
	animation.speed_scale = speed
	if animation.assigned_animation != clip or not animation.is_playing(): animation.play(clip, 0.12)

func take_bullet_hit(amount: int, point: Vector3) -> void:
	var before := health
	take_damage(amount)
	if health < before: FEEDBACK.impact(self, self, point, true, false)
	elif state != "dead": burst(point)

func take_damage(amount: int) -> void:
	if amount <= 0 or not vulnerable(): return
	_finish_emergence_visual()
	health = maxi(0, health - (amount if principal else 1))
	health_changed.emit()
	elapsed = 0
	if health == 0:
		state = "dead"
		play(&"mie/dying")
		animation.play(&"mie/dying", 0)
		animation.advance(0)
		audio.stop_voice()
		audio.action("hurt")
		duration = animation.get_animation(&"mie/dying").length
		collision_layer = 0
		died.emit()
	else:
		var running := locomotion in ["run", "start", "turn", "land"] or Vector2(velocity.x, velocity.z).length() > 0.7
		var clip: StringName = (&"mie/running_hit_short" if strategy == 0 else &"mie/running_hit") if running else &"mie/hit_fromstand"
		last_hit_clip = clip
		state = "hurt"
		animation.speed_scale = 1
		animation.play(clip, 0)
		animation.advance(0)
		audio.stop_voice()
		audio.action("hurt")
		duration = animation.get_animation(clip).length
		recovery = duration + recovery_seconds if principal else 0.0

func burst(point: Vector3) -> void:
	var effect := BURST.new()
	if not principal: effect.tint = copy_aura_color
	get_parent().add_child(effect)
	effect.global_position = point

func emit_wave(reach: float) -> void:
	var wave := ARC.new()
	wave.reach = reach
	get_parent().add_child(wave)
	wave.global_transform = Transform3D(global_basis, global_position)
	# Same Angelastri ribbon, lowered to the miniature's chest; reach stays exact.
	wave.position.y -= 1.1 - miniature_scale * 0.9
