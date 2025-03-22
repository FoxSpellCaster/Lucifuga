shader_type sky;

uniform bool background_dark = false;

vec3 skybox_dark_srgb(vec3 dir) {
    vec3 rgb = dir * 0.5 + vec3(0.5);
    return vec3(0.05) + 0.20 * rgb;
}

vec3 skybox_light_srgb(vec3 dir) {
    vec3 rgb = dir * 0.5 + vec3(0.5);
    return vec3(0.7) + 0.20 * rgb;
}

float interleaved_gradient_noise(vec2 n) {
    float f = 0.06711056 * n.x + 0.00583715 * n.y;
    return fract(52.9829189 * fract(f));
}

vec3 dither_interleaved(vec3 rgb, float levels, vec4 frag_coord) {
    float noise = interleaved_gradient_noise(frag_coord.xy);
    noise = noise - 0.5;
    return rgb + noise / (levels - 1.0);
}

vec3 linear_from_srgb(vec3 color) {
	return mix(
		pow((color.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)), vec3(2.4)),
		color.rgb * (1.0 / 12.92),
		lessThan(color.rgb, vec3(0.04045))
	);
}

void sky() {
    vec3 rgb;
    if (background_dark) {
        rgb = skybox_dark_srgb(EYEDIR);
    } else {
        rgb = skybox_light_srgb(EYEDIR);
    }

    vec3 rgb_gamma_dithered = dither_interleaved(rgb, 256.0, FRAGCOORD);

    COLOR = linear_from_srgb(rgb_gamma_dithered);
    // COLOR = linear_from_srgb(rgb); // Without dithering
}