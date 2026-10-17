extends TestCase


func _listen(vm: MinigameTapeViewModel, index: int) -> void:
	vm.set_mode(MinigameTapeViewModel.Mode.STOP)
	vm.position.value = MinigameTapeViewModel.FRAGMENTS[index].x
	vm.set_mode(MinigameTapeViewModel.Mode.PLAY)
	for i in 300:
		vm.tick(0.01)


func test_solves_after_three_fragments() -> void:
	var vm := MinigameTapeViewModel.new()
	var solved := [false]
	vm.solved.connect(func() -> void: solved[0] = true)
	_listen(vm, 0)
	_listen(vm, 1)
	check(not solved[0], "ещё не всё")
	_listen(vm, 2)
	check_eq(vm.heard_count.value, 3, "услышано")
	check(solved[0], "решено")


func test_rewind_stops_at_start() -> void:
	var vm := MinigameTapeViewModel.new()
	vm.set_mode(MinigameTapeViewModel.Mode.REWIND)
	for i in 100:
		vm.tick(0.1)
	check_eq(vm.position.value, 0.0, "начало")
	check_eq(vm.mode.value, MinigameTapeViewModel.Mode.STOP, "авто-стоп")


func test_skipping_through_does_not_count() -> void:
	var vm := MinigameTapeViewModel.new()
	vm.set_mode(MinigameTapeViewModel.Mode.FORWARD)
	for i in 100:
		vm.tick(0.05)
	check_eq(vm.heard_count.value, 0, "перемотка не слушает")
