shader_type canvas_item;
// Режим сканера: экран уходит в зелёный монохром с линиями развёртки, от сканера (правый
// нижний угол) бежит волна; когда она доходит до доступного предмета, тот проявляется
// тёплым живым цветом и мерцает. Все размеры — в пикселях холста 1920×1080.

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
// 0 — обычный экран, 1 — полный режим сканера.
uniform float strength : hint_range(0.0, 1.0) = 0.0;
// Радиус волны от сканера.
uniform float wave = 0.0;
uniform vec2 origin = vec2(1830.0, 990.0);
uniform vec2 canvas_size = vec2(1920.0, 1080.0);
// Прямоугольник предмета (x, y, w, h); w = 0 — проявлять нечего.
uniform vec4 target = vec4(0.0);

const vec3 SCAN_GREEN = vec3(0.16, 0.95, 0.48);
const vec3 WARM = vec3(1.0, 0.82, 0.38);

void fragment() {
	vec2 px = UV * canvas_size;
	vec3 src = texture(screen_texture, SCREEN_UV).rgb;
	float lum = dot(src, vec3(0.299, 0.587, 0.114));
	vec3 scan = SCAN_GREEN * (0.04 + lum * 0.5);
	// Линии развёртки (шаг 4 px) и медленная полоса, ползущая вниз.
	scan *= 0.82 + 0.18 * step(0.5, fract(px.y * 0.25));
	float band = fract(px.y / canvas_size.y - TIME * 0.35);
	scan += SCAN_GREEN * smoothstep(0.96, 1.0, band) * 0.12;
	// Волна от сканера: светлое кольцо.
	float d = distance(px, origin);
	float ring = 1.0 - smoothstep(0.0, 70.0, abs(d - wave));
	scan += SCAN_GREEN * ring * 0.45;
	// Найденный предмет: настоящие цвета, тёплый отлив и пульс.
	if (target.z > 0.0) {
		vec2 lo = target.xy;
		vec2 hi = target.xy + target.zw;
		float inside = step(lo.x, px.x) * step(px.x, hi.x) * step(lo.y, px.y) * step(px.y, hi.y);
		float reach = distance(origin, lo + target.zw * 0.5);
		float shown = smoothstep(reach - 120.0, reach, wave);
		float pulse = 0.85 + 0.15 * sin(TIME * 6.0);
		vec3 hot = mix(src, WARM, 0.25) * (1.25 * pulse);
		scan = mix(scan, hot, inside * shown);
	}
	COLOR = vec4(mix(src, scan, strength), 1.0);
}
