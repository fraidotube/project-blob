@tool
extends Node3D

const FIRE_WALL_FRAMES := preload(
	"res://IGNIS/engine/godot/sprite_frames/area_fire_wall_loop.tres"
)

@export_group("Fire Wall")

@export_range(1, 64, 1) var wall_cells: int = 5:
	set(value):
		wall_cells = value
		_request_refresh()

@export_range(0.0025, 0.05, 0.0005) var pixel_size: float = 0.012:
	set(value):
		pixel_size = value
		_request_refresh()

@export_range(0.1, 8.0, 0.05) var height_scale: float = 2.25:
	set(value):
		height_scale = value
		_request_refresh()

@export_range(0.1, 8.0, 0.05) var width_scale: float = 1.0:
	set(value):
		width_scale = value
		_request_refresh()

@export_range(-5.0, 5.0, 0.05) var visual_y_offset: float = 0.0:
	set(value):
		visual_y_offset = value
		_request_refresh()

@export_group("Editor Preview")
@export var preview_in_editor: bool = true:
	set(value):
		preview_in_editor = value
		_request_refresh()

@export_group("Collision")

@export_range(0.1, 10.0, 0.1) var collision_height: float = 3.5:
	set(value):
		collision_height = value
		_request_refresh()

@export_range(0.1, 5.0, 0.1) var collision_depth: float = 0.6:
	set(value):
		collision_depth = value
		_request_refresh()

@export_group("Damage Zone")

@export_range(0.1, 10.0, 0.1) var damage_height: float = 3.5:
	set(value):
		damage_height = value
		_request_refresh()

@export_range(0.1, 5.0, 0.1) var damage_depth: float = 1.2:
	set(value):
		damage_depth = value
		_request_refresh()


var _refresh_queued := false


func _ready() -> void:
	_refresh_wall()


func _request_refresh() -> void:
	if not is_inside_tree():
		return

	if _refresh_queued:
		return

	_refresh_queued = true
	call_deferred("_refresh_wall")


func _refresh_wall() -> void:
	_refresh_queued = false

	var flames_root := get_node_or_null("Flames") as Node3D
	var blocker_shape := get_node_or_null(
		"StaticBody3D/CollisionShape3D"
	) as CollisionShape3D
	var damage_shape := get_node_or_null(
		"FireDamageZone/CollisionShape3D"
	) as CollisionShape3D

	if flames_root == null:
		return

	_clear_generated_flames(flames_root)

	if (
		not Engine.is_editor_hint()
		or preview_in_editor
	):
		_build_flames(flames_root)

	if blocker_shape != null and damage_shape != null:
		_update_collision_shapes(
			blocker_shape,
			damage_shape
		)


func _clear_generated_flames(
	flames_root: Node3D
) -> void:
	for child: Node in flames_root.get_children():
		flames_root.remove_child(child)
		child.queue_free()


func _build_flames(
	flames_root: Node3D
) -> void:
	var cell_world_width := (
		256.0
		* pixel_size
		* width_scale
	)

	var total_width := (
		float(wall_cells)
		* cell_world_width
	)

	var first_x := (
		-total_width * 0.5
		+ cell_world_width * 0.5
	)

	var sprites: Array[AnimatedSprite3D] = []

	for i: int in range(wall_cells):
		var sprite := AnimatedSprite3D.new()

		sprite.name = "Flame_%02d" % (i + 1)
		sprite.sprite_frames = FIRE_WALL_FRAMES
		sprite.animation = &"default"
		sprite.frame = 0
		sprite.pixel_size = pixel_size

		sprite.scale = Vector3(
			width_scale,
			height_scale,
			1.0
		)

		sprite.position = Vector3(
			first_x
			+ float(i) * cell_world_width,
			visual_y_offset,
			0.0
		)

		sprite.shaded = false
		sprite.double_sided = true

		flames_root.add_child(sprite)
		sprites.append(sprite)

	for sprite: AnimatedSprite3D in sprites:
		sprite.frame = 0
		sprite.play(&"default")


func _update_collision_shapes(
	blocker_shape: CollisionShape3D,
	damage_shape: CollisionShape3D
) -> void:
	var cell_world_width := (
		256.0
		* pixel_size
		* width_scale
	)

	var total_width := (
		float(wall_cells)
		* cell_world_width
	)

	var blocker_box := BoxShape3D.new()
	blocker_box.size = Vector3(
		total_width,
		collision_height,
		collision_depth
	)

	blocker_shape.shape = blocker_box
	blocker_shape.position.y = (
		collision_height * 0.5
	)

	var damage_box := BoxShape3D.new()
	damage_box.size = Vector3(
		total_width,
		damage_height,
		damage_depth
	)

	damage_shape.shape = damage_box
	damage_shape.position.y = (
		damage_height * 0.5
	)
