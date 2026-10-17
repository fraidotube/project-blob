extends Node3D
## Esplosione luminosa condivisa per emissione, blocco e dissolvenza delle copie.

var tint := Color(0.15, 0.6, 1.0)
var radius := 0.12
var age := 0.0
var ring: MeshInstance3D
var material: StandardMaterial3D

func _ready() -> void:
	ring = MeshInstance3D.new()
	var mesh := TorusMesh.new()
	mesh.inner_radius = radius * 0.85
	mesh.outer_radius = radius
	mesh.rings = 24
	mesh.ring_segments = 8
	ring.mesh = mesh
	material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = tint
	material.emission_enabled = true
	material.emission = tint
	material.emission_energy_multiplier = 2.0
	ring.material_override = material
	add_child(ring)
	var particles := CPUParticles3D.new()
	particles.amount = 26
	particles.lifetime = 0.65
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.direction = Vector3.UP
	particles.spread = 150
	particles.initial_velocity_min = 0.3
	particles.initial_velocity_max = 1.4
	particles.gravity = Vector3(0, -0.5, 0)
	var spark := SphereMesh.new()
	spark.radius = 0.008
	spark.height = 0.016
	spark.material = material
	particles.mesh = spark
	add_child(particles)
	particles.restart()

func _process(delta: float) -> void:
	age += delta
	ring.scale = Vector3.ONE * (0.2 + age * 2.0)
	material.albedo_color.a = maxf(0.0, 1.0 - age / 0.8)
	if age >= 0.85: queue_free()
