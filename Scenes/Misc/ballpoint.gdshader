shader_type canvas_item;

uniform vec4 ink_color : source_color = vec4(0.1, 0.2, 0.6, 1.0);
uniform vec4 paper_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float shade_levels : hint_range(2.0, 16.0) = 5.0;
uniform bool posterize = true;

float luminance(vec3 c) {
    return dot(c, vec3(0.299, 0.587, 0.114));
}

void fragment() {
    vec4 scene = texture(TEXTURE, UV);
    float lum = luminance(scene.rgb);

    // Darker pixels -> more ink (invert so dark = high ink amount)
    float ink_amount = 1.0 - lum;

    if (posterize) {
        ink_amount = floor(ink_amount * shade_levels) / shade_levels;
    }

    vec3 final_color = mix(paper_color.rgb, ink_color.rgb, ink_amount);
    COLOR = vec4(final_color, scene.a);
}