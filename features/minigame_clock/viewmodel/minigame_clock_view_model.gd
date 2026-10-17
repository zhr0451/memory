class_name MinigameClockViewModel extends ViewModel
## Будильник: время и дни звонка надо вывести из записки и нажать «Завести».
## Записка: урок в 8:30, дорога 45 минут, умывание и завтрак 15 минут, по выходным не вставать.

signal solved
signal submitted(correct: bool)

const LESSON_MINUTES := 8 * 60 + 30
const WALK_MINUTES := 45
const PREP_MINUTES := 15
const WORKDAYS := 0b0011111  # биты 0…4 — Пн…Пт

var hour := Observable.new(12)
var minute := Observable.new(0)
var pm := Observable.new(true)
var days := Observable.new(0b1100000)  # старт: включены Сб и Вс

var _done: bool = false
var _state: GameState


func _init(state: GameState = null) -> void:
	_state = state


## Записка нужна для решения; если её ещё не нашли, герой в замешательстве.
func note_available() -> bool:
	return _state == null or _state.clock_note_found.value


func activate() -> void:
	if not note_available():
		_state.say("clock.confused")


static func target_minutes() -> int:
	return LESSON_MINUTES - WALK_MINUTES - PREP_MINUTES


## Угол ручки (0 — вправо) → час 1…12.
static func hour_from_angle(degrees: float) -> int:
	var h := int(roundf(fposmod(degrees + 90.0, 360.0) / 30.0)) % 12
	return 12 if h == 0 else h


## Угол ручки (0 — вправо) → минуты 0…59.
static func minute_from_angle(degrees: float) -> int:
	return int(roundf(fposmod(degrees + 90.0, 360.0) / 6.0)) % 60


func set_hour(value: int) -> void:
	hour.value = posmod(value - 1, 12) + 1


func set_minute(value: int) -> void:
	minute.value = posmod(value, 60)


func set_pm(value: bool) -> void:
	pm.value = value


func toggle_day(index: int) -> void:
	days.value = days.value ^ (1 << index)


func is_day_on(index: int) -> bool:
	return (days.value >> index) & 1 == 1


func total_minutes() -> int:
	return ((hour.value % 12) + (12 if pm.value else 0)) * 60 + minute.value


func time_text() -> String:
	return "%02d:%02d" % [hour.value, minute.value]


func is_correct() -> bool:
	return total_minutes() == target_minutes() and days.value == WORKDAYS


## Кнопка «Завести».
func submit() -> void:
	var ok := is_correct()
	submitted.emit(ok)
	if ok and not _done:
		_done = true
		solved.emit()
