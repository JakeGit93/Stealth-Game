shader_type spatial;
render_mode unshaded, cull_front, depth_draw_never;

uniform vec3 sun_direction = vec3(1.0, 0.1, 0.0); // normalised, set from GDScript

void fragment() {
    float elevation = sun_direction.y; // 1.0 = noon, 0.0 = horizon, -1.0 = midnight

    vec3 noon_color    = vec3(0.1, 0.1, 0.1);
    vec3 horizon_color = vec3(0.1, 0.1, 0.1);
    vec3 night_color   = vec3(0.01, 0.01, 0.06);

    vec3 sky_color;
    if (elevation > 0.0) {
        sky_color = mix(horizon_color, noon_color, elevation);
    } else {
        sky_color = mix(night_color, horizon_color, 1.0 + elevation);
    }

    ALBEDO = sky_color;
}
