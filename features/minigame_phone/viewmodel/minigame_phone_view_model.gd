class_name MinigamePhoneViewModel extends ViewModel
## Дисковый телефон: позвонить бабушке. Номер нарисован картинками на холодильнике (свалка):
## радуга (7), кошка (4), велосипед (2), ладошка (5), бублик (0), торт с одной свечкой (1) → 74-25-01.
## Цифры на диске стёрлись: подтверждение — число щелчков при возврате диска.
## Вердикт — после шестой цифры: длинные гудки и бабушкин голос или короткие гудки (ошибка, батарейка садится).

signal solved
signal dialed_digit(digit: int, pulses: int)

enum Line { HUNG_UP, TONE, DIALING, RINGING, BUSY }

const NUMBER := "742501"
## Угол упора (градусы, 0 — вправо, по часовой).
const STOP_ANGLE := 60.0
const HOLE_STEP := 30.0
## Насколько не дотянуть до упора и всё равно засчитать.
const STOP_SLACK := 6.0

var line := Observable.new(Line.HUNG_UP)
var dialed := Observable.new("")

var _state: GameState
var _done: bool = false
var _hinted_no_tone: bool = false


func _init(state: GameState = null) -> void:
	_state = state


## Рисунок с холодильника нашли на свалке (без состояния — считаем, что нашли).
func note_available() -> bool:
	return _state == null or _state.phone_note_found.value


func activate() -> void:
	if not note_available():
		_say("phone.confused")


## Сколько щелчков даёт цифра: 1…9, ноль — 10.
static func pulses_for(digit: int) -> int:
	return 10 if digit == 0 else digit


## Угол отверстия цифры в покое: «1» ближе всех к упору, «0» дальше всех.
static func hole_angle(digit: int) -> float:
	return fposmod(STOP_ANGLE - (pulses_for(digit) + 0.5) * HOLE_STEP, 360.0)


## На сколько градусов по часовой надо довернуть диск от этого отверстия до упора.
static func pull_needed(digit: int) -> float:
	return (pulses_for(digit) + 0.5) * HOLE_STEP


static func reached_stop(digit: int, rotation_degrees: float) -> bool:
	return rotation_degrees >= pull_needed(digit) - STOP_SLACK


func is_solved() -> bool:
	return _done


## Клик по трубке: снять или положить.
func toggle_receiver() -> void:
	if _done:
		return
	if line.value == Line.HUNG_UP:
		dialed.value = ""
		line.value = Line.TONE
	else:
		line.value = Line.HUNG_UP
		dialed.value = ""


## Рычаг: сбросить набор, трубка остаётся снятой — снова гудок.
func press_hook() -> void:
	if _done or line.value == Line.HUNG_UP:
		return
	dialed.value = ""
	line.value = Line.TONE


## Диск довели до упора и отпустили. Без гудка цифра не набирается, но щелчки всё равно слышны.
func dial(digit: int) -> void:
	if _done:
		return
	dialed_digit.emit(digit, pulses_for(digit))
	if line.value == Line.HUNG_UP:
		if not _hinted_no_tone:
			_hinted_no_tone = true
			_say("phone.no_tone")
		return
	if line.value != Line.TONE and line.value != Line.DIALING:
		return
	dialed.value += str(digit)
	line.value = Line.DIALING
	if dialed.value.length() < NUMBER.length():
		return
	if dialed.value == NUMBER:
		_done = true
		line.value = Line.RINGING
		solved.emit()
	else:
		line.value = Line.BUSY
		if _state != null:
			_state.mistake()


func _say(key: String) -> void:
	if _state != null:
		_state.say(key)
