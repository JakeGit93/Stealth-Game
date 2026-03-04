shader_type spatial;
render_mode specular_schlick_ggx, depth_draw_opaque;

uniform float microfacet_roughness = 0.02;
uniform float glint_strength = 1.0;
uniform float glint_density = 80.0;
uniform vec3 base_color = vec3(0.8,0.7,0.5);

////////////////////////////////////////////////////////////
// Hash utility
////////////////////////////////////////////////////////////
float hash21(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

////////////////////////////////////////////////////////////
// Glint NDF
////////////////////////////////////////////////////////////
float glint_ndf(vec3 N, vec3 H, vec2 uv) {
    float NoH = max(dot(N, H), 0.0);

    vec2 cell = floor(uv * glint_density);
    float rnd = hash21(cell);

    float threshold = mix(0.999, 0.95, microfacet_roughness);
    float spike = step(threshold, rnd);

    float sharpness = 1.0 / max(microfacet_roughness * microfacet_roughness, 1e-5);
    float lobe = pow(NoH, sharpness);

    return spike * lobe;
}

////////////////////////////////////////////////////////////
// Albedo (set in fragment)
////////////////////////////////////////////////////////////
void fragment() {
    ALBEDO = base_color;
}

////////////////////////////////////////////////////////////
// Glints (set in light)
////////////////////////////////////////////////////////////
void light() {
    vec3 N = normalize(NORMAL);
    vec3 V = normalize(VIEW);
    vec3 L = normalize(LIGHT);
    vec3 H = normalize(L + V);

    float NoL = max(dot(N, L), 0.0);
    float NoV = max(dot(N, V), 0.0);

    float visibility = step(0.0, NoL) * step(0.0, NoV);

    float glint = glint_ndf(N, H, UV) * glint_strength * NoL * visibility;
    glint = clamp(glint, 0.0, 1.0);

    SPECULAR_LIGHT += LIGHT_COLOR * glint;
}