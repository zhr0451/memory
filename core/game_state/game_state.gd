class_name GameState extends RefCounted
## Состояние прохождения: пройденные предметы и главы, лицо, батарейка и очередь реплик героя.
## Заряд считается в половинках деления: глава садит на ½, ошибка в мини-игре — на целое деление.
## Заряд кончился от ошибки — проигрыш, глава начинается заново с тем зарядом, что был в её начале.

signal lines_drained
## Ошибка посадила батарейку в ноль.
signal battery_dead

const MAX_BATTERY := 4
const CHARGE_PER_BAR := 2
const MAX_CHARGE := MAX_BATTERY * CHARGE_PER_BAR
const CHAPTER_COST := 1
const MISTAKE_COST := 2
## Сканер на свалке: −½ деления за импульс; последнюю половинку на него не тратим.
const SCAN_COST := 1

var items_done := Observable.new(0)
var chapters_done := Observable.new(0)
var emotion := Observable.new(Emotion.Kind.OFF)
## Заряд в половинках деления: 0…MAX_CHARGE.
var charge := Observable.new(MAX_CHARGE)
var face_on := Observable.new(false)
var hud_visible := Observable.new(false)
var clock_note_found := Observable.new(false)
var floppy_found := Observable.new(false)
var phone_note_found := Observable.new(false)
## Сканер уже доставали хотя бы раз (реплика героя — только в первый).
var scanner_used := Observable.new(false)
var current_line := Observable.new("")

var _queue: Array[String] = []
## Точка перезапуска — начало текущей главы.
var _checkpoint_items: int = 0
var _checkpoint_chapters: int = 0
var _checkpoint_charge: int = MAX_CHARGE
var _checkpoint_emotion: Emotion.Kind = Emotion.Kind.JOY


## Предмет доступен, только если он следующий по сюжету.
func is_item_available(index: int) -> bool:
	return index == items_done.value


## Предмет пройден; если он закрывает главу — батарейка садится на ½ деления (но не до нуля:
## за успех не проигрывают) и запоминается точка перезапуска.
func complete_item(ends_chapter: bool) -> void:
	items_done.value += 1
	if ends_chapter:
		chapters_done.value += 1
		charge.value = maxi(1, charge.value - CHAPTER_COST)
		save_checkpoint()


## Ошибка в мини-игре: минус деление. В ноль — battery_dead.
func mistake() -> void:
	if charge.value <= 0:
		return
	charge.value = maxi(0, charge.value - MISTAKE_COST)
	if charge.value == 0:
		battery_dead.emit()
	elif charge.value <= MISTAKE_COST:
		say("battery.low")


## Импульс сканера: минус ½ деления. Если останется ноль — сканер не включается (сканом не проигрывают).
func spend_scan() -> bool:
	if charge.value <= SCAN_COST:
		say("scan.low")
		return false
	charge.value -= SCAN_COST
	return true


func is_dead() -> bool:
	return charge.value <= 0


## Запомнить начало главы; эмоция — та, с которой глава начинается.
func save_checkpoint() -> void:
	_checkpoint_items = items_done.value
	_checkpoint_chapters = chapters_done.value
	_checkpoint_charge = charge.value
	_checkpoint_emotion = emotion.value


## После проигрыша: вернуть главу к началу. Найденные подсказки остаются найденными.
func restart_chapter() -> void:
	_queue.clear()
	current_line.value = ""
	items_done.value = _checkpoint_items
	chapters_done.value = _checkpoint_chapters
	charge.value = _checkpoint_charge
	emotion.value = _checkpoint_emotion
	face_on.value = true
	hud_visible.value = true


## Реплика героя по ключу текста; печатается по очереди.
func say(key: String) -> void:
	_queue.append(Texts.get_text(key))
	if current_line.value == "":
		_next_line()


## View сообщает, что текущая реплика показана.
func finish_line() -> void:
	_next_line()


func reset() -> void:
	_queue.clear()
	items_done.value = 0
	chapters_done.value = 0
	emotion.value = Emotion.Kind.OFF
	charge.value = MAX_CHARGE
	face_on.value = false
	hud_visible.value = false
	clock_note_found.value = false
	floppy_found.value = false
	phone_note_found.value = false
	scanner_used.value = false
	current_line.value = ""
	save_checkpoint()
	_checkpoint_emotion = Emotion.Kind.JOY


func _next_line() -> void:
	if _queue.is_empty():
		current_line.value = ""
		lines_drained.emit()
	else:
		current_line.value = _queue.pop_front()
