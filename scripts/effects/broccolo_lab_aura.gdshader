shader_type spatial;
render_mode unshaded, cull_disabled, blend_add, depth_draw_never, world_vertex_coords;
uniform float active = 0.0;
uniform vec4 tint : source_color = vec4(0.12, 0.5, 1.0, 1.0);
uniform float edge_width = 0.002;
uniform float glow_gain = 1.0;
uniform float pulse_floor = 0.2;
void vertex() {
 VERTEX += NORMAL * edge_width;
}
void fragment() {
 float rim = pow(1.0 - abs(dot(normalize(NORMAL), normalize(VIEW))), 1.6);
 float pulse = mix(pulse_floor, 1.0, 0.5 + 0.5 * sin(TIME * 9.0));
 ALBEDO = tint.rgb;
 EMISSION = tint.rgb * (1.5 + pulse) * glow_gain;
 ALPHA = active * (0.025 + rim * 0.75) * pulse;
}
