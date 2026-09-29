shader_type canvas_item;
render_mode unshaded, blend_add;

// Project Blob - Menu Atmosphere V4.2.1
// Effetto volutamente evidente. La nebbia approvata resta separata.

uniform float intensity = 1.35;

uniform vec2 meteor_center = vec2(0.355, 0.895);
uniform vec4 magenta : source_color = vec4(1.0, 0.015, 0.82, 1.0);
uniform vec4 violet : source_color = vec4(0.48, 0.06, 0.92, 1.0);
uniform vec4 cyan : source_color = vec4(0.015, 0.56, 1.0, 1.0);


float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}


float noise21(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);

	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));

	return mix(
		mix(a, b, f.x),
		mix(c, d, f.x),
		f.y
	);
}


float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;

	for (int i = 0; i < 4; i++) {
		v += noise21(p) * a;
		p = p * 2.01 + vec2(6.3, 2.7);
		a *= 0.5;
	}

	return v;
}


float blob(
	vec2 uv,
	vec2 center,
	float radius
) {
	return 1.0 - smoothstep(
		radius * 0.20,
		radius,
		distance(uv, center)
	);
}


float beam(
	vec2 uv,
	vec2 origin,
	float angle,
	float width,
	float length
) {
	vec2 p = uv - origin;

	float c = cos(angle);
	float s = sin(angle);

	vec2 r = vec2(
		c * p.x - s * p.y,
		s * p.x + c * p.y
	);

	float side = exp(
		-abs(r.x) / max(width, 0.001)
	);

	float forward = smoothstep(
		0.0,
		length * 0.16,
		-r.y
	) * (
		1.0 - smoothstep(
			length * 0.65,
			length,
			-r.y
		)
	);

	return side * forward;
}


