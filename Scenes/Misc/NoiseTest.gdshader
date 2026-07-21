//TODO
//sample noisetex using a mask for highest values
//add to COLOR

shader_type canvas_item;

uniform float threshold : hint_range(0.0, 1.0) = 0.9;

float hash(vec2 p){
    uvec2 q = uvec2(ivec2(p)) * uvec2(1597334677u, 3812015801u);
    uint n = (q.x ^ q.y) * 1597334677u;
    return float(n) * (1.0 / float(0xffffffffu));
}


void fragment() {
	float stepped_time1 = floor(TIME / 0.05);
    vec2 pixel_coord = SCREEN_UV * vec2(1920.0, 1080.0); // scale to actual pixel grid
	float noise_value = hash(floor(pixel_coord) * stepped_time1);
	float mask1 = step(threshold, noise_value);
    
    COLOR = vec4(vec3(noise_value), mask1);
	//COLOR.g = 1.0;
}