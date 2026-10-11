extends RefCounted

const KEY := preload("res://assets/models/edificio/key_with_tag/scene.gltf")
const RACKET := preload("res://scenes/pickups/bruno_racket_pickup.tscn")

static func box(parent: Node3D, dimensions: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var visual := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	visual.mesh = mesh
	visual.position = at
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.7
	visual.material_override = material
	parent.add_child(visual)
	return visual

static func wire(parent: Node3D, points: PackedVector3Array, color: Color, radius: float = 0.004) -> void:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var frames: Array[Basis] = []
	for i in points.size():
		var tangent := (points[mini(i + 1, points.size() - 1)] - points[maxi(i - 1, 0)]).normalized()
		var side := tangent.cross(Vector3.UP)
		if side.length_squared() < 0.01: side = tangent.cross(Vector3.RIGHT)
		side = side.normalized()
		frames.append(Basis(side, tangent.cross(side).normalized(), tangent))
	for i in points.size() - 1:
		for j in 10:
			var angle := TAU * j / 10
			var next := TAU * (j + 1) / 10
			var a := frames[i] * Vector3(cos(angle), sin(angle), 0)
			var b := frames[i] * Vector3(cos(next), sin(next), 0)
			var c := frames[i + 1] * Vector3(cos(angle), sin(angle), 0)
			var d := frames[i + 1] * Vector3(cos(next), sin(next), 0)
			for pair in [[points[i], a], [points[i + 1], c], [points[i + 1], d], [points[i], a], [points[i + 1], d], [points[i], b]]:
				tool.set_normal(pair[1])
				tool.add_vertex(pair[0] + pair[1] * radius)
	var mesh := MeshInstance3D.new()
	mesh.mesh = tool.commit()
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	mesh.material_override = material
	parent.add_child(mesh)

static func make(id: String, puzzle: Node = null) -> Node3D:
	var visual := Node3D.new()
	match id:
		"bruno_key": visual.add_child(KEY.instantiate())
		"bruno_racket":
			var racket := RACKET.instantiate() as Node3D
			visual.add_child(racket)
			racket.remove_from_group("bruno_racket_target")
			if puzzle != null: puzzle._decorate_racket(racket)
		"network_cable":
			var points := PackedVector3Array()
			for i in 101:
				var angle := TAU * 1.45 * i / 100.0
				points.append(Vector3(cos(angle) * 0.16, sin(angle * 0.5) * 0.015, sin(angle) * 0.12))
			wire(visual, points, Color("d4b850"))
			for endpoint in [points[0], points[-1]]:
				box(visual, Vector3(0.025, 0.018, 0.04), endpoint, Color("c7d8e2"))
		"regia_charger":
			box(visual, Vector3(0.12, 0.035, 0.065), Vector3.ZERO, Color("171a20"))
			for side in [-1.0, 1.0]:
				var points := PackedVector3Array()
				for i in 41:
					var t := float(i) / 40
					points.append(Vector3(side * (0.06 + t * 0.12), sin(t * PI) * 0.01, sin(t * TAU) * 0.045))
				wire(visual, points, Color("202025"), 0.003)
				box(visual, Vector3(0.014, 0.012, 0.025), points[-1], Color("2e3138"))
		"regia_laptop":
			if puzzle != null:
				copy_meshes(puzzle.laptop_visual, visual, Transform3D.IDENTITY)
	return visual

static func copy_meshes(source: Node3D, target: Node3D, parent_pose: Transform3D) -> void:
	var pose := parent_pose * source.transform
	if source is MeshInstance3D:
		var mesh := MeshInstance3D.new()
		mesh.mesh = source.mesh
		mesh.material_override = source.material_override
		mesh.transform = pose
		target.add_child(mesh)
	for child in source.get_children():
		if child is Node3D and child.get_script() == null:
			copy_meshes(child, target, pose)

static func bounds(source: Node3D, frame: Transform3D = Transform3D.IDENTITY) -> AABB:
	var result := AABB()
	var first := true
	for mesh: MeshInstance3D in source.find_children("*", "MeshInstance3D", true, false):
		var box := frame.affine_inverse() * mesh.global_transform * mesh.get_aabb()
		result = box if first else result.merge(box)
		first = false
	return result
