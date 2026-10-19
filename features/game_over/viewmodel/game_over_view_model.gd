class_name GameOverViewModel extends ViewModel
## Проигрыш: батарейка села от ошибок. Герой гаснет; «Попробовать ещё» — глава заново.

var _state: GameState


func _init(state: GameState) -> void:
	_state = state


## Последняя реплика перед тем, как погаснуть.
func speak() -> Signal:
	_state.emotion.value = Emotion.Kind.FEAR
	_state.say("game_over.line")
	return _state.lines_drained


func power_off() -> void:
	_state.emotion.value = Emotion.Kind.OFF
	_state.face_on.value = false


## Вернуть главу к началу (заряд, предметы, эмоция — как в начале главы).
func retry() -> void:
	_state.restart_chapter()
