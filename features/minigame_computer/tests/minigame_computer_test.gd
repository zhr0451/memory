extends TestCase

const Screen := MinigameComputerViewModel.Screen


func _vm(state: GameState = null, cyrillic: bool = true) -> MinigameComputerViewModel:
	return MinigameComputerViewModel.new(state, cyrillic, "ПИП" if cyrillic else "PIP")


## Координаты клавиши по символу.
func _key(vm: MinigameComputerViewModel, ch: String) -> Vector2i:
	for row in MinigameComputerViewModel.ROWS.size():
		for column in (MinigameComputerViewModel.ROWS[row] as Array).size():
			if vm.key_char(row, column) == ch:
				return Vector2i(row, column)
	return Vector2i(-1, -1)


func _type(vm: MinigameComputerViewModel, text: String) -> void:
	for ch in text:
		var key := _key(vm, ch)
		vm.press_key(key.x, key.y)


func _boot(vm: MinigameComputerViewModel) -> void:
	vm.toggle_monitor()
	vm.toggle_pc()
	vm.insert_floppy()


func test_screen_follows_switches_and_floppy() -> void:
	var vm := _vm()
	check_eq(vm.screen.value, Screen.OFF, "всё выключено")
	vm.toggle_pc()
	check_eq(vm.screen.value, Screen.OFF, "монитор выключен")
	vm.toggle_monitor()
	check_eq(vm.screen.value, Screen.NO_DISK, "нет дискеты")
	vm.toggle_pc()
	check_eq(vm.screen.value, Screen.NO_SIGNAL, "блок выключен")
	vm.toggle_pc()
	vm.insert_floppy()
	check_eq(vm.screen.value, Screen.PASSWORD, "загрузилась")


func test_correct_password_solves_on_enter() -> void:
	var vm := _vm()
	var solved := [0]
	vm.solved.connect(func() -> void: solved[0] += 1)
	_boot(vm)
	_type(vm, "ПИП")
	check_eq(vm.password.value, "ПИП", "набрано")
	check_eq(solved[0], 0, "нужен Enter")
	vm.enter()
	check_eq(solved[0], 1, "решено")
	check_eq(vm.screen.value, Screen.DESKTOP, "рабочий стол")
	vm.enter()
	check_eq(solved[0], 1, "один раз")


func test_english_layout_types_latin() -> void:
	var vm := _vm(null, false)
	_boot(vm)
	_type(vm, "PIP")
	vm.enter()
	check(vm.is_solved(), "PIP на английском")


func test_same_keys_for_both_languages() -> void:
	var ru := _vm()
	var en := _vm(null, false)
	check_eq(_key(ru, "П"), _key(en, "G"), "П и G на одной клавише")


func test_wrong_password_clears_and_hints_once() -> void:
	var state := GameState.new()
	state.floppy_found.value = true
	var vm := _vm(state)
	var verdicts: Array = []
	vm.submitted.connect(func(ok: bool) -> void: verdicts.append(ok))
	_boot(vm)
	state.finish_line()
	_type(vm, "МИША")
	vm.enter()
	check_eq(verdicts, [false], "вердикт «неверно»")
	check_eq(vm.password.value, "", "поле очищено")
	check_eq(state.current_line.value, Texts.get_text("computer.remember"), "герой вспоминает имя")
	state.finish_line()
	vm.enter()
	check_eq(state.current_line.value, "", "подсказка не повторяется")
	check(not vm.is_solved(), "не решено")


func test_typing_only_on_password_screen() -> void:
	var vm := _vm()
	_type(vm, "П")
	check_eq(vm.password.value, "", "компьютер выключен")
	_boot(vm)
	for i in MinigameComputerViewModel.MAX_PASSWORD + 3:
		vm.press_key(0, 0)
	check_eq(vm.password.value.length(), MinigameComputerViewModel.MAX_PASSWORD, "длина ограничена")
	vm.backspace()
	check_eq(vm.password.value.length(), MinigameComputerViewModel.MAX_PASSWORD - 1, "стирание")


func test_floppy_needs_to_be_found() -> void:
	var state := GameState.new()
	var vm := _vm(state)
	check(not vm.floppy_available(), "дискеты нет")
	vm.toggle_monitor()
	vm.toggle_pc()
	check_eq(state.current_line.value, Texts.get_text("computer.confused"), "герой просит дискету")
	vm.insert_floppy()
	check(not vm.floppy_in.value, "без находки не вставить")
	state.floppy_found.value = true
	vm.insert_floppy()
	check_eq(vm.screen.value, Screen.PASSWORD, "после находки загрузилась")


func test_password_answer_is_localized() -> void:
	Texts.set_language("en")
	var en := Texts.get_text("computer.password")
	Texts.set_language("ru")
	check_eq(Texts.get_text("computer.password"), "ПИП", "русский пароль")
	check_eq(en, "PIP", "английский пароль")
