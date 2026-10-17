extends TestCase


func _tune(vm: MinigameRadioViewModel, freq: float) -> void:
	vm.set_angle(MinigameRadioViewModel.angle_for(freq))


func test_garble_clears_with_signal() -> void:
	var text := "Концерт по заявкам"
	check_eq(MinigameRadioViewModel.garble(text, 1.0), text, "полный сигнал — весь текст")
	check(MinigameRadioViewModel.garble(text, 0.2).contains("*"), "слабый сигнал — помехи")
	check_eq(MinigameRadioViewModel.garble(text, 0.5).length(), text.length(), "длина сохраняется")


func test_signal_peaks_at_station() -> void:
	var vm := MinigameRadioViewModel.new()
	_tune(vm, MinigameRadioViewModel.stations()[1].frequency)
	check(vm.strength.value > 0.99, "на станции сигнал полный")
	_tune(vm, 91.5)
	check_eq(vm.strength.value, 0.0, "между станциями тишина")
	check_eq(vm.heard_text.value, Texts.get_text("radio.noise"), "шум")


func test_needs_both_station_and_cassette() -> void:
	var vm := MinigameRadioViewModel.new()
	var solved := [false]
	vm.solved.connect(func() -> void: solved[0] = true)
	var target := MinigameRadioViewModel.stations()[MinigameRadioViewModel.TARGET_STATION].frequency
	_tune(vm, target)
	vm.submit()
	check(not solved[0], "без кассеты не решено")
	vm.insert_cassette(0)
	vm.submit()
	check(not solved[0], "не та кассета")
	vm.insert_cassette(MinigameRadioViewModel.TARGET_CASSETTE)
	_tune(vm, 93.4)
	vm.submit()
	check(not solved[0], "не та волна")
	_tune(vm, target + 0.1)
	vm.submit()
	check(solved[0], "волна и кассета верны")


func test_cassette_toggles() -> void:
	var vm := MinigameRadioViewModel.new()
	vm.insert_cassette(2)
	check_eq(vm.cassette.value, 2, "вставлена")
	vm.insert_cassette(2)
	check_eq(vm.cassette.value, -1, "вынута")


func test_news_names_target_frequency() -> void:
	var spelled := {"ru": "сто один и семь", "en": "one hundred one point seven"}
	for code in spelled:
		Texts.set_language(code)
		check(Texts.get_text("radio.news").contains(spelled[code]), "в новостях называют 101,7 (%s)" % code)
	Texts.set_language("ru")
	check_eq(MinigameRadioViewModel.stations()[MinigameRadioViewModel.TARGET_STATION].frequency, 101.7, "частота цели")
