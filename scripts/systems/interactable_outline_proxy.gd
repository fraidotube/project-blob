extends RefCounted
class_name InteractableOutlineProxy

const OUTLINE_SHADER := preload(
	"res://assets/shaders/interactable_outline_screen.gdshader"
)

const INTERACTION_LAYER_MASK := 2

var _owner: Node3D
var _proxy: MeshInstance3D
var _material: ShaderMaterial


func setup(
	owner: Node3D,
	color: Color,
	width: float,
	manual_visual_roots: Array[NodePath] = [],
	auto_margin: float = 0.035,
	max_size_multiplier: float = 3.0
) -> void:
	clear()

	_owner = owner

	var source_meshes: Array[MeshInstance3D] = []

	if not manual_visual_roots.is_empty():
		for path: NodePath in manual_visual_roots:
			var root_node := owner.get_node_or_null(path)

			if root_node == null:
				continue

			_collect_meshes_recursive(
				root_node,
				source_meshes
			)
	else:
		source_meshes = _auto_detect_meshes(
			owner,
			auto_margin,
			max_size_multiplier
		)

	if source_meshes.is_empty():
		return

	var combined_mesh := _build_combined_mesh(
		owner,
		source_meshes
	)

	if combined_mesh == null:
		return

	_material = ShaderMaterial.new()
	_material.shader = OUTLINE_SHADER
	_material.set_shader_parameter(
		"outline_color",
		color
	)
	_material.set_shader_parameter(
		"outline_width",
		width
	)

	_proxy = MeshInstance3D.new()
	_proxy.name = "InteractionOutlineProxy"
	_proxy.mesh = combined_mesh
	_proxy.material_override = _material
	_proxy.cast_shadow = (
		GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	)
	_proxy.extra_cull_margin = 1.0
	_proxy.visible = false

	owner.add_child(_proxy)


func set_enabled(enabled: bool) -> void:
	if _proxy == null:
		return

	if not is_instance_valid(_proxy):
		_proxy = null
		return

	_proxy.visible = enabled


func set_color(color: Color) -> void:
	if _material == null:
		return

	_material.set_shader_parameter(
		"outline_color",
		color
	)


func set_width(width: float) -> void:
	if _material == null:
		return

	_material.set_shader_parameter(
		"outline_width",
		width
	)


func clear() -> void:
	if _proxy != null and is_instance_valid(_proxy):
		_proxy.queue_free()

	_proxy = null
	_material = null
	_owner = null


func _auto_detect_meshes(
	owner: Node3D,
	margin: float,
	max_size_multiplier: float
) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []

	var interaction_shape := _find_interaction_shape(
		owner
	)

	if interaction_shape == null:
		# Fallback sicuro: se non troviamo un collider di interazione,
		# proviamo almeno il nodo stesso e i suoi discendenti.
		_collect_meshes_recursive(
			owner,
			result
		)

		return result

	var target_aabb := _collision_shape_world_aabb(
		interaction_shape
	)

	if target_aabb.size == Vector3.ZERO:
		_collect_meshes_recursive(
			owner,
			result
		)

		return result

	target_aabb = target_aabb.grow(margin)

	# Normalmente il visual e il collider stanno nello stesso ramo.
	# Se non è così (es. telecomando/contatore importati), cerchiamo
	# nel parent immediato: il filtro spaziale impedirà di prendere
	# geometrie lontane.
	var search_root: Node = owner

	if owner.get_parent() != null:
		search_root = owner.get_parent()

	var candidates: Array[MeshInstance3D] = []
	_collect_meshes_recursive(
		search_root,
		candidates
	)

	for mesh_instance: MeshInstance3D in candidates:
		if not is_instance_valid(mesh_instance):
			continue

		if mesh_instance.mesh == null:
			continue

		if not mesh_instance.visible:
			continue

		var candidate_aabb := (
			mesh_instance.global_transform
			* mesh_instance.get_aabb()
		)

		if not candidate_aabb.intersects(target_aabb):
			continue

		if _is_candidate_too_large(
			candidate_aabb,
			target_aabb,
			max_size_multiplier
		):
			continue

		if not result.has(mesh_instance):
			result.append(mesh_instance)

	# Se il filtro spaziale è troppo selettivo, non lasciamo
	# l'interagibile senza outline: fallback sul subtree dell'owner.
	if result.is_empty():
		_collect_meshes_recursive(
			owner,
			result
		)

	return result


func _find_interaction_shape(
	node: Node
) -> CollisionShape3D:
	if node is CollisionShape3D:
		var collision_parent := node.get_parent()

		if (
			collision_parent is CollisionObject3D
			and (
				collision_parent.collision_layer
				& INTERACTION_LAYER_MASK
			) != 0
			and not node.disabled
			and node.shape != null
		):
			return node as CollisionShape3D

	for child: Node in node.get_children():
		var found := _find_interaction_shape(
			child
		)

		if found != null:
			return found

	return null


func _collision_shape_world_aabb(
	collision_shape: CollisionShape3D
) -> AABB:
	if collision_shape.shape == null:
		return AABB()

	var debug_mesh := (
		collision_shape.shape.get_debug_mesh()
	)

	if debug_mesh == null:
		return AABB()

	var local_aabb := debug_mesh.get_aabb()

	return (
		collision_shape.global_transform
		* local_aabb
	)


func _is_candidate_too_large(
	candidate: AABB,
	target: AABB,
	multiplier: float
) -> bool:
	var candidate_size := candidate.size.abs()
	var target_size := target.size.abs()

	if target_size.x > 0.001:
		if candidate_size.x > target_size.x * multiplier:
			return true

	if target_size.y > 0.001:
		if candidate_size.y > target_size.y * multiplier:
			return true

	if target_size.z > 0.001:
		if candidate_size.z > target_size.z * multiplier:
			return true

	return false


func _collect_meshes_recursive(
	node: Node,
	output: Array[MeshInstance3D]
) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D

		if (
			mesh_instance.mesh != null
			and not output.has(mesh_instance)
		):
			output.append(mesh_instance)

	for child: Node in node.get_children():
		_collect_meshes_recursive(
			child,
			output
		)


func _build_combined_mesh(
	owner: Node3D,
	source_meshes: Array[MeshInstance3D]
) -> ArrayMesh:
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(
		Mesh.PRIMITIVE_TRIANGLES
	)

	var appended_any := false
	var owner_inverse := (
		owner.global_transform.affine_inverse()
	)

	for mesh_instance: MeshInstance3D in source_meshes:
		if (
			not is_instance_valid(mesh_instance)
			or mesh_instance.mesh == null
		):
			continue

		var source_mesh := mesh_instance.mesh
		var mesh_transform := (
			owner_inverse
			* mesh_instance.global_transform
		)

		for surface_index: int in range(
			source_mesh.get_surface_count()
		):
			if (
				source_mesh.surface_get_primitive_type(
					surface_index
				)
				!= Mesh.PRIMITIVE_TRIANGLES
			):
				continue

			surface_tool.append_from(
				source_mesh,
				surface_index,
				mesh_transform
			)

			appended_any = true

	if not appended_any:
		return null

	return surface_tool.commit()
