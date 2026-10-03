shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_back, diffuse_lambert, specular_schlick_ggx;

// Project Blob port for Godot 4.7.
// Derived from drcd1/GodotSimpleExplosionVFX (Godot 3.2.3)
// and memo1918/GodotExplosionVFX (Godot 4.2).
//
// The original controls are preserved with meaningful names.
// One additional control is intentionally exposed:
//   smoke_opacity_multiplier
// because the original shader had no global smoke-opacity parameter.

uniform float particle_h_frames = 8.0;
uniform float particle_v_frames = 8.0;
uniform bool particles_anim_loop = false;
uniform float still_frame = -1.0;

uniform sampler2D smoke_sprite : source_color;
uniform sampler2D smoke_color_ramp : source_color;
uniform sampler2D blend_help;
uniform float soft_limit = 0.1;
uniform float blend_scale = 0.1;

uniform float smoke_opacity_multiplier : hint_range(0.0, 4.0, 0.05) = 1.0;

uniform float emission_falloff_multiplier : hint_range(0.0, 2.0, 0.01) = 1.0;
uniform sampler2D emission_falloff : source_color;
uniform sampler2D emission_color_ramp : source_color;

uniform sampler2D normal_plus;
uniform sampler2D normal_minus;

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

void vertex() {
	mat4 mat_world = mat4(
		normalize(INV_VIEW_MATRIX[0]) * length(MODEL_MATRIX[0]),
		normalize(INV_VIEW_MATRIX[1]) * length(MODEL_MATRIX[0]),
		normalize(INV_VIEW_MATRIX[2]) * length(MODEL_MATRIX[2]),
		MODEL_MATRIX[3]
	);

	MODELVIEW_MATRIX = VIEW_MATRIX * mat_world;

	float h_frames = particle_h_frames;
	float v_frames = particle_v_frames;
	float total_frames = h_frames * v_frames;
	float frame = floor(INSTANCE_CUSTOM.y * total_frames);

	if (still_frame > -0.01) {
		frame = floor(still_frame);
	} else if (!particles_anim_loop) {
		frame = clamp(frame, 0.0, total_frames - 1.0);
	} else {
		frame = mod(frame, total_frames);
	}

	UV /= vec2(h_frames, v_frames);
	UV += vec2(
		mod(frame, h_frames) / h_frames,
		floor(frame / h_frames) / v_frames
	);

	// The particle lifetime/animation custom data is used by
	// the original emission-falloff calculation.
	COLOR.rgb = INSTANCE_CUSTOM.xyz;
}

void fragment() {
	vec4 smoke = texture(smoke_sprite, UV);
	float smoke_alpha = smoke.a;

	float max_rg = max(smoke.r, smoke.g);
	float density = max(max_rg, smoke.b);

	vec3 smoke_color = texture(
		smoke_color_ramp,
		vec2(density)
	).rgb;

	float blend_value = texture(
		blend_help,
		vec2(density)
	).r;

	float local_soft_limit = (
		soft_limit
		+ (1.0 - blend_value) * blend_scale
	);

	// Godot 4 uses different NDC Z conventions between Compatibility
	// and Forward+/Mobile. This is the part that the 4.2 fork retained
	// from the Godot 3 shader and that can cause over-fading in Godot 4.
	float scene_depth = texture(
		depth_texture,
		SCREEN_UV
	).r;

	vec3 scene_ndc;
	vec3 particle_ndc;

#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	scene_ndc = vec3(
		SCREEN_UV,
		scene_depth
	) * 2.0 - 1.0;

	particle_ndc = vec3(
		SCREEN_UV,
		FRAGCOORD.z
	) * 2.0 - 1.0;
#else
	scene_ndc = vec3(
		SCREEN_UV * 2.0 - 1.0,
		scene_depth
	);

	particle_ndc = vec3(
		SCREEN_UV * 2.0 - 1.0,
		FRAGCOORD.z
	);
#endif

	vec4 scene_view = (
		INV_PROJECTION_MATRIX
		* vec4(scene_ndc, 1.0)
	);
	scene_view.xyz /= scene_view.w;

	vec4 particle_view = (
		INV_PROJECTION_MATRIX
		* vec4(particle_ndc, 1.0)
	);
	particle_view.xyz /= particle_view.w;

	float depth_difference = abs(
		scene_view.z - particle_view.z
	);

	float safe_soft_limit = max(
		local_soft_limit,
		0.0001
	);

	float soft_factor = clamp(
		depth_difference / safe_soft_limit,
		0.0,
		1.0
	);

	float final_alpha = clamp(
		smoke_alpha
		* soft_factor
		* smoke_opacity_multiplier,
		0.0,
		1.0
	);

	// Original flame falloff path.
	vec2 lifetime_uv = vec2(COLOR.y);

	float falloff = texture(
		emission_falloff,
		lifetime_uv
	).r;

	float emission_lookup = (
		density
		+ emission_falloff_multiplier * falloff
	);

	vec3 flame_color = texture(
		emission_color_ramp,
		vec2(emission_lookup)
	).rgb;

	vec3 n_plus = texture(
		normal_plus,
		UV
	).rgb;

	vec3 n_minus = texture(
		normal_minus,
		UV
	).rgb;

	ALBEDO = smoke_color;
	ALPHA = final_alpha;
	EMISSION = flame_color * 5.0;
	NORMAL = n_plus - n_minus;
}
