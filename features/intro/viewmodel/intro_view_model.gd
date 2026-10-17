class_name IntroViewModel extends ViewModel
## Вступление: герой включается и говорит первые реплики.

const LINES: Array[String] = ["intro.1", "intro.2", "intro.3"]

var _state: GameState


func _init(state: GameState) -> void:
	_state = state


func power_on() -> void:
	_state.face_on.value = true
	_state.emotion.value = Emotion.Kind.JOY


## Ставит реплики в очередь; сигнал срабатывает, когда все показаны.
func speak() -> Signal:
	for key in LINES:
		_state.say(key)
	return _state.lines_drained
