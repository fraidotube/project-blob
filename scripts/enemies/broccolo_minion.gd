extends CharacterBody3D
## Copia minuta del modello Broccolo: inseguimento e soli attacchi ravvicinati.

@export_group("Vita e movimento")
## Numero di colpi base necessari per eliminarlo.
@export_range(1, 20, 1) var max_health := 3
## Velocita' di inseguimento in metri al secondo.
@export_range(0.2, 4.0, 0.1) var move_speed := 1.8
## Intervallo medio tra salti durante l'inseguimento.
@export_range(0.5, 5.0, 0.1) var jump_interval := 2.8
## Intervallo medio tra brevi sequenze di passo furtivo.
@export_range(0.5, 5.0, 0.1) var sneak_interval := 3.2
@export_group("Attacco corpo a corpo")
## Raggio entro cui inizia l'animazione di calcio.
@export_range(0.2, 2.0, 0.05) var attack_distance := 0.75
## Pausa minima tra due calci.
@export_range(0.1, 2.0, 0.05) var attack_cooldown := 0.8
## Danno al player per ogni calcio connesso.
@export_range(1, 20, 1) var attack_damage := 5
## Frazione dell'animazione FlyingKick al cui impatto controllare il player.
@export_range(0.0, 1.0, 0.05) var hit_timing := 0.45

const MINION_SCALE := 0.11
const HIT_CLIPS: Array[StringName] = [&"mie/hit_fromstand", &"mie/running_hit", &"mie/running_hit_short"]
const DEATH_CLIP: StringName = &"mie/dying"
const ATTACK_CLIP: StringName = &"mie/FlyingKick"
const RUN_CLIP: StringName = &"mie/walking"

var health := 0
var player: CharacterBody3D
var animation: AnimationPlayer
var body_visual: Node3D
var attack_timer := 0.0
var attack_elapsed := 0.0
var attack_duration := 0.0
var attack_applied := false
var hurt_timer := 0.0
var jump_timer := 0.0
var sneak_timer := 0.0
var sneaking := false
var sneak_remaining := 0.0
var jump_anim_active := false
var dead := false
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	health = max_health
	floor_snap_length = 0.12
	floor_constant_speed = true
	body_visual = get_node_or_null("Broccolo") as Node3D
	if body_visual == null:
		push_error("BroccoloMinion: manca il modello Broccolo nella scena istanziata.")
		queue_free()
		return
	body_visual.scale = Vector3.ONE * MINION_SCALE
	for collision_object in body_visual.find_children("*", "CollisionObject3D", true, false):
		collision_object.collision_layer = 0
		collision_object.collision_mask = 0
	animation = body_visual.get_node_or_null("AnimationPlayer") as AnimationPlayer
	if animation == null:
		push_error("BroccoloMinion: manca AnimationPlayer.")
		queue_free()
		return
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.055
	capsule.height = 0.22
	collision.shape = capsule
	collision.position.y = 0.11
	add_child(collision)
	collision_layer = 1
	collision_mask = 1
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	jump_timer = rng.randf_range(1.0, jump_interval)
	sneak_timer = rng.randf_range(1.0, sneak_interval)
	_play(RUN_CLIP)

