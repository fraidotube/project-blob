shader_type spatial;
render_mode blend_add, depth_draw_never, cull_disabled, unshaded, shadows_disabled;

uniform sampler2D noise_tex;

uniform vec4 inner_color : source_color = vec4(1.0, 0.12, 0.01, 1.0);
uniform vec4 outer_color : source_color = vec4(0.42, 0.02, 0.70, 1.0);
uniform vec4 hot_color : source_color = vec4(1.0, 0.88, 0.28, 1.0);

uniform float scroll_speed : hint_range(0.0, 8.0, 0.05) = 3.0;
uniform float noise_scale : hint_range(0.5, 12.0, 0.1) = 4.5;
uniform float fresnel_power : hint_range(0.2, 8.0, 0.1) = 2.2;
uniform float alpha_strength : hint_range(0.0, 2.0, 0.01) = 0.90;
uniform float dissolve : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float emission_strength : hint_range(0.0, 12.0, 0.1) = 5.2;

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

	return mix(
		mix(a, b, f.x),
		mix(c, d, f.x),
		f.y
	);
}

float fbm(vec2 p) {
	float value = 0.0;
	float amp = 0.5;

	for (int i = 0; i < 4; i++) {
		value += amp * noise2d(p);
		p = p * 2.03 + vec2(17.7, 9.4);
		amp *= 0.5;
	}

	return value;
}

void fragment() {
	vec2 flow_uv = UV * noise_scale;
	flow_uv.y -= TIME * scroll_speed;

	float n1 = fbm(flow_uv);
	float n2 = fbm(flow_uv * 1.85 + vec2(TIME * 0.31, -TIME * 0.17));
	float n = mix(n1, n2, 0.45);

	float fresnel = pow(
		1.0 - clamp(
			abs(dot(normalize(NORMAL), normalize(VIEW))),
			0.0,
			1.0
		),
		fresnel_power
	);

	float hot = smoothstep(0.58, 0.90, n);
	float body = smoothstep(0.18, 0.72, n + fresnel * 0.42);

	float alpha = clamp(
		(body + fresnel * 0.45)
		* alpha_strength
		* (1.0 - dissolve),
		0.0,
		1.0
	);

	vec3 color = mix(
		inner_color.rgb,
		outer_color.rgb,
		clamp(fresnel + n * 0.28, 0.0, 1.0)
	);

	color = mix(
		color,
		hot_color.rgb,
		hot
	);

	ALBEDO = color;
	EMISSION = color * emission_strength * (0.55 + hot * 0.85);
	ALPHA = alpha;
}
