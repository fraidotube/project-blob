shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform vec4 fog_color_a : source_color = vec4(0.34, 0.05, 0.56, 1.0);
uniform vec4 fog_color_b : source_color = vec4(0.04, 0.28, 0.45, 1.0);

uniform float speed = 0.020;
uniform float scale = 3.6;
uniform float density = 0.46;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);

	// interpolazione più morbida
	f = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

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

mat2 rot(float a) {
	float s = sin(a);
	float c = cos(a);
	return mat2(vec2(c, -s), vec2(s, c));
}

float fbm(vec2 p) {
	float value = 0.0;
	float amplitude = 0.5;

	p = rot(0.37) * p;

	for (int i = 0; i < 6; i++) {
		value += amplitude * value_noise(p);
		p = rot(0.61) * (p * 2.03 + vec2(7.31, 11.17));
		amplitude *= 0.52;
	}

	return value;
}

void fragment() {
	vec2 uv = UV;
	vec2 centered = uv - vec2(0.5);

	// Domain warp: rompe completamente la griglia rettangolare
	float t = TIME * speed;

	vec2 warp_pos = centered * 2.2;
	float warp_x = fbm(warp_pos + vec2(t * 0.75, 3.2));
	float warp_y = fbm(warp_pos + vec2(-4.7, t * 0.55));

	vec2 warp = vec2(
		warp_x - 0.5,
		warp_y - 0.5
	) * 1.35;

	vec2 p1 = (
		centered * scale
		+ warp
		+ vec2(t, t * 0.18)
	);

	vec2 p2 = (
		centered * (scale * 1.55)
		- warp * 0.45
		+ vec2(-t * 0.58, t * 0.11)
	);

	float a = fbm(p1);
	float b = fbm(p2);

	float fog = mix(a, b, 0.38);

	// niente soglia dura: transizione molto più naturale
	fog = smoothstep(0.24, 0.78, fog);

	// concentriamo la foschia soprattutto in basso e ai lati,
	// ma senza maschere dai bordi netti
	float bottom = smoothstep(0.05, 1.0, uv.y);
	float side = smoothstep(
		0.10,
		1.0,
		abs(uv.x - 0.5) * 2.0
	);

	float spatial_mask = mix(
		0.52,
		1.0,
		max(bottom * 0.82, side * 0.52)
	);

	float alpha = fog * density * spatial_mask;

	float tint_mix = clamp(
		0.30 + b * 0.62 + uv.x * 0.12,
		0.0,
		1.0
	);

	vec3 fog_rgb = mix(
		fog_color_a.rgb,
		fog_color_b.rgb,
		tint_mix
	);

	COLOR = vec4(
		fog_rgb,
		clamp(alpha, 0.0, 0.58)
	);
}
