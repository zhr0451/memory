class_name MinigameRadioViewModel extends ViewModel
## Магнитола: найти по шкале станцию «концерт по заявкам» (её частоту называют в новостях),
## вставить кассету, которую просит ведущий, и нажать «Готово».

signal solved
signal submitted(correct: bool)

const MIN_FREQUENCY := 88.0
const SPAN := 20.0
const CAPTURE := 1.2
const FINE_STEP := 0.1
const TUNE_TOLERANCE := 0.3
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


func _init() -> void:
	_refresh()


func set_angle(degrees: float) -> void:
	frequency.value = frequency_from_angle(degrees)
	_refresh()


## Точная подстройка стрелками: шаг по сетке 0,1, без выхода за шкалу.
func nudge(direction: int) -> void:
	var next := snappedf(frequency.value + direction * FINE_STEP, FINE_STEP)
	frequency.value = clampf(next, MIN_FREQUENCY, MIN_FREQUENCY + SPAN - FINE_STEP)
	_refresh()


func insert_cassette(index: int) -> void:
	cassette.value = -1 if cassette.value == index else index


## Кнопка «Готово».
func submit() -> void:
	var tuned := absf(frequency.value - stations()[TARGET_STATION].frequency) <= TUNE_TOLERANCE
	var ok: bool = tuned and cassette.value == TARGET_CASSETTE
	submitted.emit(ok)
	if ok and not _done:
		_done = true
		solved.emit()


func _refresh() -> void:
	var nearest := stations()[0]
	for station in stations():
		if absf(station.frequency - frequency.value) < absf(nearest.frequency - frequency.value):
			nearest = station
	var s := clampf(1.0 - absf(nearest.frequency - frequency.value) / CAPTURE, 0.0, 1.0)
	strength.value = s
	if s <= 0.0:
		heard_text.value = ""
	else:
		heard_text.value = Texts.get_text(nearest.text_key)
	wave_cycles = nearest.wave_cycles
