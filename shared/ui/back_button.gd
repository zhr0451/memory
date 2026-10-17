class_name BackButton extends Button
## Стрелка «назад» в углу мини-игры. Если есть ui_back.png, показывается она.

const ICON_PATH := "res://shared/ui/assets/ui_back.png"


func _ready() -> void:
	custom_minimum_size = Vector2(72, 72)
	size = custom_minimum_size
	position = Vector2(32, 32)
	focus_mode = Control.FOCUS_NONE
	flat = false
	if ResourceLoader.exists(ICON_PATH):
		icon = load(ICON_PATH) as Texture2D
	else:
		text = "←"
		add_theme_font_size_override("font_size", 40)
