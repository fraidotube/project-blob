@tool
extends Node3D

@export_category("Interaction Outline Builder")

@export var target_parent: Node3D
@export var source_meshes: Array[MeshInstance3D] = []

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
		push_error("InteractionOutlineBuilder: target_parent non assegnato.")
		return

	if source_meshes.is_empty():
		push_error("InteractionOutlineBuilder: source_meshes è vuoto.")
		return

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var target_inverse := target_parent.global_transform.affine_inverse()
	var triangle_count := 0

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

		# Centro del singolo componente, espresso nello spazio
		# locale del target. Serve per rendere coerente il winding
		# anche con mesh importate con scale negative/mirror.
		var component_center := (
			local_transform
			* source_mesh.get_aabb().get_center()
		)

		for surface_index: int in range(source_mesh.get_surface_count()):
			if (
				source_mesh.surface_get_primitive_type(surface_index)
				!= Mesh.PRIMITIVE_TRIANGLES
			):
				continue

			var arrays := source_mesh.surface_get_arrays(surface_index)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]

			if vertices.is_empty():
				continue

			if not indices.is_empty():
				var tri_total := indices.size() / 3

				for tri_index: int in range(tri_total):
					var i0 := indices[tri_index * 3]
					var i1 := indices[tri_index * 3 + 1]
					var i2 := indices[tri_index * 3 + 2]

					var p0 := local_transform * vertices[i0]
					var p1 := local_transform * vertices[i1]
					var p2 := local_transform * vertices[i2]

					_add_oriented_triangle(
						st,
						p0,
						p1,
						p2,
						component_center
					)
					triangle_count += 1
			else:
				var tri_total := vertices.size() / 3

				for tri_index: int in range(tri_total):
					var p0 := (
						local_transform
						* vertices[tri_index * 3]
					)
					var p1 := (
						local_transform
						* vertices[tri_index * 3 + 1]
					)
					var p2 := (
						local_transform
						* vertices[tri_index * 3 + 2]
					)

					_add_oriented_triangle(
						st,
						p0,
						p1,
						p2,
						component_center
					)
					triangle_count += 1

	if triangle_count == 0:
		push_error(
			"InteractionOutlineBuilder: nessun triangolo valido trovato."
		)
		return

	# Generiamo normali nuove DOPO aver reso coerente il winding.
	# Lo shader screen-space usa NORMAL per espandere il bordo.
	st.generate_normals()

	var combined_mesh: ArrayMesh = st.commit()

	if combined_mesh == null:
		push_error(
			"InteractionOutlineBuilder: impossibile creare la mesh combinata."
		)
		return

	var old_outline := target_parent.get_node_or_null("InteractionOutline")
	if old_outline != null:
		old_outline.free()

	var outline := MeshInstance3D.new()
	outline.name = "InteractionOutline"
	outline.mesh = combined_mesh
	outline.visible = false
	outline.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	outline.extra_cull_margin = 1.0

	target_parent.add_child(outline)

	var edited_root := get_tree().edited_scene_root
	if edited_root != null:
		outline.owner = edited_root

	print(
		"InteractionOutline FIX03 generato per: ",
		target_parent.name,
		" | mesh sorgenti: ",
		source_meshes.size(),
		" | triangoli: ",
		triangle_count
	)


func _add_oriented_triangle(
	st: SurfaceTool,
	p0: Vector3,
	p1: Vector3,
	p2: Vector3,
	component_center: Vector3
) -> void:
	var face_normal := (p1 - p0).cross(p2 - p0)
	var triangle_center := (p0 + p1 + p2) / 3.0

	# Se la faccia punta verso il centro del componente,
	# invertiamo p1/p2. Questo corregge winding invertito,
	# mirror e scale negative frequenti nei GLB importati.
	if (
		face_normal.length_squared() > 0.0000001
		and face_normal.dot(triangle_center - component_center) < 0.0
	):
		var temp := p1
		p1 = p2
		p2 = temp

	st.set_smooth_group(-1)
	st.add_vertex(p0)
	st.add_vertex(p1)
	st.add_vertex(p2)
