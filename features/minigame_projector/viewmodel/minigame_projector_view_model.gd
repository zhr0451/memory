class_name MinigameProjectorViewModel extends ViewModel
## Диафильм: угол ручки задаёт резкость. Решено, когда картинка чёткая 1 секунду.

signal solved

const TARGET_ANGLE := 217.0
const TOLERANCE := 7.0
const HOLD_TIME := 1.0
const MAX_BLUR := 6.0
const FALLOFF := 90.0

var angle := Observable.new(0.0)
var blur := Observable.new(MAX_BLUR)

var _held: float = 0.0
var _done: bool = false


func set_angle(degrees: float) -> void:
	angle.value = fposmod(degrees, 360.0)
	var distance := _distance()
	blur.value = 0.0 if distance <= TOLERANCE else MAX_BLUR * clampf(distance / FALLOFF, 0.0, 1.0)


func tick(delta: float) -> void:
	if _done:
		return
	if _distance() <= TOLERANCE:
		_held += delta
		if _held >= HOLD_TIME:
			_done = true
			solved.emit()
	else:
		_held = 0.0


func _distance() -> float:
	return absf(rad_to_deg(angle_difference(deg_to_rad(angle.value), deg_to_rad(TARGET_ANGLE))))
