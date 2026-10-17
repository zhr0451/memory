class_name MinigameProjectorViewModel extends ViewModel
## Диафильм: четыре шага настройки проектора — лампа, кадр, масштаб, фокус.
## Одновременно доступна одна ручка, но на картинке сразу видны все дефекты:
## каждый шаг исправляет свой, и к концу картинка становится итоговой.
## Ручка встаёт на место, как только попала в допуск, и открывается следующая.

signal solved
signal visuals_changed
signal step_changed(step: int)
signal knob_locked(knob: int)

enum Knob { LAMP, FRAME, ZOOM, FOCUS }

## Целевые значения ручек (0…1 по кругу, начало — сверху, по часовой).
const TARGETS: Dictionary = {Knob.LAMP: 0.62, Knob.FRAME: 0.35, Knob.ZOOM: 0.55, Knob.FOCUS: 0.30}
const START: Dictionary = {Knob.LAMP: 0.28, Knob.FRAME: 0.46, Knob.ZOOM: 0.35, Knob.FOCUS: 0.90}
const TOLERANCE: Dictionary = {Knob.LAMP: 0.05, Knob.FRAME: 0.03, Knob.ZOOM: 0.04, Knob.FOCUS: 0.04}
const MAX_BLUR := 6.0
const BLUR_FALLOFF := 0.25
const SHIFT_PER_UNIT := 700.0
const ZOOM_PER_UNIT := 1.2

var values: Dictionary = START.duplicate()
var step := Observable.new(0)

## Производные величины для картинки.
var darkness: float = 0.0
var glare: float = 0.0
var shift: float = 0.0
var picture_scale: float = 1.0
var blur: float = 0.0

var _done: bool = false


func _init() -> void:
	_refresh()


## Угол ручки View (0 — вправо) → значение 0…1 (0 — сверху).
static func value_from_angle(degrees: float) -> float:
	return fposmod(degrees + 90.0, 360.0) / 360.0


static func angle_for(value: float) -> float:
	return value * 360.0 - 90.0


## Ключ подсказки для текущего шага (по виду картинки).
func hint_key() -> String:
	if _done:
		return "projector.done"
	var knob: int = step.value
	match knob:
		Knob.LAMP:
			return "projector.hint.lamp_bright" if values[Knob.LAMP] > TARGETS[Knob.LAMP] else "projector.hint.lamp_dark"
		Knob.FRAME:
			return "projector.hint.frame"
		Knob.ZOOM:
			return "projector.hint.zoom_big" if values[Knob.ZOOM] > TARGETS[Knob.ZOOM] else "projector.hint.zoom_small"
	return "projector.hint.focus"


func is_locked(knob: int) -> bool:
	return knob < step.value


func is_active(knob: int) -> bool:
	return knob == step.value and not _done


## Крутить можно только активную ручку; попав в допуск, она фиксируется.
func set_angle(knob: int, degrees: float) -> void:
	if not is_active(knob):
		return
	values[knob] = value_from_angle(degrees)
	if _circular_distance(values[knob], TARGETS[knob]) <= TOLERANCE[knob]:
		values[knob] = TARGETS[knob]
		knob_locked.emit(knob)
		step.value += 1
		step_changed.emit(step.value)
		if step.value >= Knob.size():
			_done = true
			_refresh()
			solved.emit()
			return
	_refresh()


## Картинка сразу показывает все неисправленные дефекты; каждый шаг убирает свой.
func _refresh() -> void:
	var lamp: float = values[Knob.LAMP]
	var lamp_target: float = TARGETS[Knob.LAMP]
	var lamp_fixed := _is_fixed(Knob.LAMP)
	darkness = 0.0 if lamp_fixed else clampf((lamp_target - lamp) / lamp_target, 0.0, 1.0)
	glare = 0.0 if lamp_fixed else clampf((lamp - lamp_target) / (1.0 - lamp_target), 0.0, 1.0) * 0.85
	shift = 0.0 if _is_fixed(Knob.FRAME) else (values[Knob.FRAME] - TARGETS[Knob.FRAME]) * SHIFT_PER_UNIT
	picture_scale = 1.0 if _is_fixed(Knob.ZOOM) else 1.0 + (values[Knob.ZOOM] - TARGETS[Knob.ZOOM]) * ZOOM_PER_UNIT
	var error := _circular_distance(values[Knob.FOCUS], TARGETS[Knob.FOCUS])
	blur = 0.0 if _is_fixed(Knob.FOCUS) else MAX_BLUR * clampf((error - TOLERANCE[Knob.FOCUS] * 0.5) / BLUR_FALLOFF, 0.0, 1.0)
	visuals_changed.emit()


func _is_fixed(knob: int) -> bool:
	return _done or knob < step.value


func _circular_distance(a: float, b: float) -> float:
	var d := absf(a - b)
	return minf(d, 1.0 - d)
