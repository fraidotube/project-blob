/*
	Procedural Magical Waterball Shader by KINOMOTO Yui @arlez80
	Original source: GodotShaders / arlez80
	MIT License

	Project Blob Godot 4 port:
	- SCREEN_TEXTURE replaced by hint_screen_texture uniform
	- color hints updated to source_color
	- added dissolve and emission_boost only for gameplay VFX lifetime/visibility
*/
shader_type spatial;
render_mode depth_draw_opaque, unshaded, shadows_disabled, cull_disabled;

uniform sampler2D noise_tex : repeat_enable, filter_linear;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

uniform vec4 root_color : source_color = vec4(1.0, 0.75, 0.3, 1.0);
uniform vec4 tip_color : source_color = vec4(1.0, 0.03, 0.001, 1.0);
uniform vec4 specular_color : source_color = vec4(0.3, 1.0, 1.0, 1.0);

uniform float fire_alpha : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform vec2 fire_speed = vec2(0.0, 1.0);
uniform float fire_aperture : hint_range(0.0, 3.0, 0.01) = 0.22;

uniform vec2 wave_noise_speed = vec2(0.42, 0.23);
uniform float wave_noise_scale : hint_range(0.0, 0.3, 0.001) = 0.1;

uniform float dissolve : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float emission_boost : hint_range(0.0, 6.0, 0.05) = 1.15;

void fragment()
{
	vec2 rev_uv = vec2(UV.x, 1.0 - UV.y);

	vec2 shifted_uv = (
		rev_uv
		+ TIME * fire_speed
	);

	float fire_noise = texture(
		noise_tex,
		shifted_uv
	).r;

	float noise = (
		rev_uv.y
		* (
			(
				(rev_uv.y + fire_aperture)
				* fire_noise
				- fire_aperture
			)
			* 75.0
		)
	);

	vec4 fire_color = mix(
		tip_color,
		root_color,
		noise * 0.05
	);

	vec2 wave_shift = (
		(
			texture(
				noise_tex,
				shifted_uv
			).xy
			+ texture(
				noise_tex,
				shifted_uv * 2.0
			).xy
		)
		* 0.5
		- vec2(0.5, 0.5)
	) * wave_noise_scale;

	vec2 screen_uv = (
		SCREEN_UV
		+ wave_shift
	);

	float fire_mask = clamp(
		noise,
		0.0,
		1.0
	);

	float fresnel_like = clamp(
		1.0
		- abs(
			dot(
				VERTEX,
				NORMAL
				+ vec3(
					wave_shift * 300.0,
					0.0
				)
			)
		),
		0.0,
		1.0
	);

	ALPHA = (
		fire_mask
		* fire_alpha
		* (1.0 - dissolve)
	);

	ALBEDO = mix(
		texture(
			screen_texture,
			screen_uv
		).rgb
		* fire_color.rgb,
		specular_color.rgb,
		fresnel_like
	);

	// Small Project Blob addition so the effect remains readable
	// in the dark shooting range.
	EMISSION = (
		fire_color.rgb
		* fire_mask
		* emission_boost
		* (1.0 - dissolve)
	);
}
