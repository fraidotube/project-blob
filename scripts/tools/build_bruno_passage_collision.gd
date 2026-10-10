extends SceneTree

# Offline asset generator. Does not save/rewrite the map or the building GLB.
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var source := load("res://assets/models/environment/connesi_building_test2.glb") as PackedScene
	var building := source.instantiate()
	var wall := building.get_node_or_null("Mura Interne Alte/Parete_013") as MeshInstance3D
	if wall == null or wall.mesh == null:
		push_error("Verified wall mesh missing; no collision generated")
		building.free()
		quit(1)
		return
	var shape := wall.mesh.create_trimesh_shape()
	DirAccess.make_dir_recursive_absolute("res://resources/collision")
	var result := ResourceSaver.save(shape, "res://resources/collision/parete_013_current.tres")
	print("PASSAGE_COLLISION_BUILD result=", result, " bounds=", wall.mesh.get_aabb(), " vertices=", shape.get_faces().size())
	building.free()
	quit(0 if result == OK else 1)
