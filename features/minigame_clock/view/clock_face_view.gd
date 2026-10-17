class_name ClockFaceView extends Control
## Циферблат со стрелками (рисуется кодом).

const RADIUS := 190.0
const INK := Color("2b2f3a")

var hour: int = 12:
	set(value):
		hour = value
		queue_redraw()
var minute: int = 0:
	set(value):
		minute = value
		queue_redraw()


func _ready() -> void:
	size = Vector2.ONE * RADIUS * 2.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, RADIUS, Color("e8e2d0"))
	draw_arc(center, RADIUS, 0.0, TAU, 64, INK, 8.0, true)
	var font := ThemeDB.fallback_font
	for i in 12:
		var dir := Vector2.from_angle(i * TAU / 12.0 - PI * 0.5)
		draw_line(center + dir * RADIUS * 0.84, center + dir * RADIUS * 0.94, INK, 6.0, true)
		var label := str(12 if i == 0 else i)
		draw_string(font, center + dir * RADIUS * 0.68 + Vector2(-12, 14), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 40, INK)
	var hour_angle := ((hour % 12) + minute / 60.0) * TAU / 12.0 - PI * 0.5
	var minute_angle := minute * TAU / 60.0 - PI * 0.5
	draw_line(center, center + Vector2.from_angle(hour_angle) * RADIUS * 0.5, INK, 12.0, true)
	draw_line(center, center + Vector2.from_angle(minute_angle) * RADIUS * 0.78, Color("b04a3a"), 7.0, true)
	draw_circle(center, 12.0, INK)
