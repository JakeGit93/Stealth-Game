shader_type canvas_item;

uniform sampler2D noise_texture;

void fragment() {
    vec4 tex = texture(NORMAL_TEXTURE, UV);
	tex.rgb = vec3(0.1,0.0,1.0);
	//tex.g = 1.0;
    COLOR = tex;
}