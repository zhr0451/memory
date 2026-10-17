class_name UiStyle extends RefCounted
## Единый вид кнопок: рамка, наведение, нажатие/включено (зелёный).


static func style_button(button: Button) -> void:
	button.add_theme_stylebox_override("normal", _box(Color("3c4455")))
	button.add_theme_stylebox_override("hover", _box(Color("4b556a")))
	button.add_theme_stylebox_override("pressed", _box(Color("5f8a54")))
	button.add_theme_stylebox_override("hover_pressed", _box(Color("6a9a5e")))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color"]:
		button.add_theme_color_override(color_name, Color("eef1f6"))


static func _box(color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = Color("8e99a8")
	box.set_border_width_all(3)
	box.set_corner_radius_all(12)
	box.set_content_margin_all(8)
	return box
