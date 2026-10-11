extends Node3D

const CHARACTER := preload("res://scenes/enemies/angelastri.tscn")
const FEEDBACK := preload("res://scripts/effects/melee_feedback.gd")
const ARC := preload("res://scripts/effects/zombie_attack_arc_3d.gd")
const BLOOD := preload("res://assets/vfx/brackeys/brackeys_particle_bundle/predrawn/blood_impact_6x5.png")
var actor: Node3D
var camera: Camera3D
var animation: AnimationPlayer
var weapon: Node3D
var next_effect := 2.0
var effect_index := 0
var label: Label
var automatic := true

class BloodSplash extends Sprite3D:
	var age := 0.0
	func _process(delta: float) -> void:
		age += delta
		frame = mini(29, 3 + int(age * 55.0))
		if age >= 0.5: queue_free()

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	AudioManager.stop_menu_music()
	var environment := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("242931")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color.WHITE
	settings.ambient_light_energy = 0.7
	environment.environment = settings
	add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -30, 0)
	light.light_energy = 1.8
	add_child(light)
	var floor_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(12, 12)
	floor_mesh.mesh = plane
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("515964")
	floor_mesh.material_override = material
	add_child(floor_mesh)
	actor = CHARACTER.instantiate()
	add_child(actor)
	animation = actor.get_node("sgt_Angelastri/AnimationPlayer")
	animation.play(&"mie/idle_new")
	camera = Camera3D.new()
	add_child(camera)
	camera.position = Vector3(3.3, 2.1, 4.5)
	camera.look_at(Vector3(0, 1.1, 0))
	camera.fov = 50
	camera.make_current()
	weapon = Node3D.new()
	add_child(weapon)
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var panel := VBoxContainer.new()
	panel.position = Vector2(24, 24)
	canvas.add_child(panel)
	label = Label.new()
	label.text = "PROVA VFX ANGELASTRI — ciclo automatico"
	panel.add_child(label)
	for entry in [["1 — Sangue attuale (particelle)", 0], ["2 — Sangue: variante animata", 1], ["3 — Arco d'attacco 3D", 2]]:
		var button := Button.new()
		button.text = entry[0]
		var index: int = entry[1]
		button.pressed.connect(func(): show_effect(index))
		panel.add_child(button)
	var toggle := Button.new()
	toggle.text = "Autoplay / pausa"
	toggle.pressed.connect(func(): automatic = not automatic)
	panel.add_child(toggle)

func _process(delta: float) -> void:
	if not automatic: return
	next_effect -= delta
	if next_effect <= 0.0:
		show_effect(effect_index)
		effect_index = (effect_index + 1) % 3
		next_effect = 2.5

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_1, KEY_2, KEY_3]: show_effect(event.keycode - KEY_1)
		elif event.keycode == KEY_SPACE: automatic = not automatic

func show_effect(index: int) -> void:
	var point := actor.global_position + Vector3(0, 1.3, 0.2)
	if index == 0:
		label.text = "Sangue attuale: particelle 3D, stesso effetto della mappa"
		FEEDBACK.impact(weapon, actor, point, true, false)
	elif index == 1:
		label.text = "Variante: schizzo animato + particelle (solo questa prova)"
		FEEDBACK.impact(weapon, actor, point, true, false)
		var splash := BloodSplash.new()
		splash.texture = BLOOD
		splash.hframes = 6
		splash.vframes = 5
		splash.pixel_size = 0.012
		splash.modulate = Color(0.68, 0.28, 0.32, 0.9)
		splash.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		splash.shaded = false
		add_child(splash)
		splash.global_position = point + (camera.global_position - point).normalized() * 0.25
	else:
		label.text = "Arco 3D: confine del colpo, sospeso all'altezza del busto"
		animation.play(&"mie/zombie_attack2", 0.15)
		await get_tree().create_timer(animation.get_animation(&"mie/zombie_attack2").length * 0.45, false).timeout
		var arc := ARC.new()
		add_child(arc)
		arc.global_transform = actor.global_transform
