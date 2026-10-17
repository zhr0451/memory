class_name ReelView extends Control
## Катушка кассеты (заглушка). Вращается кодом; центр вращения посередине.

const RADIUS := 90.0


func _ready() -> void:
	size = Vector2.ONE * RADIUS * 2.0
	pivot_offset = size * 0.5
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, RADIUS, Color("d8d2c4"))
	draw_circle(center, RADIUS * 0.78, Color("2a2622"))
	draw_circle(center, RADIUS * 0.34, Color("d8d2c4"))
	for i in 6:
		var dir := Vector2.from_angle(i * TAU / 6.0)
		draw_line(center + dir * RADIUS * 0.18, center + dir * RADIUS * 0.34, Color("2a2622"), 6.0)
