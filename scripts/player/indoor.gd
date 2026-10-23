extends Area3D

@export_group("Ambiente interno ed esterno")
## Player audio esterno di cui attenuare il volume quando il giocatore entra nell'area.
@export var exterior_ambience: AudioStreamPlayer

## Volume esterno in dB, prima del volume del bus Ambience.
@export_range(
	-80.0,
	0.0,
	0.5
) var outside_volume_db := -6.0

## Volume dentro l'area in dB; -80 equivale a quasi silenzio.
@export_range(
	-80.0,
	0.0,
	0.5
) var inside_volume_db := -80.0

## Durata della sfumatura tra interno ed esterno (secondi).
@export_range(
	0.1,
	5.0,
	0.1
) var fade_time := 1.2

var _tween: Tween

## Allinea subito il mix al checkpoint, senza attendere body_entered o una sfumatura.
func synchronize_player(player: CharacterBody3D) -> void:
	if exterior_ambience == null or player == null: return
	var capsule := player.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if capsule == null: return
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = capsule.shape
	query.transform = capsule.global_transform
	query.collision_mask = collision_layer
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var inside := false
	for hit: Dictionary in get_world_3d().direct_space_state.intersect_shape(query, 64):
		if hit.collider == self:
			inside = true
			break
	if _tween != null: _tween.kill()
	exterior_ambience.volume_db = inside_volume_db if inside else outside_volume_db


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	_fade_to(
		inside_volume_db
	)


func _on_body_exited(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	_fade_to(
		outside_volume_db
	)


func _fade_to(target_db: float) -> void:
	if exterior_ambience == null:
		return

	if _tween != null:
		_tween.kill()

	_tween = create_tween()

	_tween.tween_property(
		exterior_ambience,
		"volume_db",
		target_db,
		fade_time
	)
