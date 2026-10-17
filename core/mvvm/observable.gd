class_name Observable extends RefCounted
## Значение с уведомлением об изменении. Используется во ViewModel.

signal changed(new_value: Variant)

var value: Variant:
	set(v):
		if _value == v:
			return
		_value = v
		changed.emit(v)
	get:
		return _value

var _value: Variant


func _init(initial: Variant = null) -> void:
	_value = initial
