extends CharacterBody3D

@export var max_health := 40
@export var walk_speed := 1.2
@export var run_speed := 4.0
const FEEDBACK := preload("res://scripts/effects/melee_feedback.gd")
const INVULNERABLE_SHADER := preload("res://scripts/effects/angelastri_invulnerable.gdshader")
const IMPACT_WAVE := preload("res://scripts/effects/zombie_attack_arc_3d.gd")
var invulnerable_material: ShaderMaterial
var idle_sound_left := 6.0
var health := 40
var encounter: Node
var presentation: Node3D
var player: CharacterBody3D
var animation: AnimationPlayer
var state := "chase"
var elapsed := 0.0
var duration := 0.0
var attack_hit := false
var attack_index := 0
var attack_cooldown := 1.2
var bite_cooldown := 8.0
var dodge_cooldown := 0.0
var reaction_cooldown := 0.0
var dodge_direction := Vector3.ZERO
var grab_state: Dictionary = {}
var bar: ProgressBar
var hud: CanvasLayer
var rng := RandomNumberGenerator.new()
var navigation: NavigationAgent3D
var rage := 0.0
var bite_connected := false
@export var step_height := 0.35

func configure(owner_encounter: Node, actor_presentation: Node3D) -> void:
	encounter = owner_encounter
	presentation = actor_presentation
	player = encounter.player
	animation = presentation.animation
	rng.randomize()
	health = max_health
	floor_snap_length = 0.45
	floor_max_angle = deg_to_rad(50.0)
	floor_constant_speed = true
	var actor: Node3D = presentation.model
	global_transform = actor.global_transform
	actor.reparent(self, true)
	actor.transform = Transform3D.IDENTITY
	invulnerable_material = ShaderMaterial.new()
	invulnerable_material.shader = INVULNERABLE_SHADER
	for mesh in actor.find_children("*", "MeshInstance3D", true, false):
		if mesh.visible: mesh.material_overlay = invulnerable_material
	# Transfer the user's collision to the moving/damage body. Leaving a second
	# collider on the visual body blocks our LOS ray and intercepts weapon hits.
	var supplied_shape := actor.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if supplied_shape != null: supplied_shape.reparent(self, true)
	if actor is CollisionObject3D:
		actor.collision_layer = 0
		actor.collision_mask = 0
	collision_layer = 1
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.8
	shape.shape = capsule
	shape.position.y = 0.95
	if supplied_shape == null: add_child(shape)
	else: shape.free()
	navigation = NavigationAgent3D.new()
	navigation.path_desired_distance = 0.4
	navigation.target_desired_distance = 1.1
	add_child(navigation)
	for clip in [&"mie/walking", &"mie/running", &"mie/idle"]:
		animation.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
	for clip in [&"mie/zombie_attack1", &"mie/zombie_attack2", &"mie/bite_neck", &"mie/dodging", &"mie/dodging_right", &"mie/ducking", &"mie/hit_reaction1", &"mie/hit_reaction2", &"mie/death"]:
		animation.get_animation(clip).loop_mode = Animation.LOOP_NONE
	presentation.sequence = false
	presentation.presentation_stage = "combat"
	_build_hud()
	_play(&"mie/idle")
	var weapon: Node = player.get_node("Head/Camera3D/WeaponHolder")
	weapon.enable_racket_combat()
	GameplayUI.clear_notice()

func _build_hud() -> void:
	hud = CanvasLayer.new()
	hud.layer = 8
	add_child(hud)
	var panel := VBoxContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	panel.offset_left = -250
	panel.offset_right = 250
	panel.offset_top = 22
	var title := Label.new()
	title.text = "ANGELASTRI"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	panel.add_child(title)
	bar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(500, 22)
	bar.max_value = max_health
	bar.value = health
	bar.show_percentage = false
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("a42c73")
	bar.add_theme_stylebox_override("fill", fill)
	panel.add_child(bar)

func _play(clip: StringName) -> void:
	if animation.assigned_animation != clip or not animation.is_playing():
		animation.play(clip, 0.2)

