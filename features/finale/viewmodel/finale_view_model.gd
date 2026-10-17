class_name FinaleViewModel extends ViewModel
## Финал: «Он меня нашёл», батарейка 0, лицо гаснет.

var _state: GameState


func _init(state: GameState) -> void:
	_state = state


func sad() -> void:
	_state.emotion.value = Emotion.Kind.SAD


func speak() -> Signal:
	_state.say("finale.1")
	return _state.lines_drained


func power_off() -> void:
	_state.battery.value = 0
	_state.emotion.value = Emotion.Kind.OFF
	_state.face_on.value = false
