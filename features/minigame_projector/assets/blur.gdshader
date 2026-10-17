shader_type canvas_item;
// Размытие того, что нарисовано под узлом. blur = 0 — резко.

uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
uniform float blur : hint_range(0.0, 8.0) = 0.0;

void fragment() {
	vec2 step_px = SCREEN_PIXEL_SIZE * blur * 1.2;
	vec3 sum = vec3(0.0);
	for (int x = -3; x <= 3; x++) {
		for (int y = -3; y <= 3; y++) {
			sum += texture(screen_tex, SCREEN_UV + vec2(float(x), float(y)) * step_px).rgb;
		}
	}
	COLOR = vec4(sum / 49.0, 1.0);
}
