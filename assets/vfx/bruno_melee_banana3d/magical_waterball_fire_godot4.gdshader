/*
	Procedural Magical Waterball Shader by KINOMOTO Yui @arlez80
	Original source: GodotShaders / arlez80
	MIT License

	Project Blob Godot 4 adaptation:
	- soft lilac blob surface, gentle light pulse and radial vertex wobble
	- object-space noise avoids the generated banana mesh's UV seam
	- dissolve and emission_boost retain the gameplay controller contract
*/
shader_type spatial;
render_mode depth_draw_opaque, unshaded, shadows_disabled, cull_disabled;

uniform sampler2D noise_tex : repeat_enable, filter_linear;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

uniform vec4 root_color : source_color = vec4(0.84, 0.68, 1.0, 1.0);
uniform vec4 tip_color : source_color = vec4(0.58, 0.32, 0.90, 1.0);
uniform vec4 specular_color : source_color = vec4(0.96, 0.90, 1.0, 1.0);

// Keep the existing material controls; flow now describes a soft blob.
uniform float fire_alpha : hint_range(0.0, 1.0, 0.01) = 0.85;
uniform vec2 fire_speed = vec2(0.12, 0.25);
uniform float fire_aperture : hint_range(0.0, 3.0, 0.01) = 0.22;
uniform vec2 wave_noise_speed = vec2(0.12, 0.08);
uniform float wave_noise_scale : hint_range(0.0, 0.3, 0.001) = 0.025;

group_uniforms Blob;
uniform float pulse_frequency : hint_range(0.0, 4.0, 0.05) = 1.2;
uniform float pulse_intensity : hint_range(0.0, 0.5, 0.01) = 0.18;
uniform float blob_wobble_amplitude : hint_range(0.0, 0.15, 0.005) = 0.06;
uniform float blob_wobble_speed : hint_range(0.0, 3.0, 0.05) = 0.8;
group_uniforms;

uniform float dissolve : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float emission_boost : hint_range(0.0, 6.0, 0.05) = 1.8;

varying vec3 blob_position;
varying vec3 blob_normal;

void vertex() {
	// UV.y follows the arc; UV.x wraps once around each ring.
	// Both layers share the same UVs and phase, preserving their separation.
	blob_position = VERTEX;
	blob_normal = NORMAL;
	float ring_phase = UV.x * TAU;
	float arc_phase = UV.y * TAU;
	float wobble_time = TIME * blob_wobble_speed;
	float tip_weight = pow(max(sin(UV.y * PI), 0.0), 0.7);
	float wobble = (
		0.55 * sin(arc_phase * 1.5 - wobble_time + sin(ring_phase))
		+ 0.30 * sin(ring_phase * 2.0 + arc_phase - wobble_time * 0.73)
		+ 0.15 * sin(arc_phase * 2.5 + ring_phase + wobble_time * 0.51)
	);
	VERTEX += normalize(NORMAL) * blob_wobble_amplitude * tip_weight * wobble;
}

float blob_noise(vec3 position, vec2 flow) {
	// Continuous in local space, including the closing triangles of each ring.
	vec3 weights = abs(normalize(blob_normal));
	weights /= max(weights.x + weights.y + weights.z, 0.0001);
	return (
		texture(noise_tex, position.yz + flow).r * weights.x
		+ texture(noise_tex, position.xz + flow).r * weights.y
		+ texture(noise_tex, position.xy + flow).r * weights.z
	);
}

void fragment() {
	vec3 position = blob_position * (0.65 + fire_aperture * 0.35);
	float primary = blob_noise(position, TIME * fire_speed * 0.25);
	float secondary = blob_noise(
		position * 1.7 + vec3(0.31, 0.47, 0.23),
		-TIME * wave_noise_speed * 0.35
	);
	float field = clamp(primary * 0.65 + secondary * 0.35, 0.0, 1.0);
	float soft_lobe = smoothstep(0.25, 0.75, field);
	float rim = pow(
		1.0 - clamp(abs(dot(normalize(NORMAL), normalize(VIEW))), 0.0, 1.0),
		2.0
	);
	float visibility = 1.0 - clamp(dissolve, 0.0, 1.0);
	float pulse = 1.0 + pulse_intensity * sin(TIME * TAU * pulse_frequency);

	vec3 color = mix(tip_color.rgb, root_color.rgb, 0.35 + soft_lobe * 0.65);
	color = mix(color, specular_color.rgb, rim * 0.35);
	vec2 distortion = (vec2(primary, secondary) - vec2(0.5)) * wave_noise_scale;
	vec3 background = texture(
		screen_texture,
		clamp(SCREEN_UV + distortion, vec2(0.001), vec2(0.999))
	).rgb;

	// Unshaded materials render ALBEDO directly, ignoring EMISSION.
	// HDR albedo makes the pulse and gameplay attenuation visible in both renderers.
	ALBEDO = (
		mix(color, background * color, 0.12)
		* emission_boost * (0.75 + soft_lobe * 0.25) * pulse * visibility
	);
	// Pulse affects light only: the body remains visible between beats.
	ALPHA = clamp(
		fire_alpha * (0.72 + soft_lobe * 0.28) * (0.85 + rim * 0.15) * visibility,
		0.0,
		1.0
	);
}
