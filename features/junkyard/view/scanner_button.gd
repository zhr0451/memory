class_name ScannerButton extends Button
## Кнопка сканера в правом нижнем углу свалки (слева внизу — лицо и батарейка).
## Если есть ui_scanner.png — показывается он, иначе заглушка: коробочка с антенной и зелёным экраном.

const ICON_PATH := "res://features/junkyard/assets/ui_scanner.png"
const SIZE := Vector2(120, 120)
const MARGIN := 32.0
const BODY := Color("4a5263")
const SCREEN := Color("37e07a")


func _ready() -> void:
	UiStyle.style_button(self)
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tooltip_text = Texts.get_text("ui.scanner")
	size = SIZE
	position = Vector2(1920, 1080) - SIZE - Vector2(MARGIN, MARGIN)
	pivot_offset = SIZE * 0.5
	if ResourceLoader.exists(ICON_PATH):
		icon = load(ICON_PATH) as Texture2D
		flat = true
		expand_icon = true
		icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		# Арт сам себе рамка: без полей стиля кнопки, на весь размер.
		for state in ["normal", "hover", "pressed", "disabled", "focus"]:
			add_theme_stylebox_override(state, StyleBoxEmpty.new())


## Герой «достаёт» сканер: кнопка подпрыгивает.
func show_pulse() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * 1.18, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.25)


## Сканер не включился (мало заряда): кнопка качает головой.
func show_refused() -> void:
	var tween := create_tween()
	for offset in [12.0, -12.0, 8.0, 0.0]:
		tween.tween_property(self, "rotation_degrees", offset, 0.06)


func _draw() -> void:
	if icon != null:
		return
	var c := size * 0.5
	draw_line(c + Vector2(16, -26), c + Vector2(28, -46), Color("c9d1dc"), 4.0, true)
	draw_circle(c + Vector2(28, -46), 5.0, Color("e05a4a"))
	draw_rect(Rect2(c + Vector2(-28, -26), Vector2(56, 64)), BODY)
	draw_rect(Rect2(c + Vector2(-28, -26), Vector2(56, 64)), Color("1f242e"), false, 3.0)
	draw_rect(Rect2(c + Vector2(-20, -18), Vector2(40, 28)), SCREEN)
	for i in 3:
		draw_line(c + Vector2(-20, -12 + i * 9), c + Vector2(20, -12 + i * 9), Color("1d7a44"), 2.0)
	draw_circle(c + Vector2(0, 26), 6.0, Color("8e99a8"))
