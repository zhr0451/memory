class_name TestCase extends RefCounted
## Основа тестов. Методы test_* запускает tests/test_runner.gd.

var failures: Array[String] = []


func check(condition: bool, message: String = "") -> void:
	if not condition:
		failures.append(message if message != "" else "условие ложно")


func check_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if actual != expected:
		failures.append("%s: ожидалось %s, получено %s" % [message, str(expected), str(actual)])
