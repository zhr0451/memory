class_name JunkyardViewModel extends ViewModel
## Свалка: какие предметы закрыты, доступны или уже оживлены.

signal chapter_selected(index: int)
signal note_found

enum ItemState { LOCKED, AVAILABLE, DONE }

var chapters_done: Observable
var clock_note_found: Observable

var _state: GameState


func _init(state: GameState) -> void:
	_state = state
	chapters_done = state.chapters_done
	clock_note_found = state.clock_note_found


func item_state(index: int) -> ItemState:
	if index < _state.chapters_done.value:
		return ItemState.DONE
	if _state.is_item_available(index):
		return ItemState.AVAILABLE
	return ItemState.LOCKED


## Клик по предмету. Возвращает true, если выбор принят.
func select(index: int) -> bool:
	if item_state(index) != ItemState.AVAILABLE:
		return false
	chapter_selected.emit(index)
	return true


## Клик по спрятанной записке: герой поднимает её, и в мини-игре «будильник» она упадёт к часам.
func find_note() -> void:
	if _state.clock_note_found.value:
		return
	_state.clock_note_found.value = true
	_state.say("junk.note.found")
	note_found.emit()

