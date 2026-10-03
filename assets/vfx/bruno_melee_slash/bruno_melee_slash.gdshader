shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled;

uniform vec4 core_color : source_color = vec4(1.0, 0.95, 0.65, 1.0);
uniform vec4 hot_color : source_color = vec4(1.0, 0.22, 0.02, 1.0);
uniform vec4 edge_color : source_color = vec4(0.55, 0.02, 0.0, 1.0);

uniform float time_scale : hint_range(0.0, 8.0, 0.05) = 3.2;
uniform float dissolve : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float alpha_mul : hint_range(0.0, 2.0, 0.01) = 1.0;
uniform float flame_detail : hint_range(1.0, 20.0, 0.1) = 8.0;
uniform float flame_wobble : hint_range(0.0, 1.0, 0.01) = 0.22;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float noise2d(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);

	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));

	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * noise2d(p);
		p = p * 2.03 + vec2(17.1, 9.2);
		a *= 0.5;
	}
	return v;
}

void fragment() {
	float along = UV.x;
	float across = UV.y;

	float center = 1.0 - abs(across * 2.0 - 1.0);
	float tip_fade = smoothstep(0.0, 0.10, along) * smoothstep(1.0, 0.82, along);

	vec2 n_uv = vec2(
		along * flame_detail - TIME * time_scale,
		across * 3.0 + TIME * time_scale * 0.17
	);

	float n = fbm(n_uv);
	float broken_edge = clamp(center + (n - 0.5) * flame_wobble, 0.0, 1.0);

	float body = smoothstep(0.08 + dissolve * 0.75, 0.48, broken_edge);
	float core = pow(center, 3.6) * body;

	vec3 col = mix(edge_color.rgb, hot_color.rgb, center);
	col = mix(col, core_color.rgb, core);

	float emission = 2.2 + core * 5.5;

	ALBEDO = col;
	EMISSION = col * emission;
	ALPHA = body * tip_fade * alpha_mul;
}
