extends Node3D
## Sfera di prova: traiettoria rettilinea con sweep fisico ed esplosione occlusa.
signal detonated
var shooter: CharacterBody3D
var target: CharacterBody3D
var direction := Vector3.FORWARD
var speed := 5.0
var damage := 7
var radius := 1.2
var lifetime := 3.0
var age := 0.0
var blast := false
var tint := Color(0.3, 0.65, 1.0)
## Collegamenti opzionali del laboratorio: null conserva il proiettile mappa.
var visual_scene: PackedScene
var burn_status: Node3D
var energy_visual: Node3D
var direct_hit := false
const BURST = preload("res://scripts/effects/broccolo_lab_burst.gd")

func _ready() -> void:
	add_to_group("broccolo_lab_projectiles")
	if visual_scene != null:
		energy_visual = visual_scene.instantiate()
		add_child(energy_visual)
		energy_visual.aim(direction)
		return
	var visual := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.065
	sphere.height = 0.13
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = tint
	material.emission_enabled = true
	material.emission = tint
	material.emission_energy_multiplier = 3
	sphere.material = material
	visual.mesh = sphere
	add_child(visual)

func exclusions() -> Array[RID]:
	var result: Array[RID] = []
	for actor in get_tree().get_nodes_in_group("broccolo_lab_actors"):
		if is_instance_valid(actor): result.append(actor.get_rid())
	return result

func _physics_process(delta: float) -> void:
	if blast: return
	age += delta
	var motion := direction * speed * delta
	var shape := SphereShape3D.new()
	shape.radius = 0.065
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform.origin = global_position
	query.motion = motion
	query.collision_mask = 1
	query.exclude = exclusions()
	var space := get_world_3d().direct_space_state
	var overlaps := space.intersect_shape(query, 16)
	if not overlaps.is_empty():
		for hit: Dictionary in overlaps:
			if hit.collider == target: direct_hit = true
		detonate()
		return
	var sweep := space.cast_motion(query)
	if sweep[0] < 1.0:
		query.transform.origin = global_position + motion * sweep[1] + motion.normalized() * 0.003
		query.motion = Vector3.ZERO
		for hit: Dictionary in space.intersect_shape(query, 16):
			if hit.collider == target: direct_hit = true
	global_position += motion * sweep[0]
	if sweep[0] < 1.0 or age >= lifetime: detonate()

func detonate() -> void:
	if blast: return
	blast = true
	if is_instance_valid(target) and not target.is_dead and global_position.distance_to(target.global_position) <= radius:
		var query := PhysicsRayQueryParameters3D.create(global_position, target.global_position, 1)
		var excluded := exclusions()
		excluded.append(target.get_rid())
		query.exclude = excluded
		if get_world_3d().direct_space_state.intersect_ray(query).is_empty():
			target.take_damage(damage)
			if direct_hit and not target.is_dead and is_instance_valid(burn_status) and burn_status.target == target:
				burn_status.ignite()
	if is_instance_valid(energy_visual):
		var pose := energy_visual.global_transform
		remove_child(energy_visual)
		get_parent().add_child(energy_visual)
		energy_visual.global_transform = pose
		energy_visual.explode(radius)
	var effect := BURST.new()
	effect.tint = tint
	effect.radius = radius / 1.9
	get_parent().add_child(effect)
	effect.global_position = global_position
	detonated.emit()
	queue_free()

func set_paused(value: bool) -> void:
	set_physics_process(not value)
	if is_instance_valid(energy_visual): energy_visual.set_paused(value)
