extends TestCase


func test_choose_switches_language_and_shows_hud() -> void:
	Settings.path = "user://test_settings.cfg"
	var state := GameState.new()
	var vm := LanguageSelectViewModel.new(state)
	var chosen: Array[String] = []
	vm.chosen.connect(func(code: String) -> void: chosen.append(code))
	check(not state.hud_visible.value, "HUD скрыт до выбора")
	vm.choose("en")
	check_eq(Texts.language, "en", "язык переключён")
	check_eq(chosen, ["en"] as Array[String], "сигнал chosen")
	check(state.hud_visible.value, "HUD показан после выбора")
	vm.choose("ru")
	check_eq(vm.selected.value, "ru", "выбор запомнен")
