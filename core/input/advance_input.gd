class_name AdvanceInput extends RefCounted
## Единая клавиша для реплик, воспоминаний и титров: только пробел.


static func is_advance(event: InputEvent) -> bool:
	var key := event as InputEventKey
	return key != null and key.pressed and not key.echo and key.keycode == KEY_SPACE
