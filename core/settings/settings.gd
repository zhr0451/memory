class_name Settings extends RefCounted
## Настройки игрока в user://settings.cfg (в вебе — в хранилище браузера).

static var path: String = "user://settings.cfg"
const SECTION := "game"


## Сохранённый язык; если его нет — язык системы (ru или en).
static func load_language(supported: Array[String]) -> String:
	var config := ConfigFile.new()
	if config.load(path) == OK:
		var saved: String = config.get_value(SECTION, "language", "")
		if supported.has(saved):
			return saved
	var system := OS.get_locale_language()
	return system if supported.has(system) else "en"


static func save_language(code: String) -> void:
	var config := ConfigFile.new()
	config.load(path)
	config.set_value(SECTION, "language", code)
	config.save(path)
