class_name WaveScreen extends Control
## Экран приёмника: чистая синусоида проступает из шума по мере захвата станции.

const POINTS := 120
const LINE_COLOR := Color("9fd08a")

var strength: float = 0.0
var cycles: float = 3.0

var _phase: float = 0.0


func _process(delta: float) -> void:
	_phase += delta * 4.0
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("11160f"))
	var mid := size.y * 0.5
	draw_line(Vector2(0, mid), Vector2(size.x, mid), Color("26301f"), 2.0)
	var points := PackedVector2Array()
	for i in POINTS + 1:
		var t := float(i) / POINTS
		var clean := sin(t * TAU * cycles + _phase) * strength
		var noise := randf_range(-1.0, 1.0) * (1.0 - strength)
		points.append(Vector2(t * size.x, mid - clampf(clean + noise, -1.0, 1.0) * (mid - 8.0)))
	draw_polyline(points, LINE_COLOR, 3.0, true)
