shader_type canvas_item;
uniform float phase = 0.0;
uniform float intensity = 0.0;
uniform vec4 flame_color : source_color = vec4(1.0, 0.24, 0.025, 1.0);
void fragment() {
	float edge = min(UV.x, 1.0 - UV.x);
	float tongues = 0.5 + 0.5 * sin(UV.x * 43.0 + sin(UV.x * 19.0 + phase * 3.0) * 2.0 - phase * 7.0);
	float height = 0.1 + 0.16 * tongues;
	float bottom = smoothstep(1.0 - height, 1.0, UV.y);
	float sides = (1.0 - smoothstep(0.0, 0.08 + 0.035 * sin(UV.y * 35.0 - phase * 8.0), edge)) * 0.55;
	float flame = max(bottom, sides);
	vec3 hot = mix(flame_color.rgb, vec3(1.0, 0.7, 0.12), flame);
	COLOR = vec4(hot, flame * intensity * 0.65);
}
