class_name MinigameRadioViewModel extends ViewModel
## Магнитола: найти по шкале станцию «концерт по заявкам» (её частоту называют в новостях),
## вставить кассету, которую просит ведущий, и нажать «Готово».
## Автоподстройка (как АПЧ на старых приёмниках): отпустил ручку рядом со станцией — приёмник ловит её сам,
## текст передачи становится чистым. Вердикт говорит, что именно не так: волна или кассета.

signal solved
signal submitted(verdict: Verdict)

enum Verdict { RIGHT, WRONG_STATION, NO_CASSETTE, WRONG_CASSETTE }

const VERDICT_KEYS: Dictionary = {
	Verdict.RIGHT: "radio.right",
	Verdict.WRONG_STATION: "radio.wrong.station",
	Verdict.NO_CASSETTE: "radio.wrong.no_cassette",
	Verdict.WRONG_CASSETTE: "radio.wrong.cassette",
}

const MIN_FREQUENCY := 88.0
const SPAN := 20.0
const CAPTURE := 1.2
const FINE_STEP := 0.1
const TUNE_TOLERANCE := 0.3
## В каком радиусе от станции автоподстройка её ловит.
const SNAP_RANGE := 0.8
const TARGET_STATION := 3
const TARGET_CASSETTE := 1
const CASSETTE_COUNT := 4

static var _stations: Array[RadioStation] = []

var frequency := Observable.new(MIN_FREQUENCY)
var strength := Observable.new(0.0)
## Чистый текст ближайшей станции; пустой, если сигнала нет.
var heard_text := Observable.new("")
var wave_cycles: float = 0.0
var cassette := Observable.new(-1)

var _done: bool = false
var _state: GameState


static func stations() -> Array[RadioStation]:
	if _stations.is_empty():
		_stations = [
			RadioStation.create(89.5, "radio.ad", 2.0),
			RadioStation.create(93.4, "radio.news", 3.0),
			RadioStation.create(97.2, "radio.music", 5.0),
			RadioStation.create(101.7, "radio.request", 7.0),
		]
	return _stations


## Угол ручки (0 — вправо) → частота.
static func frequency_from_angle(degrees: float) -> float:
	return MIN_FREQUENCY + fposmod(degrees + 90.0, 360.0) / 360.0 * SPAN


static func angle_for(freq: float) -> float:
	return (freq - MIN_FREQUENCY) / SPAN * 360.0 - 90.0


## Чем слабее сигнал, тем больше букв заменено случайными цифрами. Набор скрытых букв постоянный,
## сами цифры каждый вызов новые.
static func garble(text: String, signal_strength: float) -> String:
	var result := ""
	for i in text.length():
		var ch := text[i]
		var threshold := float((i * 37 + 11) % 100) / 100.0
		result += ch if (ch == " " or signal_strength > threshold) else str(randi() % 10)
	return result


func _init(state: GameState = null) -> void:
	_state = state
	_refresh()


func set_angle(degrees: float) -> void:
	if _done:
		return
	frequency.value = frequency_from_angle(degrees)
	_refresh()


## Точная подстройка стрелками: шаг по сетке 0,1, без выхода за шкалу.
func nudge(direction: int) -> void:
	if _done:
		return
	var next := snappedf(frequency.value + direction * FINE_STEP, FINE_STEP)
	frequency.value = clampf(next, MIN_FREQUENCY, MIN_FREQUENCY + SPAN - FINE_STEP)
	_refresh()


## Ручку отпустили: если рядом станция — ловим её точно.
func release() -> void:
	if _done:
		return
	var nearest := _nearest()
	if absf(nearest.frequency - frequency.value) <= SNAP_RANGE:
		frequency.value = nearest.frequency
		_refresh()


## Станция поймана точно (после автоподстройки или стрелками).
func is_locked() -> bool:
	return absf(_nearest().frequency - frequency.value) < FINE_STEP * 0.5


func is_solved() -> bool:
	return _done


func insert_cassette(index: int) -> void:
	if _done:
		return
	cassette.value = -1 if cassette.value == index else index


func verdict() -> Verdict:
	if absf(frequency.value - stations()[TARGET_STATION].frequency) > TUNE_TOLERANCE:
		return Verdict.WRONG_STATION
	if cassette.value < 0:
		return Verdict.NO_CASSETTE
	if cassette.value != TARGET_CASSETTE:
		return Verdict.WRONG_CASSETTE
	return Verdict.RIGHT


## Кнопка «Готово». После решения больше не реагирует: идёт запись.
## Не та волна или не та кассета — ошибка; без кассеты — просто подсказка.
func submit() -> void:
	if _done:
		return
	var result := verdict()
	submitted.emit(result)
	if (result == Verdict.WRONG_STATION or result == Verdict.WRONG_CASSETTE) and _state != null:
		_state.mistake()
	if result == Verdict.RIGHT:
		_done = true
		solved.emit()


func _nearest() -> RadioStation:
	var nearest := stations()[0]
	for station in stations():
		if absf(station.frequency - frequency.value) < absf(nearest.frequency - frequency.value):
			nearest = station
	return nearest


func _refresh() -> void:
	var nearest := _nearest()
	var s := clampf(1.0 - absf(nearest.frequency - frequency.value) / CAPTURE, 0.0, 1.0)
	strength.value = s
	if s <= 0.0:
		heard_text.value = ""
	else:
		heard_text.value = Texts.get_text(nearest.text_key)
	wave_cycles = nearest.wave_cycles
