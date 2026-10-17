class_name LanguageSelectViewModel extends ViewModel
## Выбор языка перед началом игры. Выбор запоминается и подставляется в следующий раз.

signal chosen(code: String)

var selected: Observable

var _state: GameState


func _init(state: GameState) -> void:
	_state = state
	selected = Observable.new(Settings.load_language(Texts.LANGUAGES))


func choose(code: String) -> void:
	Texts.set_language(code)
	Settings.save_language(code)
	selected.value = code
	_state.hud_visible.value = true
	chosen.emit(code)
