class_name JunkyardViewModel extends ViewModel
## Свалка: какие предметы закрыты, доступны или уже оживлены; спрятанные подсказки к мини-играм;
## сканер, который на время импульса проявляет доступный предмет и подсказку к нему.

signal item_selected(index: int)
signal clue_found(clue: Clue)
## Импульс сканера пошёл; index — предмет, который он проявит (-1, если доступных нет).
signal scan_started(index: int)

enum ItemState { LOCKED, AVAILABLE, DONE }
## Спрятанные подсказки: записка — к будильнику, дискета — к компьютеру, рисунок на холодильнике — к телефону.
enum Clue { NOTE, FLOPPY, FRIDGE }

const CLUE_LINES: Dictionary = {
	Clue.NOTE: "junk.note.found",
	Clue.FLOPPY: "junk.floppy.found",
	Clue.FRIDGE: "junk.fridge.found",
}
## К какому предмету подсказка: сканер проявляет её вместе с этим предметом.
const CLUE_ITEMS: Dictionary = {
	Clue.NOTE: &"clock",
	Clue.FLOPPY: &"computer",
	Clue.FRIDGE: &"phone",
}

var items_done: Observable
## Идёт импульс сканера.
var scanning := Observable.new(false)

var _state: GameState


func _init(state: GameState) -> void:
	_state = state
	items_done = state.items_done


func item_state(index: int) -> ItemState:
	if index < _state.items_done.value:
		return ItemState.DONE
	if _state.is_item_available(index):
		return ItemState.AVAILABLE
	return ItemState.LOCKED


## Клик по предмету. Возвращает true, если выбор принят.
func select(index: int) -> bool:
	if item_state(index) != ItemState.AVAILABLE:
		return false
	item_selected.emit(index)
	return true


## Кнопка сканера. Импульс стоит ½ деления; повторно во время импульса не включается.
func scan() -> bool:
	if scanning.value or not _state.spend_scan():
		return false
	scanning.value = true
	if not _state.scanner_used.value:
		_state.scanner_used.value = true
		_state.say("scan.first")
	scan_started.emit(available_index())
	return true


## Ненайденная подсказка к предмету index (её покажет сканер) или -1.
func clue_for(index: int) -> int:
	if index < 0:
		return -1
	var id := Story.item(index).id
	for clue: Clue in CLUE_ITEMS:
		if CLUE_ITEMS[clue] == id and not is_clue_found(clue):
			return clue
	return -1


## View сообщает, что импульс погас.
func end_scan() -> void:
	scanning.value = false


## Предмет, который сейчас можно оживить, или -1.
func available_index() -> int:
	for i in Story.item_count():
		if item_state(i) == ItemState.AVAILABLE:
			return i
	return -1


func is_clue_found(clue: Clue) -> bool:
	return _flag(clue).value


## Клик по спрятанной подсказке: герой подбирает её, и она появится в своей мини-игре.
func find_clue(clue: Clue) -> void:
	var flag := _flag(clue)
	if flag.value:
		return
	flag.value = true
	_state.say(CLUE_LINES[clue])
	clue_found.emit(clue)


func _flag(clue: Clue) -> Observable:
	match clue:
		Clue.FLOPPY:
			return _state.floppy_found
		Clue.FRIDGE:
			return _state.phone_note_found
		_:
			return _state.clock_note_found
