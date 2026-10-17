class_name LanguageSelectView extends Control
## Первый экран игры: две кнопки с названиями языков. Названия не переводятся.

const NATIVE_NAMES: Dictionary = {"ru": "Русский", "en": "English"}
const BUTTON_SIZE := Vector2(460, 140)

var _vm: LanguageSelectViewModel
var _buttons: Dictionary = {}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var backdrop := ColorRect.new()
	backdrop.color = Color("14171d")
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var title := Label.new()
	title.text = "Язык / Language"
	title.position = Vector2(0, 300)
	title.size = Vector2(1920, 100)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	add_child(title)
	var x := 960.0 - (BUTTON_SIZE.x * Texts.LANGUAGES.size() + 60.0 * (Texts.LANGUAGES.size() - 1)) * 0.5
	for code in Texts.LANGUAGES:
		var button := Button.new()
		button.text = NATIVE_NAMES[code]
		button.position = Vector2(x, 480)
		button.size = BUTTON_SIZE
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 56)
		add_child(button)
		_buttons[code] = button
		x += BUTTON_SIZE.x + 60.0
	bind(LanguageSelectViewModel.new(Game.state))
	for code in _buttons:
		_buttons[code].pressed.connect(_vm.choose.bind(code))


func bind(vm: LanguageSelectViewModel) -> void:
	_vm = vm
	vm.selected.changed.connect(func(_code: String) -> void: _refresh())
	vm.chosen.connect(func(_code: String) -> void: Game.on_language_chosen())
	_refresh()


func _refresh() -> void:
	for code in _buttons:
		_buttons[code].modulate = Color.WHITE if code == _vm.selected.value else Color(0.7, 0.7, 0.75)
