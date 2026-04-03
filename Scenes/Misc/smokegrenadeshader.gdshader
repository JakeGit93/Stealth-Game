shader_type spatial;
render_mode unshaded, depth_draw_always, cull_back;

uniform int STEPS = 64;
uniform float STEP_SIZE = 0.05;

uniform float density_multiplier = 2.0;
uniform vec3 smoke_color : source_color = vec3(0.6, 0.6, 0.6);

uniform sampler3D noise_tex;
uniform float time_scale = 0.2;

varying vec3 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float sample_density(vec3 p) {
    vec3 uv = p * 0.5 + vec3(0.0, TIME * time_scale, 0.0);

    float n = texture(noise_tex, uv).r;

    float falloff = 1.0 - length(p);
    falloff = clamp(falloff, 0.0, 1.0);

    return n * falloff * density_multiplier;
}

void fragment() {
    // Camera position (world space)
    vec3 ray_origin = (INV_VIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;

    // Ray direction
    vec3 ray_dir = normalize(world_pos - ray_origin);

    // Start at surface
    vec3 pos = world_pos;

    float transmittance = 1.0;
    vec3 color = vec3(0.0);

    for (int i = 0; i < STEPS; i++) {
        vec3 local = (inverse(MODEL_MATRIX) * vec4(pos, 1.0)).xyz;

        // Only inside volume bounds
        if (any(greaterThan(abs(local), vec3(0.5)))) {
            pos += ray_dir * STEP_SIZE;
            continue;
        }

        float density = sample_density(local);

        float alpha = clamp(density * STEP_SIZE, 0.0, 1.0);

        vec3 contrib = smoke_color * alpha;

        color += transmittance * contrib;
        transmittance *= (1.0 - alpha);

        if (transmittance < 0.01) {
            break;
        }

        pos += ray_dir * STEP_SIZE;
    }

    ALBEDO = color;
    ALPHA = 1.0 - transmittance;
}