extends SceneTree
## Запуск: godot --headless --path . -s tests/test_runner.gd
## Ищет *_test.gd в core/ и features/, вызывает методы test_*.

const ROOTS: Array[String] = ["res://core", "res://features"]


## Собирает ошибки движка (SCRIPT ERROR, push_error и т.п.), пока идёт тест:
## упавший с ошибкой тест иначе выглядел бы как «ok».
class ErrorCollector extends Logger:
	var errors: Array[String] = []
	var _mutex := Mutex.new()

	func _log_error(function: String, file: String, line: int, code: String, rationale: String,
			_editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
		if error_type == ERROR_TYPE_WARNING:
			return
		var text := rationale if not rationale.is_empty() else code
		_mutex.lock()
		errors.append("%s (%s:%d, %s)" % [text, file.get_file(), line, function])
		_mutex.unlock()

	func take() -> Array[String]:
		_mutex.lock()
		var result := errors.duplicate()
		errors.clear()
		_mutex.unlock()
		return result


func _init() -> void:
	var total := 0
	var failed := 0
	var collector := ErrorCollector.new()
	OS.add_logger(collector)
	for root in ROOTS:
		for path in _find_tests(root):
			var script := load(path) as GDScript
			if script == null or not script.can_instantiate():
				total += 1
				failed += 1
				print("  FAIL %s :: не загрузился (ошибка разбора)" % path.get_file())
				continue
			var suite := script.new() as TestCase
			for method in suite.get_method_list():
				var method_name: String = method["name"]
				if not method_name.begins_with("test_"):
					continue
				suite.failures.clear()
				collector.take()
				suite.call(method_name)
				for error in collector.take():
					suite.failures.append("ошибка движка: " + error)
				total += 1
				if suite.failures.is_empty():
					print("  ok   %s :: %s" % [path.get_file(), method_name])
				else:
					failed += 1
					print("  FAIL %s :: %s" % [path.get_file(), method_name])
					for message in suite.failures:
						print("       - " + message)
	OS.remove_logger(collector)
	print("Тестов: %d, провалено: %d" % [total, failed])
	quit(1 if failed > 0 else 0)


func _find_tests(dir_path: String) -> Array[String]:
	var found: Array[String] = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return found
	for entry in dir.get_directories():
		found.append_array(_find_tests(dir_path.path_join(entry)))
	for file in dir.get_files():
		if file.ends_with("_test.gd"):
			found.append(dir_path.path_join(file))
	return found
