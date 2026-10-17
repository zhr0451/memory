extends SceneTree
## Запуск: godot --headless --path . -s tests/test_runner.gd
## Ищет *_test.gd в core/ и features/, вызывает методы test_*.

const ROOTS: Array[String] = ["res://core", "res://features"]


func _init() -> void:
	var total := 0
	var failed := 0
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
				suite.call(method_name)
				total += 1
				if suite.failures.is_empty():
					print("  ok   %s :: %s" % [path.get_file(), method_name])
				else:
					failed += 1
					print("  FAIL %s :: %s" % [path.get_file(), method_name])
					for message in suite.failures:
						print("       - " + message)
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
