shader_type canvas_item;

uniform vec4 blob_color : source_color = vec4(0.08, 0.22, 0.10, 1.0);
uniform vec4 glow_color : source_color = vec4(0.22, 0.48, 0.18, 1.0);

uniform float speed = 0.8;
uniform float horizontal_scale = 4.0;
uniform float wave_scale = 7.0;
uniform float glow_strength = 0.42;
uniform float contrast = 1.25;

void fragment() {
	vec2 uv = UV;

	vec2 blob_uv = uv;
	blob_uv.x *= horizontal_scale;

	float t = TIME * speed;

	float w1 = sin(
		blob_uv.x * wave_scale * 2.0
		+ t * 2.3
		+ sin(blob_uv.y * 13.0 - t * 1.3)
	);

	float w2 = cos(
		blob_uv.x * wave_scale * 3.4
		- t * 1.8
		+ cos(blob_uv.y * 9.0 + t * 1.7)
	);

	float w3 = sin(
		(blob_uv.x + blob_uv.y) * 18.0
		+ t * 2.6
	);

	float blob = (
		w1 * 0.45
		+ w2 * 0.35
		+ w3 * 0.20
	);

	float liquid = blob * 0.5 + 0.5;

	liquid = clamp(
		(liquid - 0.5) * contrast + 0.5,
		0.0,
		1.0
	);

	float highlight = smoothstep(
		0.55,
		0.92,
		liquid
	);

	float shadow = 1.0 - smoothstep(
		0.08,
		0.45,
		liquid
	);

	vec3 color = blob_color.rgb;

	color = mix(
		color,
		glow_color.rgb,
		highlight * glow_strength
	);

	color *= 1.0 - shadow * 0.35;

	float pulse = 0.94 + 0.06 * sin(
		t * 2.4
		+ blob_uv.x * 3.0
	);

	color *= pulse;

	COLOR = vec4(
		color,
		COLOR.a * blob_color.a
	);
}