void fragment() {
	vec2 uv = UV;
	float t = TIME;

	// --------------------------------------------------------
	// CRATERE: pulsazione evidente
	// --------------------------------------------------------

	float pulse = (
		0.82
		+ 0.18 * sin(t * 1.15)
	);

	float core = blob(
		uv,
		meteor_center,
		0.115
	);

	float halo = blob(
		uv,
		meteor_center,
		0.34
	);

	float meteor = (
		core * 1.10
		+ halo * 0.42
	) * pulse;

	// Piccolo anello energetico che respira.
	float d = distance(
		uv,
		meteor_center
	);

	float ring_radius = (
		0.110
		+ sin(t * 0.90) * 0.010
	);

	float ring = exp(
		-abs(d - ring_radius) * 58.0
	) * 0.34;


	// --------------------------------------------------------
	// RAGGI DI ENERGIA DAL METEORITE
	// --------------------------------------------------------

	float rays = 0.0;

	rays += beam(
		uv,
		meteor_center + vec2(0.00, 0.01),
		-0.32 + sin(t * 0.11) * 0.08,
		0.030,
		0.62
	);

	rays += beam(
		uv,
		meteor_center + vec2(0.01, 0.00),
		0.28 + cos(t * 0.09) * 0.07,
		0.025,
		0.54
	);

	rays *= (
		0.10
		+ 0.05 * sin(t * 0.70)
	);


	// --------------------------------------------------------
	// NUBI COLORATE IN MOVIMENTO
	// --------------------------------------------------------

	vec2 n1_uv = (
		uv * 2.10
		+ vec2(
			t * 0.018,
			sin(t * 0.045) * 0.14
		)
	);

	vec2 n2_uv = (
		uv * 2.45
		+ vec2(
			-t * 0.014,
			cos(t * 0.038) * 0.12
		)
	);

	float n1 = smoothstep(
		0.47,
		0.74,
		fbm(n1_uv)
	);

	float n2 = smoothstep(
		0.48,
		0.76,
		fbm(n2_uv + vec2(9.4, 3.2))
	);

	float low_mask = smoothstep(
		0.20,
		0.96,
		uv.y
	);

	float left_mask = smoothstep(
		0.72,
		0.05,
		uv.x
	);

	float right_mask = smoothstep(
		0.28,
		0.95,
		uv.x
	);

	float cyan_cloud = (
		n1 * right_mask * low_mask * 0.19
	);

	float violet_cloud = (
		n2 * left_mask * low_mask * 0.17
	);


	// --------------------------------------------------------
	// PARTICELLE: più grandi e leggibili
	// --------------------------------------------------------

	vec2 p_uv = (
		uv * vec2(38.0, 22.0)
		+ vec2(
			t * 0.14,
			-t * 0.085
		)
	);

	vec2 cell = floor(p_uv);
	vec2 local = fract(p_uv) - 0.5;

	float rnd = hash21(cell);
	float particle = 0.0;

	if (rnd > 0.875) {
		float twinkle = (
			0.68
			+ 0.32 * sin(
				t * (
					1.2
					+ rnd * 2.7
				)
				+ rnd * 19.0
			)
		);

		float size = mix(
			0.045,
			0.095,
			rnd
		);

		particle = smoothstep(
			size,
			0.0,
			length(local)
		) * twinkle;
	}

	float near_meteor = (
		0.34
		+ halo * 0.95
	);

	float particles = (
		particle
		* near_meteor
		* 0.52
	);


	// --------------------------------------------------------
	// LENTO SWEEP CIANO VISIBILE
	// --------------------------------------------------------

	float sweep_x = (
		fract(t * 0.020) * 1.55
		- 0.28
	);

	float sweep = exp(
		-abs(uv.x - sweep_x) * 10.0
	);

	sweep *= (
		1.0 - smoothstep(
			0.20,
			0.95,
			uv.y
		)
	);

	sweep *= 0.11;


	// --------------------------------------------------------
	// BREATHING DEI LATI
	// --------------------------------------------------------

	float side_cyan = blob(
		uv,
		vec2(
			0.92 + sin(t * 0.05) * 0.025,
			0.52
		),
		0.46
	);

	side_cyan *= (
		0.10
		+ 0.06 * (
			0.5
			+ 0.5 * sin(t * 0.34)
		)
	);

	float side_magenta = blob(
		uv,
		vec2(
			0.08 + cos(t * 0.045) * 0.025,
			0.60
		),
		0.43
	);

	side_magenta *= (
		0.08
		+ 0.05 * (
			0.5
			+ 0.5 * sin(t * 0.40 + 2.2)
		)
	);


	// --------------------------------------------------------
	// RARO IMPULSO DEL METEORITE
	// --------------------------------------------------------

	float spike_wave = max(
		0.0,
		sin(t * 0.27 + 0.4)
	);

	float spike = pow(
		spike_wave,
		28.0
	);

	float spike_glow = (
		halo
		* spike
		* 0.42
	);


	// --------------------------------------------------------
	// COMPOSIZIONE
	// --------------------------------------------------------

	vec3 color = vec3(0.0);

	color += (
		magenta.rgb
		* meteor
		* 0.56
	);

	color += (
		violet.rgb
		* ring
	);

	color += (
		magenta.rgb
		* rays
	);

	color += (
		cyan.rgb
		* cyan_cloud
	);

	color += (
		violet.rgb
		* violet_cloud
	);

	color += (
		cyan.rgb
		* sweep
	);

	color += (
		cyan.rgb
		* side_cyan
	);

	color += (
		magenta.rgb
		* side_magenta
	);

	color += (
		mix(
			magenta.rgb,
			cyan.rgb,
			rnd
		)
		* particles
	);

	color += (
		magenta.rgb
		* spike_glow
	);

	float alpha = (
		meteor * 0.30
		+ ring * 0.22
		+ rays * 0.25
		+ cyan_cloud * 0.25
		+ violet_cloud * 0.23
		+ sweep * 0.28
		+ side_cyan * 0.23
		+ side_magenta * 0.22
		+ particles * 0.42
		+ spike_glow * 0.30
	);

	COLOR = vec4(
		color * intensity,
		clamp(
			alpha * intensity,
			0.0,
			0.68
		)
	);
}
