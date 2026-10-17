class_name MinigameClockViewModel extends ViewModel
## Будильник: выставить время с детского рисунка (07:30). Минуты — с шагом 5.

signal solved

const TARGET_HOURS := 7
const TARGET_MINUTES := 30
const MINUTE_STEP := 5

var hours := Observable.new(9)
var minutes := Observable.new(15)

var _done: bool = false


func change_hours(direction: int) -> void:
	hours.value = posmod(hours.value + direction, 24)
	_check()


func change_minutes(direction: int) -> void:
	minutes.value = posmod(minutes.value + direction * MINUTE_STEP, 60)
	_check()


func time_text() -> String:
	return "%02d:%02d" % [hours.value, minutes.value]


func is_correct() -> bool:
	return hours.value == TARGET_HOURS and minutes.value == TARGET_MINUTES


func _check() -> void:
	if not _done and is_correct():
		_done = true
		solved.emit()
