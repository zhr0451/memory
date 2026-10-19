extends TestCase


func _tune(vm: MinigameRadioViewModel, freq: float) -> void:
	vm.set_angle(MinigameRadioViewModel.angle_for(freq))


func test_garble_clears_with_signal() -> void:
	var text := "Концерт по заявкам"
	check_eq(MinigameRadioViewModel.garble(text, 1.0), text, "полный сигнал — весь текст")
	check(not MinigameRadioViewModel.garble(text, 0.2).contains("*"), "звёздочек нет")
	check(MinigameRadioViewModel.garble(text, 0.2) != text, "слабый сигнал — помехи")
	check_eq(MinigameRadioViewModel.garble(text, 0.5).length(), text.length(), "длина сохраняется")


func test_signal_peaks_at_station() -> void:
	var vm := MinigameRadioViewModel.new()
	_tune(vm, MinigameRadioViewModel.stations()[1].frequency)
	check(vm.strength.value > 0.99, "на станции сигнал полный")
	_tune(vm, 91.5)
	check_eq(vm.strength.value, 0.0, "между станциями тишина")
	check_eq(vm.heard_text.value, "", "нет сигнала — нет текста")


func test_needs_both_station_and_cassette() -> void:
	var vm := MinigameRadioViewModel.new()
	var verdicts: Array = []
	vm.submitted.connect(func(v: MinigameRadioViewModel.Verdict) -> void: verdicts.append(v))
	var target := MinigameRadioViewModel.stations()[MinigameRadioViewModel.TARGET_STATION].frequency
	vm.submit()
	_tune(vm, target)
	vm.submit()
	vm.insert_cassette(0)
	vm.submit()
	vm.insert_cassette(MinigameRadioViewModel.TARGET_CASSETTE)
	_tune(vm, 93.4)
	vm.submit()
	check(not vm.is_solved(), "пока не решено")
	_tune(vm, target + 0.1)
	vm.submit()
	check(vm.is_solved(), "волна и кассета верны")
	var V := MinigameRadioViewModel.Verdict
	check_eq(verdicts, [V.WRONG_STATION, V.NO_CASSETTE, V.WRONG_CASSETTE, V.WRONG_STATION, V.RIGHT], "вердикт говорит, что не так")


func test_release_snaps_to_nearby_station() -> void:
	var vm := MinigameRadioViewModel.new()
	_tune(vm, 101.2)
	check(not vm.is_locked(), "мимо станции")
	check(vm.strength.value < 0.99, "текст с помехами")
	vm.release()
	check(is_equal_approx(vm.frequency.value, 101.7), "автоподстройка поймала 101,7")
	check(vm.is_locked(), "станция поймана")
	check_eq(MinigameRadioViewModel.garble(Texts.get_text("radio.request"), vm.strength.value), Texts.get_text("radio.request"), "просьба ведущего читается целиком")
	_tune(vm, 91.5)
	vm.release()
	check(is_equal_approx(vm.frequency.value, 91.5), "далеко от станций — не прыгает")


func test_every_verdict_has_text() -> void:
	for key in MinigameRadioViewModel.VERDICT_KEYS.values():
		check(Texts.has_key(key), "текст вердикта " + key)


func test_locked_after_solve() -> void:
	var vm := MinigameRadioViewModel.new()
	var solved := [0]
	vm.solved.connect(func() -> void: solved[0] += 1)
	_tune(vm, 101.7)
	vm.insert_cassette(MinigameRadioViewModel.TARGET_CASSETTE)
	vm.submit()
	_tune(vm, 90.0)
	vm.insert_cassette(0)
	vm.submit()
	check_eq(solved[0], 1, "решено один раз")
	check(is_equal_approx(vm.frequency.value, 101.7), "ручка больше не крутится")
	check_eq(vm.cassette.value, MinigameRadioViewModel.TARGET_CASSETTE, "кассета на месте")


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


func test_nudge_steps_by_tenth_and_clamps() -> void:
	var vm := MinigameRadioViewModel.new()
	vm.set_angle(MinigameRadioViewModel.angle_for(101.63))
	vm.nudge(1)
	check(is_equal_approx(vm.frequency.value, 101.7), "шаг вверх к сетке 0,1")
	vm.nudge(-1)
	vm.nudge(-1)
	check(is_equal_approx(vm.frequency.value, 101.5), "два шага вниз")
	vm.set_angle(MinigameRadioViewModel.angle_for(MinigameRadioViewModel.MIN_FREQUENCY))
	vm.nudge(-1)
	check(vm.frequency.value >= MinigameRadioViewModel.MIN_FREQUENCY, "не ниже шкалы")
