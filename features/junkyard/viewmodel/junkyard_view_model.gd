class_name JunkyardViewModel extends ViewModel
## Свалка: какие предметы закрыты, доступны или уже оживлены.

signal chapter_selected(index: int)

enum ItemState { LOCKED, AVAILABLE, DONE }

var chapters_done: Observable

var _state: GameState


func _init(state: GameState) -> void:
	_state = state
	chapters_done = state.chapters_done


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
