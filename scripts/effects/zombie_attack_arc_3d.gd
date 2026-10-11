extends MeshInstance3D

var age := 0.0
var reach := 1.95
var surface: StandardMaterial3D

func _ready() -> void:
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var arc := ImmediateMesh.new()
	surface = StandardMaterial3D.new()
	surface.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	surface.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	surface.cull_mode = BaseMaterial3D.CULL_DISABLED
	surface.albedo_color = Color(1, 0.8, 0.7, 0.65)
	arc.surface_begin(Mesh.PRIMITIVE_TRIANGLES, surface)
	var half_angle := acos(0.35)
	for i in range(40):
		var a := -half_angle + 2.0 * half_angle * i / 40.0
		var b := -half_angle + 2.0 * half_angle * (i + 1) / 40.0
		# A curved upright ribbon across the actual frontal reach at chest height.
		var pa := Vector3(sin(a) * reach, 1.1, cos(a) * reach)
		var pb := Vector3(sin(b) * reach, 1.1, cos(b) * reach)
		for vertex in [pa, pa + Vector3.UP * 0.16, pb + Vector3.UP * 0.16, pa, pb + Vector3.UP * 0.16, pb]:
			arc.surface_add_vertex(vertex)
	arc.surface_end()
	mesh = arc

func _process(delta: float) -> void:
	age += delta
	surface.albedo_color.a = maxf(0.0, (1.0 - age / 0.45) * 0.65)
	if age >= 0.45: queue_free()
