class_name MinigameView extends Control
## Основа мини-игры: кнопка «назад», единая точка завершения и хелперы для заглушек.
## Наследник переопределяет _build() и вызывает _finish(), когда предмет ожил.

const SOLVE_DELAY := 1.2
## Меньше этого надписи не ужимаются, даже если не влезают.
const MIN_FONT_SIZE := 16

## Индекс предмета в Story.
var item: int = 0

var _solved: bool = false


func setup(params: Dictionary) -> void:
	item = params.get("item", 0)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	var back := BackButton.new()
	add_child(back)
	back.pressed.connect(_on_back_pressed)


## Переопределяется: собрать узлы мини-игры.
func _build() -> void:
	pass


func _finish() -> void:
	if _solved:
		return
	_solved = true
	await get_tree().create_timer(SOLVE_DELAY).timeout
	Game.on_minigame_solved(item)


func _on_back_pressed() -> void:
	SceneManager.change_to(&"junkyard", {"zoom_from": item})


func _add_rect(rect: Rect2, color: Color) -> ColorRect:
	var node := ColorRect.new()
	node.color = color
	node.position = rect.position
	node.size = rect.size
	add_child(node)
	return node


func _add_label(text: String, rect: Rect2, font_size: int, color: Color = Color.WHITE) -> Label:
	var label := Label.new()
	# Перенос включаем до текста и размера: иначе Label растягивается под всю строку и игнорирует ширину rect.
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text = text
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_size_override("font_size", _fitting_font_size(text, rect.size, font_size))
	label.add_theme_color_override("font_color", color)
	add_child(label)
	return label


## Самый крупный размер шрифта не больше font_size, при котором text с переносами влезает в box.
## Нужен, потому что длина строк зависит от языка и шрифта, а рамки мини-игр фиксированные.
func _fitting_font_size(text: String, box: Vector2, font_size: int) -> int:
	if text == "":
		return font_size
	var font := ThemeDB.fallback_font
	var fit := font_size
	while fit > MIN_FONT_SIZE:
		var height := font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, box.x, fit).y
		if height <= box.y:
			break
		fit -= 2
	return fit


func _add_button(text: String, rect: Rect2, font_size: int = 36) -> Button:
	var button := Button.new()
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", font_size)
	UiStyle.style_button(button)
	add_child(button)
	return button


func _add_glyph_button(glyph: GlyphButton.Glyph, rect: Rect2) -> GlyphButton:
	var button := GlyphButton.create(glyph, rect)
	add_child(button)
	return button
