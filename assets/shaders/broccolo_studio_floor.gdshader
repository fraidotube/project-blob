shader_type spatial;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 cell = abs(fract(world_position.xz + 0.5) - 0.5);
	vec2 width = max(fwidth(world_position.xz), vec2(0.001));
	float line = 1.0 - smoothstep(0.008, 0.008 + max(width.x, width.y), min(cell.x, cell.y));
	ALBEDO = mix(vec3(0.267, 0.286, 0.314), vec3(0.40, 0.42, 0.45), line);
	ROUGHNESS = 0.95;
}
