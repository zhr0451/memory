class_name DialView extends Control
## Наборный диск. Палец — в отверстие, тянуть по часовой до упора и отпустить: диск возвращается со щелчками.
## Цифры под отверстиями почти стёрлись: видны только «1» и «0». Арт: mg_phone_plate.png и mg_phone_dial.png.

signal pulled(digit: int)
signal pulse(count: int)
signal returned

const SIZE := Vector2(520, 520)
const OUTER := 250.0
const HOLE_RING := 180.0
const HOLE_RADIUS := 30.0
const PULSE_TIME := 0.1
const PLATE_PATH := "res://features/minigame_phone/assets/mg_phone_plate.png"
const WHEEL_PATH := "res://features/minigame_phone/assets/mg_phone_dial.png"

## Поворот диска по часовой, градусы.
var wheel_rotation: float = 0.0:
	set(value):
		wheel_rotation = value
		queue_redraw()

var _digit: int = -1
var _last_angle: float = 0.0
var _busy: bool = false
var _plate: Texture2D
var _wheel: Texture2D


func _ready() -> void:
	size = SIZE
	custom_minimum_size = SIZE
	_plate = load(PLATE_PATH) if ResourceLoader.exists(PLATE_PATH) else null
	_wheel = load(WHEEL_PATH) if ResourceLoader.exists(WHEEL_PATH) else null


func _gui_input(event: InputEvent) -> void:
	var button := event as InputEventMouseButton
	if button == null or button.button_index != MOUSE_BUTTON_LEFT or _busy:
		return
	if button.pressed:
		_digit = _hole_at(button.position)
		_last_angle = _angle_of(button.position)
		mouse_default_cursor_shape = Control.CURSOR_DRAG if _digit >= 0 else Control.CURSOR_ARROW


func _input(event: InputEvent) -> void:
	if _digit < 0:
		return
	var motion := event as InputEventMouseMotion
	if motion != null:
		var angle := _angle_of(get_global_transform_with_canvas().affine_inverse() * motion.position)
		var delta := wrapf(angle - _last_angle, -180.0, 180.0)
		_last_angle = angle
		wheel_rotation = clampf(wheel_rotation + delta, 0.0, MinigamePhoneViewModel.pull_needed(_digit))
	var button := event as InputEventMouseButton
	if button != null and button.button_index == MOUSE_BUTTON_LEFT and not button.pressed:
		var digit := _digit
		_digit = -1
		if MinigamePhoneViewModel.reached_stop(digit, wheel_rotation):
			pulled.emit(digit)
			_return_home(MinigamePhoneViewModel.pulses_for(digit))
		else:
			_return_home(0)


## Диск сам возвращается в покой; при наборе каждый щелчок — сигнал pulse.
func _return_home(pulses: int) -> void:
	_busy = true
	if pulses == 0:
		var tween := create_tween()
		tween.tween_property(self, "wheel_rotation", 0.0, 0.25)
		await tween.finished
	else:
		var start := wheel_rotation
		for i in pulses:
			var tween := create_tween()
			tween.tween_property(self, "wheel_rotation", start * (1.0 - float(i + 1) / pulses), PULSE_TIME)
			await tween.finished
			pulse.emit(i + 1)
	wheel_rotation = 0.0
	_busy = false
	returned.emit()


func _hole_at(local: Vector2) -> int:
	for digit in 10:
		if local.distance_to(_hole_center(digit, wheel_rotation)) <= HOLE_RADIUS:
			return digit
	return -1


func _hole_center(digit: int, rotation_degrees: float) -> Vector2:
	var angle := deg_to_rad(MinigamePhoneViewModel.hole_angle(digit) + rotation_degrees)
	return SIZE * 0.5 + Vector2.from_angle(angle) * HOLE_RING


func _angle_of(local: Vector2) -> float:
	return rad_to_deg((local - SIZE * 0.5).angle())


func _draw() -> void:
	var center := SIZE * 0.5
	var font := ThemeDB.fallback_font
	if _plate != null:
		draw_texture_rect(_plate, Rect2(Vector2.ZERO, SIZE), false)
	else:
		draw_circle(center, OUTER, Color("e6dcc4"))
	if _wheel != null:
		_draw_digits(font)
		draw_set_transform(center, deg_to_rad(wheel_rotation))
		draw_texture(_wheel, -_wheel.get_size() * 0.5)
		draw_set_transform(Vector2.ZERO)
	else:
		draw_arc(center, HOLE_RING, 0.0, TAU, 96, Color(0.16, 0.17, 0.2, 0.92), HOLE_RADIUS * 2.6, true)
		for digit in 10:
			var hole := _hole_center(digit, wheel_rotation)
			draw_circle(hole, HOLE_RADIUS, Color("e6dcc4") if wheel_rotation < 0.5 else Color("8c836f"))
			draw_arc(hole, HOLE_RADIUS, 0.0, TAU, 32, Color("0c0d10"), 3.0, true)
		draw_circle(center, 92.0, Color("2a2c33"))
		draw_circle(center, 70.0, Color("e8e2d0"))
		if wheel_rotation < 0.5:
			_draw_digits(font)
	# Упор: металлический крючок у края диска.
	var stop := center + Vector2.from_angle(deg_to_rad(MinigamePhoneViewModel.STOP_ANGLE)) * (HOLE_RING + 8.0)
	var tip := center + Vector2.from_angle(deg_to_rad(MinigamePhoneViewModel.STOP_ANGLE)) * (HOLE_RING - 34.0)
	draw_line(stop, tip, Color("c8ccd4"), 12.0, true)
	draw_circle(stop, 10.0, Color("9aa0ab"))


## Цифры на пластине под отверстиями: стёрлись все, кроме «1» и «0».
func _draw_digits(font: Font) -> void:
	for digit in 10:
		var pos := _hole_center(digit, 0.0)
		if digit == 1 or digit == 0:
			draw_string(font, pos + Vector2(-14, 12), str(digit), HORIZONTAL_ALIGNMENT_CENTER, 28, 34, Color(0.25, 0.2, 0.15, 0.9))
		else:
			# От цифры остались только потёртости.
			draw_line(pos + Vector2(-8, -6), pos + Vector2(6, -2), Color(0.45, 0.4, 0.32, 0.35), 3.0, true)
			draw_line(pos + Vector2(-4, 6), pos + Vector2(8, 4), Color(0.45, 0.4, 0.32, 0.25), 2.0, true)
