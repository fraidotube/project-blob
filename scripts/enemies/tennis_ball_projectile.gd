extends Area3D

signal impacted(
	world_position: Vector3,
	explosive: bool
)


const EXPLOSION_VFX_SCENE: PackedScene = preload(
	"res://assets/vfx/EffettoEsplosione/BigExplosionScene_PB47.tscn"
)


@export_category("Flight")
@export var projectile_gravity: float = 9.8
@export var default_flight_time: float = 0.55
@export var max_lifetime: float = 6.0


@export_category("Damage")
@export var normal_damage_radius: float = 0.80
@export var explosive_damage_radius: float = 5.5


@export_category("Visual")
@export var spin_speed: float = 18.0


@export_category("Explosion VFX")
@export var explosion_vfx_scale: float = 1.0
@export var explosion_vfx_vertical_offset: float = 0.0
@export var explosion_vfx_cleanup_time: float = 3.0


@export_category("Impact Audio")
@export var normal_impact_sound: AudioStream = preload(
	"res://assets/models/enemies/bruno_buozzi/pallina_colpito.mp3"
)
@export var explosive_impact_sound: AudioStream = preload(
	"res://assets/models/enemies/bruno_buozzi/pallina_explosion.mp3"
)
@export_range(-24.0, 12.0, 0.5) var normal_impact_volume_db: float = 0.0
@export_range(-24.0, 12.0, 0.5) var explosive_impact_volume_db: float = 0.0
@export_range(1.0, 100.0, 1.0) var impact_audio_max_distance: float = 35.0


@onready var ball_visual: Node3D = $tennis_ball


var velocity: Vector3 = Vector3.ZERO

var damage: int = 0
var explosive: bool = false
var shooter: Node = null

var launched: bool = false
var has_impacted: bool = false
var lifetime: float = 0.0

var active_gravity: float = 9.8


func _ready() -> void:
	body_entered.connect(
		_on_body_entered
	)


func _physics_process(delta: float) -> void:
	if not launched:
		return

	if has_impacted:
		return

	lifetime += delta

	if lifetime >= max_lifetime:
		queue_free()
		return

	if ball_visual != null:
		ball_visual.rotate_x(
			spin_speed * delta
		)

		ball_visual.rotate_z(
			spin_speed
			* 0.45
			* delta
		)

	velocity.y -= (
		active_gravity
		* delta
	)

	var old_position := global_position

	var new_position := (
		old_position
		+ velocity * delta
	)

	if _sweep_for_collision(
		old_position,
		new_position
	):
		return

	global_position = new_position


func launch(
	start_position: Vector3,
	target_position: Vector3,
	new_damage: int,
	new_explosive: bool,
	new_shooter: Node,
	flight_time: float = -1.0,
	gravity_override: float = -1.0
) -> void:
	global_position = start_position

	damage = new_damage
	explosive = new_explosive
	shooter = new_shooter

	active_gravity = projectile_gravity

	if gravity_override > 0.0:
		active_gravity = gravity_override

	var time := flight_time

	if time <= 0.0:
		time = default_flight_time

	time = maxf(
		time,
		0.05
	)

	var displacement := (
		target_position
		- start_position
	)

	velocity.x = (
		displacement.x
		/ time
	)

	velocity.z = (
		displacement.z
		/ time
	)

	velocity.y = (
		displacement.y
		+ 0.5
		* active_gravity
		* time
		* time
	) / time

	lifetime = 0.0
	has_impacted = false
	launched = true


func _sweep_for_collision(
	from_position: Vector3,
	to_position: Vector3
) -> bool:
	var query := (
		PhysicsRayQueryParameters3D.create(
			from_position,
			to_position
		)
	)

	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = collision_mask

	if (
		shooter != null
		and shooter is CollisionObject3D
	):
		query.exclude = [
			(
				shooter
				as CollisionObject3D
			).get_rid()
		]

	var result := (
		get_world_3d()
		.direct_space_state
		.intersect_ray(query)
	)

	if result.is_empty():
		return false

	var hit_position: Vector3 = result.get(
		"position",
		to_position
	)

	_impact(
		hit_position
	)

	return true


func _on_body_entered(
	body: Node3D
) -> void:
	if not launched:
		return

	if has_impacted:
		return

	if body == shooter:
		return

	_impact(
		global_position
	)


func _impact(
	world_position: Vector3
) -> void:
	if has_impacted:
		return

	has_impacted = true
	launched = false

	global_position = world_position

	_apply_area_damage()

	if explosive:
		_create_explosion_visual(
			world_position
		)

	_play_impact_audio(
		world_position
	)

	impacted.emit(
		global_position,
		explosive
	)

	queue_free()


func _play_impact_audio(
	world_position: Vector3
) -> void:
	var stream := normal_impact_sound
	var volume_db := normal_impact_volume_db

	if explosive:
		stream = explosive_impact_sound
		volume_db = explosive_impact_volume_db

	if stream == null:
		return

	var world := get_tree().current_scene

	if world == null:
		return

	var audio_player := AudioStreamPlayer3D.new()

	audio_player.name = (
		"ExplosiveBallImpactAudio"
		if explosive
		else "NormalBallImpactAudio"
	)

	audio_player.stream = stream
	audio_player.bus = &"SFX"
	audio_player.volume_db = volume_db
	audio_player.max_distance = impact_audio_max_distance

	world.add_child(
		audio_player
	)

	audio_player.global_position = world_position

	audio_player.finished.connect(
		audio_player.queue_free
	)

	audio_player.play()


func _apply_area_damage() -> void:
	if damage <= 0:
		return

	var radius := (
		normal_damage_radius
	)

	if explosive:
		radius = (
			explosive_damage_radius
		)

	for node: Node in (
		get_tree()
		.get_nodes_in_group("player")
	):
		if not is_instance_valid(node):
			continue

		if not node is Node3D:
			continue

		var target := (
			node as Node3D
		)

		var distance := (
			global_position
			.distance_to(
				target.global_position
			)
		)

		if distance > radius:
			continue

		if node.has_method(
			"take_damage"
		):
			node.take_damage(
				damage
			)


func _create_explosion_visual(
	world_position: Vector3
) -> void:
	var world := (
		get_tree().current_scene
	)

	if world == null:
		return

	var explosion_instance := (
		EXPLOSION_VFX_SCENE.instantiate()
	)

	if not explosion_instance is Node3D:
		explosion_instance.queue_free()
		return

	var explosion := (
		explosion_instance
		as Node3D
	)

	world.add_child(
		explosion
	)

	explosion.global_position = (
		world_position
		+ Vector3.UP
		* explosion_vfx_vertical_offset
	)

	explosion.scale = (
		Vector3.ONE
		* explosion_vfx_scale
	)

	_restart_explosion_particles(
		explosion
	)

	var cleanup_time := maxf(
		explosion_vfx_cleanup_time,
		0.1
	)

	get_tree().create_timer(
		cleanup_time
	).timeout.connect(
		func() -> void:
			if is_instance_valid(
				explosion
			):
				explosion.queue_free()
	)


func _restart_explosion_particles(
	root: Node
) -> void:
	for child: Node in (
		root.get_children()
	):
		if child is GPUParticles3D:
			var particles := (
				child
				as GPUParticles3D
			)

			particles.restart()

		_restart_explosion_particles(
			child
		)
