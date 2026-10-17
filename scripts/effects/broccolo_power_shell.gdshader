shader_type spatial;
render_mode unshaded, cull_disabled, blend_add, depth_draw_never;
uniform vec4 tint : source_color = vec4(1.0, 0.55, 0.04, 1.0);
uniform float strength = 1.0;
uniform float glow = 4.0;
uniform float phase = 0.0;
void vertex() {
	float wave = sin(UV.x * 50.265 + UV.y * 13.0 - phase * 16.0);
	float tongue = pow(0.5 + 0.5 * sin(UV.x * 43.982 + phase * 4.5), 6.0);
	VERTEX.xz *= 0.85 + wave * 0.12;
	VERTEX.y += sin(UV.y * 3.14159) * (0.12 + 0.55 * tongue);
}
void fragment() {
	float rim = pow(1.0 - abs(dot(normalize(NORMAL), normalize(VIEW))), 0.75);
	float flow = 0.5 + 0.5 * sin(UV.x * 62.83 + UV.y * 24.0 + phase * 18.0);
	float flame = smoothstep(0.02, 0.24, UV.y) * (1.0 - smoothstep(0.72, 1.0, UV.y));
	vec3 color = mix(tint.rgb, vec3(1.0, 0.93, 0.58), flow * 0.35);
	ALBEDO = color;
	EMISSION = color * glow;
	ALPHA = strength * rim * flame * (0.04 + 0.4 * pow(flow, 3.0));
}
