class_name Knob extends Control
## Ручка, которую крутят мышью. Угол в градусах: 0 — вправо, по часовой стрелке.
## Вместо рисунка можно задать texture (центр вращения посередине).

signal angle_changed(degrees: float)

@export var texture: Texture2D

var angle: float = 0.0:
	set(value):
		angle = fposmod(value, 360.0)
		queue_redraw()

var _dragging: bool = false


func _ready() -> void:
	custom_minimum_size = Vector2(160, 160)
	size = custom_minimum_size
	mouse_default_cursor_shape = Control.CURSOR_DRAG


func _gui_input(event: InputEvent) -> void:
	var button := event as InputEventMouseButton
	if button != null and button.button_index == MOUSE_BUTTON_LEFT and button.pressed:
		if _local_to_center(button.position).length() <= size.x * 0.55:
			_dragging = true
			_update_from_mouse()


func _input(event: InputEvent) -> void:
	if not _dragging:
		return
	if event is InputEventMouseMotion:
		_update_from_mouse()
	elif event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		if button.button_index == MOUSE_BUTTON_LEFT and not button.pressed:
			_dragging = false


func _update_from_mouse() -> void:
	var offset := _local_to_center(get_local_mouse_position())
	if offset.length() < 4.0:
		return
	angle = rad_to_deg(offset.angle())
	angle_changed.emit(angle)


func _local_to_center(local: Vector2) -> Vector2:
	return local - size * 0.5


func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.5
	if texture != null:
		draw_set_transform(center, deg_to_rad(angle))
		draw_texture(texture, -texture.get_size() * 0.5)
		return
	draw_circle(center, radius, Color("5b6577"))
	draw_circle(center, radius * 0.86, Color("8a94a6"))
	var tip := center + Vector2.from_angle(deg_to_rad(angle)) * radius * 0.8
	draw_line(center, tip, Color("232831"), 10.0, true)
	draw_circle(tip, 12.0, Color("e6c86a"))
	draw_circle(center, radius * 0.18, Color("3a4252"))
