extends Node3D
## Nucleo, aura e scia derivati dallo stesso effetto approvato.
@export var flame_color := Color(1.0, 0.35, 0.035)
## Altezza normalizzata dell'involucro, metri; non cambia la collisione della sfera.
@export_range(0.15, 0.5, 0.01) var aura_size := 0.25
@onready var aura: Node3D = $Aura
@onready var core: MeshInstance3D = $Core
@onready var orbit: MeshInstance3D = $Orbit
var exploding := false
var elapsed := 0.0
var paused := false
func _ready() -> void:
	add_to_group("broccolo_energy_visuals")
	aura.ignite(aura_size, 60, flame_color)
	aura.position.y = -aura_size * 0.6
	aura.ring.hide()
	aura.streaks.local_coords = false
	aura.sparks.local_coords = false
func aim(heading: Vector3) -> void:
	if heading.length_squared() > 0.001: quaternion = Quaternion(Vector3.UP, -heading.normalized())
func explode(blast_radius: float) -> void:
	exploding = true
	elapsed = 0
	quaternion = Quaternion.IDENTITY
	core.hide()
	orbit.hide()
	aura.ignite(blast_radius * 0.75, 0.4, flame_color)
	aura.position.y = -blast_radius * 0.3
func _process(delta: float) -> void:
	if paused: return
	elapsed += delta
	if exploding:
		scale = Vector3.ONE * lerpf(0.6, 1.8, minf(1, elapsed / 0.4))
		if elapsed >= 0.4: queue_free()
	else:
		core.scale = Vector3.ONE * (1.0 + 0.12 * sin(elapsed * 24))
		orbit.rotation = Vector3(elapsed * 5, elapsed * 3, elapsed * 7)
		aura.ring.hide()
func set_paused(value: bool) -> void:
	paused = value
	aura.set_paused(value)
