extends Node3D
## Effetto persistente riutilizzato: nessun caricamento durante l'emissione.

@export_group("Trasformazione")
## Colore esterno dell'aura di trasformazione.
@export var power_color := Color(1.0, 0.58, 0.035)
## Altezza del modello a scala1, metri; modello Broccolo circa1,70m.
@export_range(0.5, 3.0, 0.05) var reference_height := 1.7
## Durata dell'aura dopo la fine della riduzione, secondi.
@export_range(0.3, 4.0, 0.1) var power_tail_seconds := 1.4
## Intensita emissiva della fiamma, senza luci o ombre aggiuntive.
@export_range(1.0, 8.0, 0.25) var glow_energy := 3.5
@export_group("Nascita copie")
## Tempo per emergere dal corpo prima della fuga casuale, secondi.
@export_range(0.2, 1.2, 0.05) var emergence_seconds := 0.5
## Durata del getto di particelle sul principale a ogni copia, secondi.
@export_range(0.2, 1.5, 0.05) var emission_seconds := 0.65
## Lampo d'aura arancione durante la duplicazione, secondi.
@export_range(0.08, 0.5, 0.02) var copy_flash_seconds := 0.22
## Intensita del lampo; breve e trasparente per lasciare leggibile la nascita.
@export_range(0.2, 1.0, 0.05) var copy_flash_strength := 0.65
## Intensita bordo arancione delle copie, indipendente dalla protezione hit.
@export_range(0.1, 1.0, 0.05) var copy_rim_strength := 0.4
## Spessore bordo in metri, nello shader mondiale del modello.
@export_range(0.002, 0.015, 0.001) var copy_rim_width := 0.006
## Moltiplicatore emissivo del bordo arancione.
@export_range(1.0, 4.0, 0.25) var copy_rim_glow := 2.0
## Minimo della pulsazione, cosi il bordo non sparisce nei fotogrammi scuri.
@export_range(0.2, 1.0, 0.05) var copy_rim_pulse_floor := 0.7

@onready var shell: MeshInstance3D = $Flames
@onready var sparks: CPUParticles3D = $Sparks
@onready var streaks: CPUParticles3D = $Streaks
@onready var ring: MeshInstance3D = $GroundRing
var shell_material: ShaderMaterial
var spark_material: StandardMaterial3D
var ring_material: StandardMaterial3D
var remaining := 0.0
var lifetime := 1.0
var body_height := 0.34
var age := 0.0
var paused := false
var transforming := false
var particle_defaults: Array[Dictionary] = []
var flash_remaining := 0.0
var base_tint := Color.WHITE

func _ready() -> void:
	shell_material = shell.material_override.duplicate()
	shell.material_override = shell_material
	spark_material = sparks.mesh.material.duplicate()
	sparks.mesh = sparks.mesh.duplicate()
	sparks.mesh.material = spark_material
	streaks.mesh = streaks.mesh.duplicate()
	streaks.mesh.material = spark_material
	ring_material = ring.material_override.duplicate()
	ring.material_override = ring_material
	# I valori nativi sono il profilo per1m; runtime li scala senza perderli.
	for particles in [sparks, streaks]:
		particle_defaults.append({"node": particles, "height": particles.position.y, "radius": particles.emission_sphere_radius, "minimum": particles.initial_velocity_min, "maximum": particles.initial_velocity_max})
	stop()

func ignite(height: float, seconds: float, tint: Color) -> void:
	flash_remaining = 0
	base_tint = tint
	transforming = true
	body_height = maxf(0.25, height)
	lifetime = maxf(0.1, seconds)
	remaining = lifetime
	age = 0
	shell_material.set_shader_parameter("tint", tint)
	shell_material.set_shader_parameter("glow", glow_energy)
	spark_material.albedo_color = tint.lightened(0.25)
	spark_material.emission = tint
	ring_material.albedo_color = tint
	ring_material.emission = tint
	sparks.emitting = true
	streaks.emitting = true
	sparks.restart()
	streaks.restart()
	_layout()
	shell.show()
	show()
	set_process(true)

func emit_copy(height: float, seconds: float, tint: Color) -> void:
	# La prima ondata non deve troncare la coda dorata della trasformazione.
	if transforming and remaining > 0 and shell.visible:
		flash_remaining = minf(copy_flash_seconds, remaining)
		shell_material.set_shader_parameter("tint", tint)
		sparks.restart()
		streaks.restart()
		return
	ignite(height, seconds, tint)
	transforming = false
	flash_remaining = minf(copy_flash_seconds, lifetime)
	shell_material.set_shader_parameter("strength", copy_flash_strength)

func charge(height: float) -> void:
	if remaining <= 0: ignite(height, power_tail_seconds, power_color)
	body_height = maxf(0.25, height)
	remaining = lifetime
	_layout()

func _layout() -> void:
	shell.position.y = body_height * 0.6
	shell.scale = Vector3(body_height * 0.85, body_height * 1.15, body_height * 0.85)
	for settings in particle_defaults:
		var particles: CPUParticles3D = settings.node
		particles.position.y = body_height * float(settings.height)
		particles.emission_sphere_radius = body_height * float(settings.radius)
		particles.initial_velocity_min = body_height * float(settings.minimum)
		particles.initial_velocity_max = body_height * float(settings.maximum)
	ring.position.y = 0.015

func _process(delta: float) -> void:
	if paused: return
	age += delta
	remaining = maxf(0, remaining - delta)
	var was_flashing := flash_remaining > 0
	flash_remaining = maxf(0, flash_remaining - delta)
	if was_flashing and flash_remaining <= 0 and transforming:
		shell_material.set_shader_parameter("tint", base_tint)
	var fade := minf(1, remaining / minf(0.35, lifetime))
	if not transforming:
		fade = copy_flash_strength * minf(1, flash_remaining / 0.08)
		shell.visible = flash_remaining > 0
	shell_material.set_shader_parameter("phase", age)
	shell_material.set_shader_parameter("strength", fade)
	ring.scale = Vector3.ONE * body_height * (0.65 + fmod(age * 1.7, 0.9))
	ring_material.albedo_color.a = fade * (0.5 - fmod(age * 1.7, 0.9) * 0.4)
	sparks.emitting = remaining > 0.25
	streaks.emitting = remaining > 0.25
	if remaining <= 0: stop()

func set_paused(value: bool) -> void:
	paused = value
	sparks.speed_scale = 0 if value else 1
	streaks.speed_scale = 0 if value else 1

func stop() -> void:
	flash_remaining = 0
	transforming = false
	remaining = 0
	sparks.emitting = false
	streaks.emitting = false
	hide()
	set_process(false)
