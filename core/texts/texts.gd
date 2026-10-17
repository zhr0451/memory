class_name Texts extends RefCounted
## Все тексты игры лежат в texts_<язык>.json; в коде только ключи.
## Русский — основной язык: если в другом языке нет ключа, берётся русский текст.

const LANGUAGES: Array[String] = ["ru", "en"]
const FALLBACK := "ru"

static var language: String = ""
static var _data: Dictionary = {}
static var _fallback: Dictionary = {}


static func get_text(key: String) -> String:
	_ensure_loaded()
	if _data.has(key):
		return str(_data[key])
	if _fallback.has(key):
		return str(_fallback[key])
	push_warning("Texts: нет ключа '%s'" % key)
	return "[%s]" % key


static func has_key(key: String) -> bool:
	_ensure_loaded()
	return _data.has(key) or _fallback.has(key)


## Переключает язык; сохранять выбор — дело вызывающего (см. Settings).
static func set_language(code: String) -> void:
	if not LANGUAGES.has(code):
		push_error("Texts: неизвестный язык '%s'" % code)
		return
	language = code
	_data = _load(code)
	_fallback = _data if code == FALLBACK else _load(FALLBACK)


static func keys_of(code: String) -> Array:
	return _load(code).keys()


static func path_for(code: String) -> String:
	return "res://core/texts/texts_%s.json" % code


static func _ensure_loaded() -> void:
	if language == "":
		set_language(Settings.load_language(LANGUAGES))


static func _load(code: String) -> Dictionary:
	var file := FileAccess.open(path_for(code), FileAccess.READ)
	if file == null:
		push_error("Texts: не открыть %s" % path_for(code))
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	push_error("Texts: %s — не словарь" % path_for(code))
	return {}
