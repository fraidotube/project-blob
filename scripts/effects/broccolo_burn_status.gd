extends Node3D
## Condizione temporanea del laboratorio; usa la salute reale senza modificare il player.
@export_group("Collegamenti")
## Giocatore che riceve il danno, collegamento necessario.
@export var target: CharacterBody3D
## Camera FPS: mostra le fiamme ai bordi solo quando e la camera attiva.
@export var camera: Camera3D
@export_group("Bruciatura")
## Durata dopo ogni impatto diretto, secondi; i colpi rinnovano, non sommano.
@export_range(0.5, 8.0, 0.25) var duration_seconds := 3.0
## Danno a ogni intervallo, oltre al danno iniziale della sfera.
@export_range(1, 20, 1) var tick_damage := 3
## Intervallo del danno, secondi; nessun tick immediato aggiuntivo all'impatto.
@export_range(0.25, 2.0, 0.05) var tick_seconds := 0.75
## Altezza fiamme che avvolgono il corpo, metri dal nodo posto ai piedi.
@export_range(0.5, 2.5, 0.1) var flame_height := 1.7
## Tinta delle fiamme sul corpo e ai bordi della visuale FPS.
@export var flame_color := Color(1.0, 0.24, 0.025)
@onready var flames: Node3D = $BodyFlames
@onready var overlay: ColorRect = $Screen/Flames
var remaining := 0.0
var tick_left := 0.0
var age := 0.0
var paused := false
var damage_applied := 0

func _ready() -> void:
	overlay.material = overlay.material.duplicate()
	stop()

func ignite() -> void:
	if not is_instance_valid(target) or target.is_dead: return
	if remaining <= 0: tick_left = tick_seconds
	remaining = duration_seconds
	age = 0
	flames.ignite(flame_height, duration_seconds, flame_color)
	flames.ring.hide()
	flames.visible = camera == null or not camera.is_current()
	overlay.material.set_shader_parameter("flame_color", flame_color)
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target) or target.is_dead:
		stop()
		return
	if paused: return
	var elapsed := minf(delta, remaining)
	remaining = maxf(0, remaining - delta)
	age += elapsed
	tick_left -= elapsed
	while tick_left <= 0.00001 and not target.is_dead:
		var health_before: int = target.health
		target.take_damage(tick_damage)
		damage_applied += health_before - int(target.health)
		tick_left += tick_seconds
	flames.ring.hide()
	flames.visible = camera == null or not camera.is_current()
	overlay.visible = camera != null and camera.is_current() and not target.is_dead
	overlay.material.set_shader_parameter("phase", age)
	overlay.material.set_shader_parameter("intensity", minf(1, remaining / 0.35))
	if remaining <= 0 or target.is_dead: stop()

func set_paused(value: bool) -> void:
	paused = value
	flames.set_paused(value)

func stop() -> void:
	remaining = 0
	tick_left = 0
	flames.stop()
	overlay.hide()
	set_physics_process(false)
