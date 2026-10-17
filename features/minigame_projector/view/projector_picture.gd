class_name ProjectorPicture extends Control
## Заглушка кадра диафильма (солнце, дом, дерево). Рисуется в координатах 800×450 и масштабируется под size.
## Заменяется рисунком, когда он будет.

const DESIGN_SIZE := Vector2(800, 450)


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, size / DESIGN_SIZE)
	var w := DESIGN_SIZE.x
	var h := DESIGN_SIZE.y
	draw_rect(Rect2(Vector2.ZERO, DESIGN_SIZE), Color("e8d9a8"))
	draw_circle(Vector2(w * 0.8, h * 0.25), 60.0, Color("e0a030"))
	draw_rect(Rect2(0, h * 0.72, w, h * 0.28), Color("7d9a5a"))
	var house := Rect2(w * 0.25, h * 0.42, 220, 170)
	draw_rect(house, Color("c06a4a"))
	draw_colored_polygon(
		PackedVector2Array([
			house.position + Vector2(-20, 0), house.position + Vector2(house.size.x * 0.5, -90),
			house.position + Vector2(house.size.x + 20, 0)]),
		Color("6b3f33"))
	draw_rect(Rect2(house.position + Vector2(85, 80), Vector2(50, 90)), Color("3d2a24"))
	draw_rect(Rect2(w * 0.6, h * 0.5, 24, 130), Color("5a3d2a"))
	draw_circle(Vector2(w * 0.6 + 12, h * 0.46), 62.0, Color("4a7a3c"))
	draw_rect(Rect2(w * 0.05, h * 0.05, 140, 14), Color("b04a3a"))