func _process(delta: float) -> void:
	if invulnerable_material == null: return
	invulnerable_material.set_shader_parameter("active", 1.0 if state in ["attack", "bite", "hurt", "dodge"] else 0.0)
	if state == "chase" and is_instance_valid(player) and not player.is_dead:
		idle_sound_left -= delta
		if idle_sound_left <= 0.0:
			FEEDBACK.play_sound(self, "res://assets/audio/enemy/zombieidle2.mp3")
			idle_sound_left = rng.randf_range(7.0, 12.0)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player): return
	if player.is_dead:
		release_player()
		hud.hide()
		velocity = Vector3.ZERO
		return
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	bite_cooldown = maxf(0.0, bite_cooldown - delta)
	dodge_cooldown = maxf(0.0, dodge_cooldown - delta)
	reaction_cooldown = maxf(0.0, reaction_cooldown - delta)
	elapsed += delta
	if not is_on_floor(): velocity.y -= 20.0 * delta
	else: velocity.y = -0.5
	var direction := player.global_position - global_position
	direction.y = 0.0
	var distance := direction.length()
	velocity.x = 0.0
	velocity.z = 0.0
	match state:
		"chase":
			_face(direction, delta)
			if attack_cooldown == 0.0 and distance < 1.65 and _clear_to_player():
				_begin_attack(bite_cooldown == 0.0 and distance < lerpf(1.2, 1.6, rage))
			elif distance > 1.25:
				var speed := run_speed if distance > 5.0 else walk_speed
				var heading := direction.normalized()
				if NavigationServer3D.map_get_iteration_id(navigation.get_navigation_map()) > 0:
					navigation.target_position = player.global_position
					var path_direction := navigation.get_next_path_position() - global_position
					path_direction.y = 0.0
					if path_direction.length() > 0.1: heading = path_direction.normalized()
				var travel := _steer(heading) * speed * lerpf(1.0, 1.25, rage)
				velocity.x = travel.x
				velocity.z = travel.z
				_play(&"mie/running" if speed == run_speed else &"mie/walking")
			else:
				_play(&"mie/idle")
		"attack", "bite":
			if elapsed < duration * 0.25: _face(direction, delta)
			if elapsed < duration * 0.25 and distance > 0.95:
				velocity.x = direction.normalized().x * 1.4
				velocity.z = direction.normalized().z * 1.4
			if state == "bite" and elapsed >= duration * 0.25 and not attack_hit:
				attack_hit = true
				if distance < lerpf(1.35, 1.7, rage) and _clear_to_player(): _grab_player()
			if state == "bite" and not grab_state.is_empty() and elapsed >= duration * 0.55 and not bool(grab_state.get("damaged", false)):
				grab_state["damaged"] = true
				player.take_damage(24)
				health = mini(max_health, health + 4)
				bar.value = health
			if state == "bite" and not grab_state.is_empty(): _bite_camera(delta)
			if state == "attack" and elapsed >= duration * 0.45 and not attack_hit:
				attack_hit = true
				var wave := IMPACT_WAVE.new()
				wave.name = "ZombieImpactWave"
				get_tree().current_scene.add_child(wave)
				wave.global_transform = global_transform
				if distance < 1.95 and _clear_to_player() and global_basis.z.dot(direction.normalized()) > 0.35:
					player.take_damage(10 if attack_index % 2 == 1 else 16)
			if elapsed >= duration:
				if state == "bite" and bite_connected: bite_cooldown = lerpf(8.0, 5.0, rage)
				release_player()
				state = "chase"
				attack_cooldown = lerpf(1.3, 0.45, rage)
		"dodge":
			if elapsed >= duration: state = "chase"
		"hurt":
			if elapsed >= duration: state = "chase"
		"dead":
			return
	var horizontal_motion := Vector3(velocity.x, 0.0, velocity.z) * delta
	if is_on_floor() and horizontal_motion.length_squared() > 0.000001:
		if test_move(global_transform, horizontal_motion) and _can_step(horizontal_motion):
			global_position.y += step_height
	move_and_slide()
	if velocity.y <= 0.0: apply_floor_snap()
	if state == "chase" and animation.assigned_animation in [&"mie/walking", &"mie/running"]:
		var actual := get_real_velocity()
		var nominal := run_speed if animation.assigned_animation == &"mie/running" else walk_speed
		animation.speed_scale = clampf(Vector2(actual.x, actual.z).length() / nominal, 0.05, 1.5)

func _can_step(motion: Vector3) -> bool:
	var raised := global_transform
	if test_move(raised, Vector3.UP * step_height): return false
	raised.origin.y += step_height
	if test_move(raised, motion): return false
	raised.origin += motion
	var result := KinematicCollision3D.new()
	if not test_move(raised, Vector3.DOWN * (step_height + 0.1), result): return false
	return result.get_normal().y > 0.7

func _face(direction: Vector3, delta: float) -> void:
	if direction.length_squared() > 0.001:
		global_rotation.y = lerp_angle(global_rotation.y, atan2(direction.x, direction.z), minf(5.0 * delta, 1.0))

