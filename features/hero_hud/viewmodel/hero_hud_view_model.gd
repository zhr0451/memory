class_name HeroHudViewModel extends ViewModel
## Лицо, батарейка и реплики героя — отражение GameState.

var emotion: Observable
var battery: Observable
var face_on: Observable
var hud_visible: Observable
var line: Observable

var _state: GameState


func _init(state: GameState) -> void:
	_state = state
	emotion = state.emotion
	battery = state.battery
	face_on = state.face_on
	hud_visible = state.hud_visible
	line = state.current_line


func finish_line() -> void:
	_state.finish_line()
