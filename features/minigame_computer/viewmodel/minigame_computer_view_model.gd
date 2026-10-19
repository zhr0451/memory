class_name MinigameComputerViewModel extends ViewModel
## Старый компьютер: включить системный блок и монитор, вставить найденную на свалке дискету, ввести пароль.
## Подсказка к паролю — «мой лучший друг»; ответ — имя героя (Пип), которое игрок слышал в главе 1.

signal submitted(correct: bool)
signal solved

## Что показывает монитор; выводится из выключателей, дискеты и пароля.
enum Screen { OFF, NO_SIGNAL, NO_DISK, PASSWORD, DESKTOP }

const MAX_PASSWORD := 12
## Клавиатура: [латиница, кириллица] на одной клавише, как на настоящих клавиатурах.
const ROWS: Array = [
	[["Q", "Й"], ["W", "Ц"], ["E", "У"], ["R", "К"], ["T", "Е"], ["Y", "Н"], ["U", "Г"], ["I", "Ш"], ["O", "Щ"], ["P", "З"], ["[", "Х"], ["]", "Ъ"]],
	[["A", "Ф"], ["S", "Ы"], ["D", "В"], ["F", "А"], ["G", "П"], ["H", "Р"], ["J", "О"], ["K", "Л"], ["L", "Д"], [";", "Ж"], ["'", "Э"]],
	[["Z", "Я"], ["X", "Ч"], ["C", "С"], ["V", "М"], ["B", "И"], ["N", "Т"], ["M", "Ь"], [",", "Б"], [".", "Ю"]],
]

var pc_on := Observable.new(false)
var monitor_on := Observable.new(false)
var floppy_in := Observable.new(false)
var password := Observable.new("")
var screen := Observable.new(Screen.OFF)
var wrong_attempts: int = 0

var _cyrillic: bool
var _answer: String
var _state: GameState
var _done: bool = false
var _hinted_floppy: bool = false
var _hinted_friend: bool = false


## cyrillic — какой алфавит печатает клавиатура (по языку игры); answer — пароль (ключ computer.password).
func _init(state: GameState = null, cyrillic: bool = true, answer: String = "") -> void:
	_state = state
	_cyrillic = cyrillic
	_answer = answer.to_upper()


## Дискету нашли на свалке (без состояния — считаем, что нашли).
func floppy_available() -> bool:
	return _state == null or _state.floppy_found.value


static func key_label(row: int, column: int) -> String:
	var key: Array = ROWS[row][column]
	return "%s %s" % [key[0], key[1]]


func key_char(row: int, column: int) -> String:
	return ROWS[row][column][1 if _cyrillic else 0]


func toggle_pc() -> void:
	pc_on.value = not pc_on.value
	if not pc_on.value:
		password.value = ""
	_update_screen()


func toggle_monitor() -> void:
	monitor_on.value = not monitor_on.value
	_update_screen()


func insert_floppy() -> void:
	if floppy_in.value or not floppy_available():
		return
	floppy_in.value = true
	_update_screen()


func press_key(row: int, column: int) -> void:
	if screen.value != Screen.PASSWORD or password.value.length() >= MAX_PASSWORD:
		return
	password.value += key_char(row, column)


func backspace() -> void:
	if screen.value == Screen.PASSWORD:
		password.value = password.value.left(-1)


## Enter: вердикт по паролю. Пустой ввод не считается; неверный пароль — ошибка.
func enter() -> void:
	if screen.value != Screen.PASSWORD or password.value == "":
		return
	var ok: bool = password.value == _answer
	submitted.emit(ok)
	if not ok:
		wrong_attempts += 1
		password.value = ""
		if _state != null:
			_state.mistake()
		if wrong_attempts == 1:
			_say("computer.remember")
		return
	if not _done:
		_done = true
		_update_screen()
		if _state != null:
			_state.emotion.value = Emotion.Kind.FEAR
		solved.emit()


func is_solved() -> bool:
	return _done


func _update_screen() -> void:
	var next := _compute_screen()
	if next == screen.value:
		return
	screen.value = next
	if next == Screen.NO_DISK and not floppy_available() and not _hinted_floppy:
		_hinted_floppy = true
		_say("computer.confused")
	elif next == Screen.PASSWORD and not _hinted_friend:
		_hinted_friend = true
		_say("computer.friend")


func _compute_screen() -> Screen:
	if not monitor_on.value:
		return Screen.OFF
	if not pc_on.value:
		return Screen.NO_SIGNAL
	if not floppy_in.value:
		return Screen.NO_DISK
	return Screen.DESKTOP if _done else Screen.PASSWORD


func _say(key: String) -> void:
	if _state != null:
		_state.say(key)
