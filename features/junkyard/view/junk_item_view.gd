class_name JunkItemView extends Control
## Предмет в куче. Все выглядят одинаково: какой из них «живой», показывает только сканер.
## Кликается только следующий по сюжету. Пока нет item_<id>.png, рисуется заглушка с подписью.

signal pressed(index: int)

const SIZE := Vector2(200, 200)
const ASSET_DIR := "res://features/junkyard/assets/"

var index: int = 0

var _item_id: StringName
var _state: JunkyardViewModel.ItemState = JunkyardViewModel.ItemState.LOCKED
var _texture: Texture2D
var _hover: bool = false


func setup(p_index: int, p_id: StringName) -> void:
	index = p_index
	_item_id = p_id
	var path := "%sitem_%s.png" % [ASSET_DIR, p_id]
	_texture = load(path) if ResourceLoader.exists(path) else null


func _ready() -> void:
	custom_minimum_size = SIZE
	size = SIZE
	pivot_offset = SIZE * 0.5
	mouse_entered.connect(func() -> void: _set_hover(true))
	mouse_exited.connect(func() -> void: _set_hover(false))


func apply_state(state: JunkyardViewModel.ItemState) -> void:
	_state = state
	var available := state == JunkyardViewModel.ItemState.AVAILABLE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if available else Control.CURSOR_ARROW


func _gui_input(event: InputEvent) -> void:
	var button := event as InputEventMouseButton
	if button != null and button.button_index == MOUSE_BUTTON_LEFT and button.pressed:
		if _state == JunkyardViewModel.ItemState.AVAILABLE:
			pressed.emit(index)


func _set_hover(value: bool) -> void:
	_hover = value and _state == JunkyardViewModel.ItemState.AVAILABLE
	create_tween().tween_property(self, "scale", Vector2.ONE * (1.07 if _hover else 1.0), 0.12)


func _draw() -> void:
	if _texture != null:
		draw_texture_rect(_texture, Rect2(Vector2.ZERO, size), false)
	else:
		var body := Color("7a8599")
		draw_rect(Rect2(10, 40, 180, 140), body)
		draw_rect(Rect2(10, 40, 180, 140), Color("2b323f"), false, 4.0)
		var font := ThemeDB.fallback_font
		var title := Texts.get_text("item.%s" % _item_id)
		draw_string(font, Vector2(0, 118), title, HORIZONTAL_ALIGNMENT_CENTER, size.x, 30, Color("1c2029"))
