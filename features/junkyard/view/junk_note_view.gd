class_name JunkNoteView extends Control
## Спрятанная среди мусора подсказка: смятая записка, дискета или дверца холодильника с рисунком. Нарочно без блеска: её надо заметить самому.
## Если есть item_note.png / item_floppy.png / item_fridge.png — рисуется он.

signal pressed

const ASSET_DIR := "res://features/junkyard/assets/"
const SIZES: Dictionary = {
	JunkyardViewModel.Clue.NOTE: Vector2(96, 72),
	JunkyardViewModel.Clue.FLOPPY: Vector2(84, 84),
	JunkyardViewModel.Clue.FRIDGE: Vector2(120, 170),
}
const TILTS: Dictionary = {
	JunkyardViewModel.Clue.NOTE: 14.0,
	JunkyardViewModel.Clue.FLOPPY: -24.0,
	JunkyardViewModel.Clue.FRIDGE: -8.0,
}
const FILES: Dictionary = {
	JunkyardViewModel.Clue.NOTE: "item_note.png",
	JunkyardViewModel.Clue.FLOPPY: "item_floppy.png",
	JunkyardViewModel.Clue.FRIDGE: "item_fridge.png",
}

var clue: JunkyardViewModel.Clue = JunkyardViewModel.Clue.NOTE

var _texture: Texture2D


static func create(p_clue: JunkyardViewModel.Clue) -> JunkNoteView:
	var view := JunkNoteView.new()
	view.clue = p_clue
	return view


## Есть ли нарисованный художником арт. Арт уже вписан в фон: без наклона и без накрывающей кучи.
static func has_art(p_clue: JunkyardViewModel.Clue) -> bool:
	return ResourceLoader.exists(ASSET_DIR + FILES[p_clue])


func _ready() -> void:
	var path: String = ASSET_DIR + FILES[clue]
	_texture = load(path) if ResourceLoader.exists(path) else null
	custom_minimum_size = SIZES[clue]
	size = SIZES[clue]
	pivot_offset = size * 0.5
	if _texture == null:
		rotation = deg_to_rad(TILTS[clue])
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _gui_input(event: InputEvent) -> void:
	var button := event as InputEventMouseButton
	if button != null and button.button_index == MOUSE_BUTTON_LEFT and button.pressed:
		pressed.emit()


func _draw() -> void:
	if _texture != null:
		draw_texture_rect(_texture, Rect2(Vector2.ZERO, size), false)
	elif clue == JunkyardViewModel.Clue.FLOPPY:
		_draw_floppy()
	elif clue == JunkyardViewModel.Clue.FRIDGE:
		_draw_fridge()
	else:
		_draw_note()


func _draw_note() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("8a8d99"))
	draw_rect(Rect2(Vector2.ZERO, size), Color("5d606c"), false, 2.0)
	for i in 4:
		draw_line(Vector2(10, 16 + i * 14), Vector2(size.x - 14 - i * 6, 16 + i * 14), Color("5d606c"), 2.0)


func _draw_floppy() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("3d4250"))
	draw_rect(Rect2(Vector2.ZERO, size), Color("272b35"), false, 2.0)
	draw_rect(Rect2(22, 0, 40, 26), Color("9aa0ab"))
	draw_rect(Rect2(14, 42, 56, 38), Color("c9c5b8"))


func _draw_fridge() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("9aa3b2"))
	draw_rect(Rect2(Vector2.ZERO, size), Color("5d606c"), false, 3.0)
	draw_rect(Rect2(10, 70, 6, 50), Color("5d606c"))
	# Детский рисунок под магнитом: шесть цветных пятнышек-картинок.
	draw_rect(Rect2(30, 22, 74, 96), Color("e8e2d0"))
	draw_circle(Vector2(67, 22), 7.0, Color("c0503a"))
	var colors: Array[Color] = [Color("d9534f"), Color("e0a040"), Color("5a9a5a"), Color("e0c060"), Color("a07050"), Color("e8c040")]
	for i in colors.size():
		draw_circle(Vector2(48 + (i % 2) * 38, 42 + floori(i / 2.0) * 28), 9.0, colors[i])


## Куча мусора поверх подсказки: прикрывает её часть.
class Cover extends Control:
	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		size = Vector2(240, 160)

	func _draw() -> void:
		var color := Color("1b2330")
		draw_colored_polygon(PackedVector2Array([
			Vector2(0, 160), Vector2(40, 40), Vector2(130, 70), Vector2(200, 0), Vector2(240, 160)]), color)
