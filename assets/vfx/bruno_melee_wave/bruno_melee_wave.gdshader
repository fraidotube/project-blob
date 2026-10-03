shader_type spatial;
render_mode blend_mix, depth_draw_never, unshaded, shadows_disabled, cull_disabled;

uniform sampler2D noise_tex;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

uniform vec4 root_color : source_color = vec4(1.0, 0.72, 0.18, 1.0);
uniform vec4 tip_color : source_color = vec4(1.0, 0.03, 0.005, 1.0);
uniform vec4 specular_color : source_color = vec4(1.0, 0.82, 0.28, 1.0);

uniform float fire_alpha : hint_range(0.0, 1.0, 0.01) = 0.95;
uniform vec2 fire_speed = vec2(0.0, 1.7);
uniform float fire_aperture : hint_range(0.0, 3.0, 0.01) = 0.22;

uniform vec2 wave_noise_speed = vec2(0.55, 0.31);
uniform float wave_noise_scale : hint_range(0.0, 0.2, 0.001) = 0.025;

uniform float edge_power : hint_range(0.1, 6.0, 0.1) = 2.2;
uniform float overall_alpha : hint_range(0.0, 2.0, 0.01) = 1.0;

void fragment() {
	vec2 rev_uv = vec2(UV.x, 1.0 - UV.y);

	vec2 fire_uv = rev_uv + TIME * fire_speed;
	float fire_noise = texture(noise_tex, fire_uv).r;

	float noise = rev_uv.y * (
		((rev_uv.y + fire_aperture) * fire_noise - fire_aperture) * 75.0
	);

	vec4 fire_color = mix(
		tip_color,
		root_color,
		clamp(noise * 0.05, 0.0, 1.0)
	);

	vec2 wave_uv = rev_uv + TIME * wave_noise_speed;
	vec2 wave_shift = (
		(
			texture(noise_tex, wave_uv).xy
			+ texture(noise_tex, wave_uv * 2.0).xy
		) * 0.5
		- vec2(0.5)
	) * wave_noise_scale;

	vec3 refracted = texture(
		screen_texture,
		SCREEN_UV + wave_shift
	).rgb;

	float edge = pow(
		clamp(
			1.0 - abs(
				dot(
					normalize(VIEW),
					normalize(NORMAL + vec3(wave_shift * 18.0, 0.0))
				)
			),
			0.0,
			1.0
		),
		edge_power
	);

	float fire_mask = clamp(noise, 0.0, 1.0);

	ALPHA = fire_mask * fire_alpha * overall_alpha;

	ALBEDO = mix(
		refracted * fire_color.rgb,
		specular_color.rgb,
		edge * 0.45
	);

	EMISSION = fire_color.rgb * fire_mask * 1.8;
}
