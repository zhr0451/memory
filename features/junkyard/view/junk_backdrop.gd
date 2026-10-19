class_name JunkBackdrop extends Control
## Заглушка фона свалки: холодное небо и тёмные кучи. Если есть bg_junkyard.png — берётся он.

const TEXTURE_PATH := "res://features/junkyard/assets/bg_junkyard.png"

## Держим ссылку: иначе текстура из load() освобождается сразу после _draw и рисуется белым.
var _texture: Texture2D


func _ready() -> void:
	size = Vector2(1920, 1080)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(TEXTURE_PATH):
		_texture = load(TEXTURE_PATH) as Texture2D


func _draw() -> void:
	if _texture:
		draw_texture_rect(_texture, Rect2(Vector2.ZERO, size), false)
		return
	var top := Color("2f3a4c")
	var bottom := Color("536077")
	draw_polygon(
		PackedVector2Array([Vector2(0, 0), Vector2(1920, 0), Vector2(1920, 1080), Vector2(0, 1080)]),
		PackedColorArray([top, top, bottom, bottom]))
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 46:
		var x := rng.randf_range(-100, 1900)
		var y := rng.randf_range(560, 1040)
		var w := rng.randf_range(120, 380)
		var h := rng.randf_range(80, 260)
		var shade := rng.randf_range(0.10, 0.22)
		var color := Color(shade * 0.8, shade, shade * 1.3)
		draw_polygon(
			PackedVector2Array([
				Vector2(x, y + h), Vector2(x + w * 0.2, y), Vector2(x + w * 0.7, y + h * 0.2), Vector2(x + w, y + h)]),
			PackedColorArray([color, color, color, color]))
