extends Node
class_name BossLootDrop

const PICKUP := preload("res://scripts/pickups/inventory_item_pickup.gd")
@export var persistent_id: StringName
@export var loot_id: StringName
@export var boss: Node3D
@export var cinematic_controller: Node
var defeated := false
var loot_position := Vector3.ZERO
var _pending_drop := false

func _ready() -> void:
	if boss == null:
		boss = get_parent() as Node3D
	if boss == null or not boss.has_signal("defeated"):
		push_error("BossLootDrop: boss must expose defeated.")
		return
	boss.connect("defeated", _on_defeated)
	SaveManager.register_object(persistent_id, self)

func _exit_tree() -> void:
	SaveManager.unregister_object(persistent_id, self)

func _on_defeated() -> void:
	if defeated:
		return
	defeated = true
	var origin := boss.global_position + boss.global_basis.x.normalized() * 0.85
	var query := PhysicsRayQueryParameters3D.create(origin + Vector3.UP * 2, origin - Vector3.UP * 5, 1)
	if boss is CollisionObject3D:
		query.exclude = [(boss as CollisionObject3D).get_rid()]
	var excluded: Array[RID] = query.exclude
	for player: Node in get_tree().get_nodes_in_group("player"):
		if player is CollisionObject3D:
			excluded.append((player as CollisionObject3D).get_rid())
	query.exclude = excluded
	var hit: Dictionary = boss.get_world_3d().direct_space_state.intersect_ray(query)
	loot_position = hit.get("position", origin) + Vector3.UP * 0.03
	_pending_drop = true
	_spawn_loot.call_deferred()

func _spawn_loot() -> void:
	_pending_drop = false
	if bool(SaveManager.object_state(loot_id).get("collected", false)):
		return
	if SaveManager.participants.has(loot_id):
		return
	var pickup := PICKUP.new()
	pickup.name = "BrunoKeyDrop"
	pickup.persistent_id = loot_id
	get_tree().current_scene.add_child(pickup)
	pickup.global_position = loot_position

func blocks_saving() -> bool:
	return _pending_drop or (not defeated and int(boss.get("health")) > 0 and bool(boss.get("ai_active")))

func get_persistent_state() -> Dictionary:
	return {"defeated": defeated, "transform": boss.global_transform, "loot_position": loot_position, "has_racket": bool(boss.get("has_racket"))}

func apply_persistent_state(state: Dictionary) -> void:
	defeated = bool(state.get("defeated", false))
	if not defeated:
		return
	if state.get("transform") is Transform3D:
		boss.global_transform = state.transform
	loot_position = state.get("loot_position", boss.global_position)
	boss.call("restore_defeated_state", bool(state.get("has_racket", false)))
	if cinematic_controller != null:
		cinematic_controller.set("intro_started", true)
		if cinematic_controller.has_method("restore_intro_blockers"):
			cinematic_controller.call("restore_intro_blockers")
	_spawn_loot()
