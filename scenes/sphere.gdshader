shader_type spatial;
# https://www.youtube.com/watch?v=io2y8RgF39A
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_toon, specular_toon;

uniform vec4 albedo : source_color;
uniform sampler2D color_gradient;
uniform sampler2D fresnel_gradient;

float fresnel(float amout, vec3 normal, vec3 view)
{
	return pow((1.0) - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

void vertex() {
	float basic_fresnel
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
