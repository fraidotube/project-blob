@tool
extends Node3D

@export_category("Interaction Outline Builder")

# Trascina qui il nodo logico dell'oggetto interattivo.
# InteractionOutline verrà creato come figlio di questo nodo.
@export var target_parent: Node3D

# Trascina qui SOLO le MeshInstance3D che devono costituire
# la sagoma dell'oggetto (corpo, sportello, viti, display, ecc.).
@export var source_meshes: Array[MeshInstance3D] = []

# Premere ON nell'Inspector per generare/rimpiazzare InteractionOutline.
# Dopo la generazione torna automaticamente OFF.
@export var generate_outline: bool:
	get:
		return false
	set(value):
		if value and Engine.is_editor_hint():
			call_deferred("_generate_outline")


func _generate_outline() -> void:
	if not Engine.is_editor_hint():
		return

	if target_parent == null:
		push_error(
			"InteractionOutlineBuilder: target_parent non assegnato."
		)
		return

	if source_meshes.is_empty():
		push_error(
			"InteractionOutlineBuilder: source_meshes è vuoto."
		)
		return

	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	var appended_any := false

	var target_inverse := (
		target_parent.global_transform.affine_inverse()
	)

	for mesh_instance: MeshInstance3D in source_meshes:
		if mesh_instance == null:
			continue

		if not is_instance_valid(mesh_instance):
			continue

		if mesh_instance.mesh == null:
			continue

		var source_mesh := mesh_instance.mesh

		var local_transform := (
			target_inverse
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
				local_transform
			)

			appended_any = true

	if not appended_any:
		push_error(
			"InteractionOutlineBuilder: nessuna superficie triangolare valida."
		)
		return

	var combined_mesh: ArrayMesh = surface_tool.commit()

	if combined_mesh == null:
		push_error(
			"InteractionOutlineBuilder: impossibile creare la mesh combinata."
		)
		return

	# È lo stesso concetto della Convex Collision:
	# dalle mesh selezionate ricaviamo UN SOLO involucro convesso.
	var convex_shape: ConvexPolygonShape3D = (
		combined_mesh.create_convex_shape(
			true,
			false
		)
	)

	if convex_shape == null:
		push_error(
			"InteractionOutlineBuilder: impossibile creare il convex hull."
		)
		return

	var outline_mesh: ArrayMesh = (
		convex_shape.get_debug_mesh()
	)

	if outline_mesh == null:
		push_error(
			"InteractionOutlineBuilder: impossibile creare la mesh del hull."
		)
		return

	var old_outline := (
		target_parent.get_node_or_null(
			"InteractionOutline"
		)
	)

	if old_outline != null:
		old_outline.free()

	var outline := MeshInstance3D.new()
	outline.name = "InteractionOutline"
	outline.mesh = outline_mesh
	outline.visible = false
	outline.cast_shadow = (
		GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	)

	target_parent.add_child(outline)

	var edited_root := get_tree().edited_scene_root

	if edited_root != null:
		outline.owner = edited_root

	print(
		"InteractionOutline generato per: ",
		target_parent.name,
		" | mesh sorgenti: ",
		source_meshes.size()
	)
