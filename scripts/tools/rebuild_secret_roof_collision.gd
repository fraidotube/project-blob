extends SceneTree
## Rigenera soltanto il collider del tetto col vano segreto dalla mesh GLB corrente.
## Nessuna modifica al GLB, ai transform o alla serializzazione della mappa.
func _initialize() -> void:
	var packed: PackedScene = load("res://assets/models/environment/connesi_building_test2.glb")
	var state := packed.get_state()
	for index in state.get_node_count():
		if state.get_node_path(index) != NodePath("./Tetto Porta Emergenza Assistenza"): continue
		for property in state.get_node_property_count(index):
			if state.get_node_property_name(index,property) != &"mesh": continue
			var mesh := state.get_node_property_value(index,property) as Mesh
			var shape := mesh.create_trimesh_shape()
			DirAccess.make_dir_recursive_absolute("res://resources/collisions")
			var error := ResourceSaver.save(shape,"res://resources/collisions/warehouse_secret_roof.tres")
			print("SECRET_ROOF_COLLISION triangles=",shape.get_faces().size()/3," error=",error)
			quit(error)
			return
	push_error("Mesh Tetto Porta Emergenza Assistenza non trovata nel GLB")
	quit(1)
