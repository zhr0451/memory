class_name PictureNoteView extends Control
## Рисунок с холодильника: бабушкин номер картинками, сверху вниз — радуга, кошка, велосипед, ладошка, бублик, торт с одной свечкой.
## Ни одной цифры: рисунок не надо переводить. Арт: mg_phone_note.png.

enum Picture { RAINBOW, CAT, BIKE, HAND, BAGEL, CANDLE }

const ORDER: Array[Picture] = [Picture.RAINBOW, Picture.CAT, Picture.BIKE, Picture.HAND, Picture.BAGEL, Picture.CANDLE]
const SIZE := Vector2(260, 640)
const CELL := 98.0
const PICTURE_SCALE := 0.8
const PATH := "res://features/minigame_phone/assets/mg_phone_note.png"
const INK := Color("4a3a2c")

var _texture: Texture2D


func _ready() -> void:
	size = SIZE
	custom_minimum_size = SIZE
	pivot_offset = SIZE * 0.5
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_texture = load(PATH) if ResourceLoader.exists(PATH) else null


func _draw() -> void:
	if _texture != null:
		draw_texture_rect(_texture, Rect2(Vector2.ZERO, size), false)
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color("efe6cf"))
	draw_circle(Vector2(size.x * 0.5, 10), 14.0, Color("c0503a"))
	for i in ORDER.size():
		draw_set_transform(Vector2(size.x * 0.5, 40 + CELL * 0.5 + i * CELL), 0.0, Vector2.ONE * PICTURE_SCALE)
		var c := Vector2.ZERO
		match ORDER[i]:
			Picture.RAINBOW:
				var colors: Array[Color] = [Color("d9534f"), Color("e8873a"), Color("e8c840"), Color("5aa05a"), Color("4aa0d0"), Color("3a5aa0"), Color("8a5ab0")]
				for k in colors.size():
					draw_arc(c + Vector2(0, 30), 70.0 - k * 7.0, PI, TAU, 32, colors[k], 6.0, true)
			Picture.CAT:
				draw_circle(c + Vector2(-30, -14), 18.0, Color("8a8a8a"))
				draw_colored_polygon(PackedVector2Array([c + Vector2(-44, -26), c + Vector2(-40, -46), c + Vector2(-30, -30)]), Color("8a8a8a"))
				draw_colored_polygon(PackedVector2Array([c + Vector2(-16, -26), c + Vector2(-20, -46), c + Vector2(-30, -30)]), Color("8a8a8a"))
				draw_rect(Rect2(c + Vector2(-20, -12), Vector2(70, 26)), Color("8a8a8a"))
				for k in 4:
					draw_line(c + Vector2(-14 + k * 20, 12), c + Vector2(-14 + k * 20, 36), INK, 5.0)
				draw_line(c + Vector2(50, -6), c + Vector2(66, -30), Color("8a8a8a"), 5.0)
			Picture.BIKE:
				draw_arc(c + Vector2(-40, 14), 26.0, 0.0, TAU, 32, INK, 5.0, true)
				draw_arc(c + Vector2(40, 14), 26.0, 0.0, TAU, 32, INK, 5.0, true)
				draw_polyline(PackedVector2Array([c + Vector2(-40, 14), c + Vector2(-6, -22), c + Vector2(30, -22), c + Vector2(40, 14)]), Color("c0503a"), 5.0)
			Picture.HAND:
				draw_circle(c + Vector2(0, 16), 26.0, Color("e8b890"))
				for k in 4:
					draw_line(c + Vector2(-18 + k * 12, 0), c + Vector2(-22 + k * 14, -40), Color("e8b890"), 10.0, true)
				draw_line(c + Vector2(20, 14), c + Vector2(44, -4), Color("e8b890"), 10.0, true)
			Picture.BAGEL:
				draw_arc(c, 26.0, 0.0, TAU, 40, Color("c08a4a"), 22.0, true)
			Picture.CANDLE:
				# Торт с одной свечкой: «один» без лучей и чёрточек, которые можно пересчитать.
				draw_rect(Rect2(c + Vector2(-60, -2), Vector2(120, 52)), Color("d98aa0"))
				draw_rect(Rect2(c + Vector2(-60, -2), Vector2(120, 14)), Color("f3e6d8"))
				draw_rect(Rect2(c + Vector2(-7, -42), Vector2(14, 40)), Color("5a8ad0"))
				draw_colored_polygon(PackedVector2Array([c + Vector2(0, -66), c + Vector2(-10, -46), c + Vector2(0, -40), c + Vector2(10, -46)]), Color("f0a020"))
	draw_set_transform(Vector2.ZERO)
