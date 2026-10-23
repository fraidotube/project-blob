extends Node

static var _sounds: Dictionary = {}
static var _blood_mesh: SphereMesh
static var _blood_fade: Gradient

## Mantiene residenti i suoni del contatto prima del primo impatto utile.
static func prepare_resources() -> void:
	for filename in ["punch1.mp3", "punch2.mp3", "punch3.mp3", "racket_hit.mp3", "racket_hit2.mp3"]:
		var path: String = "res://assets/audio/enemy/" + filename
		if not _sounds.has(path): _sounds[path] = load(path)
	if _blood_mesh != null: return
	_blood_fade = Gradient.new()
	_blood_fade.offsets = PackedFloat32Array([0.0, 0.65, 1.0])
	_blood_fade.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.85), Color(1, 1, 1, 0)])
	_blood_mesh = SphereMesh.new()
	_blood_mesh.radius = 0.015
	_blood_mesh.height = 0.03
	_blood_mesh.radial_segments = 6
	_blood_mesh.rings = 3
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("790e1b")
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_blood_mesh.material = material

class ImpactArc extends Control:
	var age := 0.0
	var point := Vector2.ZERO
	var blocked := false
	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	func _process(delta: float) -> void:
		age += delta
		queue_redraw()
		if age >= 0.32: get_parent().queue_free()
	func _draw() -> void:
		var fade := maxf(0.0, 1.0 - age / 0.32)
		var radius := 48.0 + age * 190.0
		var tint := Color(1.0, 0.2, 0.2, fade * 0.8) if blocked else Color(1, 1, 1, fade * 0.65)
		draw_arc(point, radius, -2.7, -0.35, 28, tint, 4.5, true)
		draw_arc(point, radius * 0.82, 0.3, 2.1, 24, Color(1, 1, 1, fade * 0.6), 3.5, true)

static func impact(weapon: Node3D, target: Object, point: Vector3, blood: bool, racket: bool, strike_direction: Vector3 = Vector3.ZERO) -> void:
	var camera := weapon.get_viewport().get_camera_3d()
	var world := weapon.get_tree().current_scene
	if camera == null or world == null: return
	var layer := CanvasLayer.new()
	layer.layer = 12
	world.add_child(layer)
	var arc := ImpactArc.new()
	arc.point = camera.unproject_position(point)
	var blocked := not blood and target is Node and target.has_method("try_dodge_shot")
	arc.blocked = blocked
	layer.add_child(arc)
	var paths := ["racket_hit.mp3", "racket_hit2.mp3"] if racket else ["punch1.mp3", "punch2.mp3", "punch3.mp3"]
	play_sound(weapon, "res://assets/audio/enemy/" + String(paths.pick_random()), &"Weapons")
	if blocked:
		var model := weapon.get_node("LowWorldViewModel") as Node3D
		var rest := model.position
		var bounce := weapon.create_tween()
		bounce.tween_property(model, "position", rest + Vector3(0, 0.025, 0.1), 0.055)
		bounce.tween_property(model, "position", rest, 0.16)
		play_sound(weapon, "res://assets/audio/enemy/racket_hit2.mp3", &"Weapons", 0.65)
	if not blood: return
	var spray := create_blood_spray()
	var outward := (camera.global_position - point).normalized()
	var travel := strike_direction.normalized() if strike_direction.length_squared() > 0.0001 else -camera.global_basis.z
	# Keep the flow tangent to the visible wound, rather than sending all droplets
	# inside the body. Its sideways/upward component retains the swing direction.
	travel -= outward * minf(travel.dot(outward), 0.0)
	if travel.length_squared() < 0.001: travel = outward
	# Do not amplify tiny lateral motion into a full sideways jet. Preserve the
	# actual swing component while the wound's outward spray stays dominant.
	spray.direction = (travel * 0.65 + outward * 0.75).normalized()
	world.add_child(spray)
	spray.global_position = point + outward * 0.07
	spray.restart()
	spray.emitting = true
	weapon.get_tree().create_timer(1.0, false).timeout.connect(spray.queue_free)

## Stessa risorsa usata dall'impatto e dalla preparazione GPU, senza infliggere danni.
static func create_blood_spray() -> CPUParticles3D:
	prepare_resources()
	var spray := CPUParticles3D.new()
	spray.name = "MeleeBloodSpray"
	spray.amount = 38
	spray.lifetime = 0.65
	spray.one_shot = true
	spray.emitting = false
	spray.explosiveness = 1.0
	spray.spread = 28.0
	spray.initial_velocity_min = 1.8
	spray.initial_velocity_max = 3.8
	spray.gravity = Vector3(0, -5, 0)
	spray.scale_amount_min = 0.4
	spray.scale_amount_max = 1.3
	spray.angle_min = -180.0
	spray.angle_max = 180.0
	spray.color_ramp = _blood_fade
	spray.mesh = _blood_mesh
	return spray

static func play_sound(parent: Node, path: String, bus: StringName = &"SFX", pitch: float = 1.0) -> void:
	var sound := AudioStreamPlayer.new()
	if not _sounds.has(path): _sounds[path] = load(path)
	sound.stream = _sounds[path]
	sound.bus = bus
	sound.volume_db = -3.0
	sound.pitch_scale = pitch
	parent.add_child(sound)
	sound.finished.connect(sound.queue_free)
	sound.play()
