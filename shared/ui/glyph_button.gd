class_name GlyphButton extends Button
## Кнопка с иконкой, нарисованной кодом: в веб-шрифте нет символов ←▲▼▶■, поэтому текстом их не пишем.

enum Glyph { BACK, UP, DOWN, REWIND, PLAY, FORWARD, STOP }

@export var glyph: Glyph = Glyph.PLAY

const ICON_COLOR := Color("e8ecf2")


func _ready() -> void:
	UiStyle.style_button(self)


static func create(p_glyph: Glyph, rect: Rect2) -> GlyphButton:
	var button := GlyphButton.new()
	button.glyph = p_glyph
	button.position = rect.position
	button.size = rect.size
	button.focus_mode = Control.FOCUS_NONE
	return button


func _draw() -> void:
	var c := size * 0.5
	var u := minf(size.x, size.y) * 0.24
	match glyph:
		Glyph.BACK:
			draw_colored_polygon(PackedVector2Array([c + Vector2(-u, 0), c + Vector2(0, -u), c + Vector2(0, u)]), ICON_COLOR)
			draw_rect(Rect2(c + Vector2(0, -u * 0.35), Vector2(u, u * 0.7)), ICON_COLOR)
		Glyph.UP:
			draw_colored_polygon(PackedVector2Array([c + Vector2(-u, u * 0.6), c + Vector2(u, u * 0.6), c + Vector2(0, -u * 0.8)]), ICON_COLOR)
		Glyph.DOWN:
			draw_colored_polygon(PackedVector2Array([c + Vector2(-u, -u * 0.6), c + Vector2(u, -u * 0.6), c + Vector2(0, u * 0.8)]), ICON_COLOR)
		Glyph.PLAY:
			_triangle(c, u, 1.0)
		Glyph.REWIND:
			_triangle(c + Vector2(-u * 0.9, 0), u, -1.0)
			_triangle(c + Vector2(u * 0.9, 0), u, -1.0)
		Glyph.FORWARD:
			_triangle(c + Vector2(-u * 0.9, 0), u, 1.0)
			_triangle(c + Vector2(u * 0.9, 0), u, 1.0)
		Glyph.STOP:
			draw_rect(Rect2(c - Vector2(u, u) * 0.9, Vector2(u, u) * 1.8), ICON_COLOR)


func _triangle(center: Vector2, u: float, direction: float) -> void:
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-u * 0.7 * direction, -u),
		center + Vector2(-u * 0.7 * direction, u),
		center + Vector2(u * 0.8 * direction, 0)]), ICON_COLOR)
