extends Area3D

@export var speed: float = 10.5
@export var lifetime: float = 5.0

# Aspetto
@export var core_radius: float = 0.13
@export var glow_radius: float = 0.22
@export var pulse_speed: float = 7.0
@export var pulse_amount: float = 0.12

var velocity: Vector3 = Vector3.ZERO
var damage: int = 0
var shooter: Node = null
var remaining_lifetime: float = 0.0
var time_alive: float = 0.0

var core_mesh: MeshInstance3D = null
var glow_mesh: MeshInstance3D = null
var glow_light: OmniLight3D = null
var particles: GPUParticles3D = null

func _ready() -> void:
	remaining_lifetime = lifetime
	body_entered.connect(_on_body_entered)
	_build_visual_effect()

func setup(
	new_direction: Vector3,
	new_damage: int,
	new_shooter: Node
) -> void:
	velocity = new_direction.normalized() * speed
	damage = new_damage
	shooter = new_shooter

func _physics_process(delta: float) -> void:
	global_position += velocity * delta

	time_alive += delta
	remaining_lifetime -= delta

	var pulse := 1.0 + sin(time_alive * pulse_speed) * pulse_amount

	if core_mesh != null:
		core_mesh.scale = Vector3.ONE * pulse

	if glow_mesh != null:
		glow_mesh.scale = Vector3.ONE * (1.0 + sin(time_alive * pulse_speed * 0.73) * pulse_amount * 1.6)

	if remaining_lifetime <= 0.0:
		queue_free()

func _build_visual_effect() -> void:
	# Nasconde eventuale vecchia MeshInstance3D bianca presente nella scena.
	for child in get_children():
		if child is MeshInstance3D:
			child.visible = false

	core_mesh = MeshInstance3D.new()
	core_mesh.name = "MagicCore"
	var core := SphereMesh.new()
	core.radius = core_radius
	core.height = core_radius * 2.0
	core.radial_segments = 24
	core.rings = 12
	core_mesh.mesh = core

	var core_mat := StandardMaterial3D.new()
	core_mat.albedo_color = Color(0.22, 0.04, 0.52, 1.0)
	core_mat.emission_enabled = true
	core_mat.emission = Color(0.72, 0.08, 1.0, 1.0)
	core_mat.emission_energy_multiplier = 5.5
	core_mat.roughness = 0.2
	core_mesh.material_override = core_mat
	add_child(core_mesh)

	glow_mesh = MeshInstance3D.new()
	glow_mesh.name = "MagicGlow"
	var glow := SphereMesh.new()
	glow.radius = glow_radius
	glow.height = glow_radius * 2.0
	glow.radial_segments = 24
	glow.rings = 12
	glow_mesh.mesh = glow

	var glow_mat := StandardMaterial3D.new()
	glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_mat.albedo_color = Color(0.45, 0.08, 1.0, 0.20)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(0.55, 0.08, 1.0, 1.0)
	glow_mat.emission_energy_multiplier = 2.8
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow_mat.cull_mode = BaseMaterial3D.CULL_FRONT
	glow_mesh.material_override = glow_mat
	add_child(glow_mesh)

	glow_light = OmniLight3D.new()
	glow_light.name = "MagicLight"
	glow_light.light_color = Color(0.55, 0.12, 1.0, 1.0)
	glow_light.light_energy = 2.2
	glow_light.omni_range = 2.6
	glow_light.shadow_enabled = false
	add_child(glow_light)

	particles = GPUParticles3D.new()
	particles.name = "MagicTrail"
	particles.amount = 36
	particles.lifetime = 0.45
	particles.randomness = 0.35
	particles.local_coords = false
	particles.emitting = true

	var particle_mesh := SphereMesh.new()
	particle_mesh.radius = 0.025
	particle_mesh.height = 0.05
	particle_mesh.radial_segments = 8
	particle_mesh.rings = 4

	var particle_mat := StandardMaterial3D.new()
	particle_mat.albedo_color = Color(0.55, 0.15, 1.0, 0.9)
	particle_mat.emission_enabled = true
	particle_mat.emission = Color(0.65, 0.15, 1.0, 1.0)
	particle_mat.emission_energy_multiplier = 3.0
	particle_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	particle_mesh.material = particle_mat
	particles.draw_pass_1 = particle_mesh

	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 0.09
	process.direction = Vector3(0.0, 0.0, 1.0)
	process.spread = 180.0
	process.initial_velocity_min = 0.1
	process.initial_velocity_max = 0.6
	process.gravity = Vector3.ZERO
	process.scale_min = 0.5
	process.scale_max = 1.3
	particles.process_material = process
	add_child(particles)

func _on_body_entered(body: Node) -> void:
	if body == shooter:
		return

	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

		queue_free()
		return

	queue_free()
