shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 ray_dir = normalize(world_pos - CAMERA_POSITION_WORLD);
	ALBEDO = vec3(ray_dir * 0.5 + 0.5);
}