func _clear_to_player() -> bool:
	var query := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP * 1.3, player.global_position + Vector3.UP * 0.3, 1)
	query.exclude = [get_rid(), player.get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func _steer(direction: Vector3) -> Vector3:
	# Check the whole body, including lateral options, instead of stepping through walls.
	for angle in [0.0, 0.6, -0.6, 1.2, -1.2, 1.8, -1.8]:
		var candidate: Vector3 = direction.rotated(Vector3.UP, float(angle))
		if not test_move(global_transform, candidate * 0.65) or _can_step(candidate * 0.65): return candidate
	return Vector3.ZERO

func _begin_attack(bite: bool) -> void:
	animation.speed_scale = 1.0
	attack_index += 1
	state = "bite" if bite else "attack"
	elapsed = 0.0
	attack_hit = false
	bite_connected = false
	var clip: StringName = &"mie/bite_neck" if bite else (&"mie/zombie_attack1" if attack_index % 2 == 1 else &"mie/zombie_attack2")
	var speed := lerpf(1.0, 1.8, rage) if bite else lerpf(1.0, 1.3, rage)
	duration = animation.get_animation(clip).length / speed
	animation.play(clip, 0.15, speed)
	FEEDBACK.play_sound(self, "res://assets/audio/enemy/" + ("zombiesniffingsfx.mp3" if bite else ("zombieattack.mp3" if attack_index % 2 == 1 else "zombieattack2sfx.mp3")))
	if bite:
		bite_cooldown = lerpf(3.0, 1.0, rage)

func _grab_player() -> void:
	if not grab_state.is_empty(): return
	bite_connected = true
	FEEDBACK.play_sound(self, "res://assets/audio/enemy/zombieeatingsfx.mp3")
	var weapon: Node = player.get_node("Head/Camera3D/WeaponHolder")
	grab_state = {"physics": player.is_physics_processing(), "input": player.is_processing_unhandled_input(),
		"weapon_process": weapon.is_processing(), "weapon_physics": weapon.is_physics_processing(),
		"camera_rotation": player.get_node("Head/Camera3D").rotation,
		"camera_position": player.get_node("Head/Camera3D").position}
	player.velocity = Vector3.ZERO
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	weapon.set_process(false)
	weapon.set_physics_process(false)
	# Turn the held player's existing camera toward the attacker without relocating
	# the player through scenery or creating another model/camera at the grab.
	var camera: Camera3D = player.get_node("Head/Camera3D")
	camera.look_at(global_position + Vector3.UP * 1.55, Vector3.UP)
	grab_state["bite_rotation"] = camera.rotation

func _bite_camera(delta: float) -> void:
	var camera: Camera3D = player.get_node("Head/Camera3D")
	var pulse := sin(elapsed * 18.0) * 0.015
	var target: Vector3 = grab_state.bite_rotation + Vector3(0.1 + pulse, 0, 0.22)
	camera.rotation = camera.rotation.lerp(target, 1.0 - exp(-delta * 7.0))
	camera.position = camera.position.lerp(grab_state.camera_position + Vector3(0.05, -0.08 + pulse, 0.025), 1.0 - exp(-delta * 7.0))

func release_player() -> void:
	if grab_state.is_empty() or not is_instance_valid(player): return
	var weapon: Node = player.get_node("Head/Camera3D/WeaponHolder")
	player.set_physics_process(grab_state.physics)
	player.set_process_unhandled_input(grab_state.input)
	weapon.set_process(grab_state.weapon_process)
	weapon.set_physics_process(grab_state.weapon_physics)
	player.get_node("Head/Camera3D").rotation = grab_state.camera_rotation
	player.get_node("Head/Camera3D").position = grab_state.camera_position
	grab_state.clear()

func try_dodge_shot(_hit_point: Vector3) -> bool:
	if state == "dead": return true
	if dodge_cooldown == 0.0 and state == "chase":
		var side := 1.0 if rng.randf() > 0.5 else -1.0
		dodge_direction = global_basis.x * side
		if test_move(global_transform, dodge_direction * 0.9): dodge_direction = -dodge_direction
		if test_move(global_transform, dodge_direction * 0.9): dodge_direction = Vector3.ZERO
		var clip: StringName = &"mie/ducking" if dodge_direction == Vector3.ZERO else (&"mie/dodging_right" if side > 0.0 else &"mie/dodging")
		state = "dodge"
		animation.speed_scale = 1.0
		elapsed = 0.0
		duration = animation.get_animation(clip).length
		dodge_cooldown = 1.6
		animation.play(clip, 0.12)
	return true

func take_bullet_hit(_amount: int, hit_point: Vector3) -> void:
	try_dodge_shot(hit_point)

func take_damage(amount: int) -> void:
	if state in ["dead", "attack", "bite", "hurt", "dodge"] or amount <= 0: return
	health = maxi(0, health - amount)
	animation.speed_scale = 1.0
	FEEDBACK.play_sound(self, "res://assets/audio/enemy/zombie_hit.mp3")
	rage = maxf(rage, 1.0 - float(health) / max_health)
	bar.value = health
	if health == 0:
		release_player()
		state = "dead"
		encounter.event.stage = "defeated"
		animation.play(&"mie/death", 0.15)
		collision_layer = 0
		hud.hide()
	else:
		release_player()
		state = "hurt"
		elapsed = 0.0
		var clip: StringName = &"mie/hit_reaction1" if rng.randf() > 0.5 else &"mie/hit_reaction2"
		duration = animation.get_animation(clip).length
		reaction_cooldown = 1.2
		animation.play(clip, 0.12)

func _exit_tree() -> void:
	release_player()
