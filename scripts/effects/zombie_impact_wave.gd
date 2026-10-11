extends MeshInstance3D

var age := 0.0
var reach := 1.95
var surface: StandardMaterial3D

func _ready() -> void:
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var ring := ImmediateMesh.new()
	surface = StandardMaterial3D.new()
	surface.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	surface.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	surface.cull_mode = BaseMaterial3D.CULL_DISABLED
	surface.albedo_color = Color(1.0, 0.65, 0.55, 0.55)
	ring.surface_begin(Mesh.PRIMITIVE_TRIANGLES, surface)
	# Same frontal cone as the attack check (dot > 0.35), only 64 triangles.
	var half_angle := acos(0.35)
	for i in range(32):
		var a := -half_angle + 2.0 * half_angle * i / 32.0
		var b := -half_angle + 2.0 * half_angle * (i + 1) / 32.0
		var va := Vector3(sin(a), 0, cos(a))
		var vb := Vector3(sin(b), 0, cos(b))
		for vertex in [va * 0.86, va, vb, va * 0.86, vb, vb * 0.86]: ring.surface_add_vertex(vertex)
	for angle in [-half_angle, half_angle]:
		var direction := Vector3(sin(angle), 0, cos(angle))
		var edge := Vector3(cos(angle), 0, -sin(angle)) * 0.012
		for vertex in [-edge, edge, direction + edge, -edge, direction + edge, direction - edge]:
			ring.surface_add_vertex(vertex)
	ring.surface_end()
	mesh = ring
	scale = Vector3(reach, 1, reach)

func _process(delta: float) -> void:
	age += delta
	surface.albedo_color.a = maxf(0, (1.0 - age / 0.35) * 0.55)
	if age >= 0.35: queue_free()
