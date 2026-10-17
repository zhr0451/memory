class_name ProjectorPicture extends Control
## Заглушка кадра диафильма (солнце, дом, дерево). Заменяется рисунком, когда он будет.


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("e8d9a8"))
	draw_circle(Vector2(size.x * 0.8, size.y * 0.25), 60.0, Color("e0a030"))
	draw_rect(Rect2(0, size.y * 0.72, size.x, size.y * 0.28), Color("7d9a5a"))
	var house := Rect2(size.x * 0.25, size.y * 0.42, 220, 170)
	draw_rect(house, Color("c06a4a"))
	draw_colored_polygon(
		PackedVector2Array([
			house.position + Vector2(-20, 0), house.position + Vector2(house.size.x * 0.5, -90),
			house.position + Vector2(house.size.x + 20, 0)]),
		Color("6b3f33"))
	draw_rect(Rect2(house.position + Vector2(85, 80), Vector2(50, 90)), Color("3d2a24"))
	draw_rect(Rect2(size.x * 0.6, size.y * 0.5, 24, 130), Color("5a3d2a"))
	draw_circle(Vector2(size.x * 0.6 + 12, size.y * 0.46), 62.0, Color("4a7a3c"))
