shader_type spatial;
render_mode unshaded, cull_front, blend_add, depth_draw_never;
uniform float active = 0.0;
void vertex() {
	VERTEX += NORMAL * 0.009;
}
void fragment() {
	ALBEDO = vec3(1.0, 0.02, 0.03);
	EMISSION = vec3(1.0, 0.01, 0.02);
	ALPHA = active * 0.2;
}
