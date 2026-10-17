extends Node
## Mantiene fino a tre cloni attivi e ne rimpiazza i caduti durante la lotta.

@export_group("Spawn minion")
## Tetto massimo di nemici vivi contemporaneamente.
@export_range(1, 3, 1) var max_alive := 3
## Minimo di copie da creare quando si apre spazio.
@export_range(2, 3, 1) var minimum_batch := 2
## Massimo di copie per ondata, limitato dai posti rimasti.
@export_range(2, 3, 1) var maximum_batch := 3
## Secondi tra una verifica di rimpiazzo e la successiva.
@export_range(0.2, 10.0, 0.1) var spawn_interval := 1.2
## Distanza approssimativa dal player per i nuovi ingressi.
@export_range(2.0, 8.0, 0.1) var spawn_distance := 3.5
## Scena-modello riutilizzata dalle copie e script AI assegnato allo spawn.
@export var minion_scene: PackedScene = preload("res://scenes/enemies/broccolo.tscn")
@export var minion_script: Script = preload("res://scripts/enemies/broccolo_minion.gd")

var encounter: Node
var center := Vector3.ZERO
var timer := 0.0
var rng := RandomNumberGenerator.new()
var active_minions: Array[Node] = []

func configure(owner: Node, spawn_center: Vector3) -> void:
	encounter = owner
	center = spawn_center
	rng.randomize()
	set_process(true)
	_spawn_batch()

func _process(delta: float) -> void:
	active_minions = active_minions.filter(func(enemy: Node) -> bool:return is_instance_valid(enemy) and not enemy.is_queued_for_deletion())
	timer += delta
	if timer < spawn_interval or active_minions.size() >= max_alive:return
	timer = 0.0
	_spawn_batch()

func _spawn_batch() -> void:
	var available := max_alive - active_minions.size()
	if available <= 0:return
	var count := mini(available, rng.randi_range(minimum_batch, maximum_batch))
	for index in count:
		var position := _find_spawn_position(index)
		if not position.is_finite():continue
		var minion := minion_scene.instantiate() as CharacterBody3D
		if minion == null:continue
		minion.set_script(minion_script)
		get_tree().current_scene.add_child(minion)
		minion.global_position = position
		active_minions.append(minion)
	print("BROCCOLO_MINION_SPAWN count=", count, " active=", active_minions.size())

func _find_spawn_position(index: int) -> Vector3:
	var focus: Vector3 = encounter.player.global_position if is_instance_valid(encounter.player) else center
	for attempt in 12:
		var angle := TAU * (float(index) / float(maxi(1, maximum_batch))) + rng.randf_range(-0.7, 0.7) + float(attempt) * 0.41
		var radius := spawn_distance + rng.randf_range(-0.8, 1.2)
		var candidate: Vector3 = focus + Vector3(cos(angle), 0.0, sin(angle)) * radius
		var ray := PhysicsRayQueryParameters3D.create(candidate + Vector3.UP * 2.0, candidate - Vector3.UP * 3.0, 1)
		ray.exclude = [encounter.player.get_rid()]
		var floor_hit: Dictionary = encounter.player.get_world_3d().direct_space_state.intersect_ray(ray)
		if floor_hit.is_empty():continue
		candidate.y = floor_hit.position.y + 0.015
		var capsule := CapsuleShape3D.new()
		capsule.radius = 0.055
		capsule.height = 0.22
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = capsule
		query.transform.origin = candidate + Vector3.UP * 0.11
		query.collision_mask = 1
		query.exclude = [encounter.player.get_rid()]
		if encounter.player.get_world_3d().direct_space_state.intersect_shape(query).is_empty():return candidate
	return Vector3.INF
