class_name MinigameProjectorViewModel extends ViewModel
## Диафильм: четыре ручки проектора. Нужно поставить все в верное положение и нажать «Готово».
## Фокус зависит от масштаба: целевое положение фокуса «плывёт» вместе с ручкой масштаба.

signal solved
signal submitted(correct_count: int, total: int)
signal visuals_changed

enum Knob { LAMP, FRAME, ZOOM, FOCUS }

## Целевые значения ручек (0…1 по кругу, начало — сверху, по часовой).
const TARGETS: Dictionary = {Knob.LAMP: 0.62, Knob.FRAME: 0.35, Knob.ZOOM: 0.55}
const START: Dictionary = {Knob.LAMP: 0.15, Knob.FRAME: 0.85, Knob.ZOOM: 0.10, Knob.FOCUS: 0.90}
const TOLERANCE: Dictionary = {Knob.LAMP: 0.05, Knob.FRAME: 0.03, Knob.ZOOM: 0.04, Knob.FOCUS: 0.04}
const FOCUS_BASE := 0.15
const FOCUS_SLOPE := 0.6
const MAX_BLUR := 6.0
const BLUR_FALLOFF := 0.25
const SHIFT_PER_UNIT := 700.0
const ZOOM_PER_UNIT := 1.2

var values: Dictionary = START.duplicate()

## Производные величины для картинки.
var darkness: float = 0.0
var glare: float = 0.0
var shift: float = 0.0
var picture_scale: float = 1.0
var blur: float = MAX_BLUR

var _done: bool = false


func _init() -> void:
	_refresh()


## Угол ручки View (0 — вправо) → значение 0…1 (0 — сверху).
static func value_from_angle(degrees: float) -> float:
	return fposmod(degrees + 90.0, 360.0) / 360.0


static func angle_for(value: float) -> float:
	return value * 360.0 - 90.0


func set_angle(knob: int, degrees: float) -> void:
	values[knob] = value_from_angle(degrees)
	_refresh()


func focus_target() -> float:
	return fposmod(FOCUS_BASE + FOCUS_SLOPE * values[Knob.ZOOM], 1.0)


func knob_correct(knob: int) -> bool:
	var target: float = focus_target() if knob == Knob.FOCUS else TARGETS[knob]
	return _circular_distance(values[knob], target) <= TOLERANCE[knob]


func correct_count() -> int:
	var count := 0
	for knob in Knob.values():
		if knob_correct(knob):
			count += 1
	return count


## Кнопка «Готово».
func submit() -> void:
	var count := correct_count()
	submitted.emit(count, Knob.size())
	if count == Knob.size() and not _done:
		_done = true
		solved.emit()


func _refresh() -> void:
	var lamp: float = values[Knob.LAMP]
	var lamp_target: float = TARGETS[Knob.LAMP]
	darkness = clampf((lamp_target - lamp) / lamp_target, 0.0, 1.0) * 0.9
	glare = clampf((lamp - lamp_target) / (1.0 - lamp_target), 0.0, 1.0) * 0.85
	shift = (values[Knob.FRAME] - TARGETS[Knob.FRAME]) * SHIFT_PER_UNIT
	picture_scale = 1.0 + (values[Knob.ZOOM] - TARGETS[Knob.ZOOM]) * ZOOM_PER_UNIT
	var focus_error := _circular_distance(values[Knob.FOCUS], focus_target())
	blur = MAX_BLUR * clampf((focus_error - TOLERANCE[Knob.FOCUS] * 0.5) / BLUR_FALLOFF, 0.0, 1.0)
	visuals_changed.emit()


func _circular_distance(a: float, b: float) -> float:
	var d := absf(a - b)
	return minf(d, 1.0 - d)
