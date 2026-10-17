class_name MinigameView extends Control
## Основа мини-игры: кнопка «назад», единая точка завершения и хелперы для заглушек.
## Наследник переопределяет _build() и вызывает _finish(), когда предмет ожил.

const SOLVE_DELAY := 1.2

var chapter: int = 0

var _solved: bool = false


func setup(params: Dictionary) -> void:
	chapter = params.get("chapter", 0)


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
	Game.on_minigame_solved(chapter)


func _on_back_pressed() -> void:
	SceneManager.change_to(&"junkyard", {"zoom_from": chapter})


func _add_rect(rect: Rect2, color: Color) -> ColorRect:
	var node := ColorRect.new()
	node.color = color
	node.position = rect.position
	node.size = rect.size
	add_child(node)
	return node


func _add_label(text: String, rect: Rect2, font_size: int, color: Color = Color.WHITE) -> Label:
	var label := Label.new()
	label.text = text
	label.position = rect.position
	label.size = rect.size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	add_child(label)
	return label


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
