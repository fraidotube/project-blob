shader_type spatial;
render_mode unshaded, cull_front, depth_draw_opaque;

uniform vec4 outline_color : source_color = vec4(0.95, 0.68, 0.28, 1.0);
uniform float outline_width : hint_range(0.0001, 0.02, 0.0001) = 0.0025;

void vertex() {
	vec4 view_position = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vec3 view_normal = normalize(mat3(MODELVIEW_MATRIX) * NORMAL);

	vec4 clip_position = PROJECTION_MATRIX * view_position;
	vec2 projected_normal = (PROJECTION_MATRIX * vec4(view_normal, 0.0)).xy;

	float projected_length = length(projected_normal);

	if (projected_length > 0.00001) {
		projected_normal /= projected_length;
		clip_position.xy += projected_normal * outline_width * clip_position.w;
	}

	POSITION = clip_position;
}

void fragment() {
	ALBEDO = outline_color.rgb;
	ALPHA = outline_color.a;
}