func _physics_process(delta: float) -> void:
	if dead:return
	if not is_instance_valid(player) or player.is_dead:
		velocity.x = move_toward(velocity.x, 0.0, move_speed * delta)
		velocity.z = move_toward(velocity.z, 0.0, move_speed * delta)
		if not is_on_floor():velocity.y -= 18.0 * delta
		move_and_slide()
		return
	attack_timer = maxf(0.0, attack_timer - delta)
	if sneaking:
		sneak_remaining -= delta
		if sneak_remaining <= 0.0:sneaking = false
	if jump_anim_active and (animation.assigned_animation != &"mie/running_jump" or not animation.is_playing()):
		jump_anim_active = false
	if hurt_timer > 0.0:
		hurt_timer = maxf(0.0, hurt_timer - delta)
		velocity.x = 0.0
		velocity.z = 0.0
		if not is_on_floor():velocity.y -= 18.0 * delta
		else:velocity.y = -0.35
		move_and_slide()
		if hurt_timer == 0.0:_play(RUN_CLIP)
		return
	jump_timer -= delta
	sneak_timer -= delta
	var to_player := player.global_position - global_position
	to_player.y = 0.0
	var distance := to_player.length()
	if attack_duration > 0.0:
		attack_elapsed += delta
		if not attack_applied and attack_elapsed >= attack_duration * hit_timing:
			attack_applied = true
			if distance <= attack_distance + 0.25 and _has_clear_path():player.take_damage(attack_damage)
		if attack_elapsed >= attack_duration:
			attack_duration = 0.0
			_play(RUN_CLIP)
	elif distance <= attack_distance:
		velocity.x = 0.0
		velocity.z = 0.0
		_face(to_player, delta)
		if attack_timer <= 0.0:_start_attack()
	else:
		if distance > 0.05:
			var direction := to_player.normalized()
			if is_on_floor() and test_move(global_transform, direction * move_speed * delta * 1.4):
				direction = _steer(direction)
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
			_face(direction, delta)
			if jump_timer <= 0.0 and is_on_floor():
				velocity.y = 2.4
				jump_timer = rng.randf_range(jump_interval, jump_interval * 1.8)
				jump_anim_active = true
				_play(&"mie/running_jump")
			elif sneak_timer <= 0.0:
				sneaking = true
				sneak_remaining = rng.randf_range(0.8, 1.8)
				sneak_timer = rng.randf_range(sneak_interval, sneak_interval * 1.8)
				_play(&"mie/walking_sneaky")
			else:
				if jump_anim_active and animation.assigned_animation == &"mie/running_jump" and animation.is_playing():
					pass
				else:
					_play(&"mie/walking_sneaky" if sneaking else RUN_CLIP)
	if not is_on_floor():velocity.y -= 18.0 * delta
	else:velocity.y = -0.35
	move_and_slide()
	apply_floor_snap()

func _start_attack() -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	attack_elapsed = 0.0
	attack_applied = false
	attack_timer = attack_cooldown
	attack_duration = animation.get_animation(ATTACK_CLIP).length
	_play(ATTACK_CLIP)

func _face(direction: Vector3, delta: float) -> void:
	if direction.length_squared() > 0.0001:
		rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), minf(9.0 * delta, 1.0))

func _steer(direction: Vector3) -> Vector3:
	for angle in [0.0, 0.55, -0.55, 1.1, -1.1, 1.7, -1.7]:
		var candidate := direction.rotated(Vector3.UP, angle)
		if not test_move(global_transform, candidate * 0.18):return candidate
	return Vector3.ZERO

func _has_clear_path() -> bool:
	var query := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP * 0.12, player.global_position + Vector3.UP * 0.12, 1)
	query.exclude = [get_rid(), player.get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func take_bullet_hit(amount: int, _hit_point: Vector3) -> void:
	take_damage(amount)

func take_damage(amount: int) -> void:
	if dead or amount <= 0:return
	health -= amount
	if health <= 0:
		dead = true
		attack_duration = 0.0
		velocity = Vector3.ZERO
		_play(DEATH_CLIP)
		collision_layer = 0
		collision_mask = 0
		await animation.animation_finished
		queue_free()
	else:
		attack_duration = 0.0
		var clip: StringName = HIT_CLIPS[rng.randi_range(0, HIT_CLIPS.size() - 1)]
		hurt_timer = animation.get_animation(clip).length
		velocity.x = 0.0
		velocity.z = 0.0
		_play(clip)

func _play(clip: StringName) -> void:
	if animation == null or not animation.has_animation(clip):return
	if animation.assigned_animation != clip or not animation.is_playing():
		animation.play(clip, 0.08)
