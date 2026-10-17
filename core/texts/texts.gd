class_name Texts extends RefCounted
## Все тексты игры лежат в texts_ru.json; в коде только ключи.

const PATH := "res://core/texts/texts_ru.json"

static var _data: Dictionary = {}
static var _loaded: bool = false


static func get_text(key: String) -> String:
	_ensure_loaded()
	if not _data.has(key):
		push_warning("Texts: нет ключа '%s'" % key)
		return "[%s]" % key
	return str(_data[key])


static func has_key(key: String) -> bool:
	_ensure_loaded()
	return _data.has(key)


static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	var file := FileAccess.open(PATH, FileAccess.READ)
	if file == null:
		push_error("Texts: не открыть %s" % PATH)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_data = parsed
	else:
		push_error("Texts: %s — не словарь" % PATH)
