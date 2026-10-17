class_name JunkNoteView extends Control
## Смятая записка, спрятанная среди мусора. Нарочно без блеска: её надо заметить самому.

signal pressed

const SIZE := Vector2(96, 72)


func _ready() -> void:
	custom_minimum_size = SIZE
	size = SIZE
	pivot_offset = SIZE * 0.5
	rotation = deg_to_rad(14.0)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _gui_input(event: InputEvent) -> void:
	var button := event as InputEventMouseButton
	if button != null and button.button_index == MOUSE_BUTTON_LEFT and button.pressed:
		pressed.emit()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("8a8d99"))
	draw_rect(Rect2(Vector2.ZERO, size), Color("5d606c"), false, 2.0)
	for i in 4:
		draw_line(Vector2(10, 16 + i * 14), Vector2(size.x - 14 - i * 6, 16 + i * 14), Color("5d606c"), 2.0)


## Куча мусора поверх записки: прикрывает её часть.
class Cover extends Control:
	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(240, 160)

	func _draw() -> void:
		var color := Color("1b2330")
		draw_colored_polygon(PackedVector2Array([
			Vector2(0, 160), Vector2(40, 40), Vector2(130, 70), Vector2(200, 0), Vector2(240, 160)]), color)
