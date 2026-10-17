class_name MinigameTapeViewModel extends ViewModel
## Плеер: перемотка и Play, на плёнке 3 фрагмента. Решено, когда все прослушаны.

signal solved

enum Mode { STOP, PLAY, REWIND, FORWARD }

## Фрагменты плёнки: [начало, конец] в долях длины.
const FRAGMENTS: Array[Vector2] = [Vector2(0.10, 0.15), Vector2(0.45, 0.50), Vector2(0.80, 0.85)]
const FRAGMENT_KEYS: Array[String] = ["tape.1", "tape.2", "tape.3"]
const PLAY_SPEED := 0.02
const WIND_SPEED := 0.25
const HEARD_SHARE := 0.8

var position := Observable.new(0.3)
var mode := Observable.new(Mode.STOP)
var heard_count := Observable.new(0)
var subtitle := Observable.new("")

var _play_time: Array[float] = [0.0, 0.0, 0.0]
var _heard: Array[bool] = [false, false, false]


func set_mode(new_mode: Mode) -> void:
	mode.value = new_mode
	if new_mode != Mode.PLAY:
		subtitle.value = "" if new_mode == Mode.STOP else Texts.get_text("tape.noise")


func toggle_play() -> void:
	set_mode(Mode.STOP if mode.value == Mode.PLAY else Mode.PLAY)


func is_heard(index: int) -> bool:
	return _heard[index]


func tick(delta: float) -> void:
	match mode.value:
		Mode.REWIND:
			_move(-WIND_SPEED * delta)
		Mode.FORWARD:
			_move(WIND_SPEED * delta)
		Mode.PLAY:
			_move(PLAY_SPEED * delta)
			_listen(delta)


func _move(amount: float) -> void:
	position.value = clampf(position.value + amount, 0.0, 1.0)
	if (position.value <= 0.0 and amount < 0.0) or (position.value >= 1.0 and amount > 0.0):
		set_mode(Mode.STOP)


func _listen(delta: float) -> void:
	var index := _fragment_at(position.value)
	if index < 0:
		subtitle.value = ""
		return
	subtitle.value = Texts.get_text(FRAGMENT_KEYS[index])
	_play_time[index] += delta
	var length := (FRAGMENTS[index].y - FRAGMENTS[index].x) / PLAY_SPEED
	if not _heard[index] and _play_time[index] >= length * HEARD_SHARE:
		_heard[index] = true
		heard_count.value += 1
		if heard_count.value == FRAGMENTS.size():
			solved.emit()


func _fragment_at(pos: float) -> int:
	for i in FRAGMENTS.size():
		if pos >= FRAGMENTS[i].x and pos <= FRAGMENTS[i].y:
			return i
	return -1
