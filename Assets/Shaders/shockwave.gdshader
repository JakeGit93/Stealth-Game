shader_type spatial;
// We're bending what's behind the sphere, not drawing anything of our own,
// so no depth writes and no lighting — just a screen-space refraction.
render_mode blend_mix, depth_draw_never, cull_back, shadows_disabled, unshaded, skip_vertex_transform;

// Godot's screen texture — gives us what's already been rendered behind this object.
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap, repeat_disable;

uniform float distortion_strength : hint_range(0.0, 0.1) = 0.02;
uniform float noise_scale : hint_range(1.0, 40.0) = 8.0;
uniform float scroll_speed : hint_range(0.0, 3.0) = 0.6;   // upward drift, like rising heat
uniform float turbulence_speed : hint_range(0.0, 3.0) = 0.25; // side-to-side flicker

// Fade the effect near the silhouette so the distortion looks like it's
// coming from the "thick" part of the heat column, not a hard sphere edge.
uniform float edge_fade : hint_range(0.0, 1.0) = 0.4;

varying vec3 view_normal;

void vertex() {
	view_normal = normalize(NORMAL);
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	NORMAL = normalize((MODELVIEW_NORMAL_MATRIX * NORMAL));
}

// Small hash + value-noise so we don't need an external noise texture.
float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// Two octaves scrolling at different speeds/directions gives a much more
// convincing "shimmer" than a single layer of noise.
float heat_noise(vec2 uv, float time) {
	float n1 = value_noise(uv * noise_scale + vec2(0.0, -time * scroll_speed));
	float n2 = value_noise(uv * noise_scale * 2.1 + vec2(time * turbulence_speed, -time * scroll_speed * 1.7));
	return (n1 * 0.6 + n2 * 0.4) - 0.5; // center around 0 so it pushes both directions
}

void fragment() {
	float fresnel = pow(1.0 - clamp(dot(normalize(view_normal), vec3(0.0, 0.0, 1.0)), 0.0, 1.0), 2.0);
	float mask = mix(1.0, 1.0 - fresnel, edge_fade);

	vec2 offset;
	offset.x = heat_noise(UV, TIME);
	offset.y = heat_noise(UV + vec2(5.2, 1.3), TIME);

	vec2 distorted_uv = SCREEN_UV + offset * distortion_strength * mask;
	distorted_uv = clamp(distorted_uv, vec2(0.001), vec2(0.999));

	vec3 col = textureLod(screen_texture, distorted_uv, 0.0).rgb;

	ALBEDO = col;
	ALPHA = 1.0;
}