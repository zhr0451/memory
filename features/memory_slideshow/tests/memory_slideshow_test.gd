extends TestCase


func test_frames_advance_then_finish() -> void:
	var state := GameState.new()
	var vm := MemorySlideshowViewModel.new(state, 2)
	var finished := [0]
	vm.finished.connect(func() -> void: finished[0] += 1)
	vm.activate()
	check_eq(state.emotion.value, Emotion.Kind.MEMORY, "эмоция")
	vm.next()
	check_eq(vm.frame_index.value, 1, "второй кадр")
	vm.next()
	vm.next()
	check_eq(finished[0], 1, "finished один раз")


func test_last_day_uses_extra_frames() -> void:
	var vm := MemorySlideshowViewModel.new(GameState.new(), Story.chapter_count())
	check_eq(vm.frames.size(), Story.LAST_DAY_FRAMES.size(), "кадры последнего дня")
