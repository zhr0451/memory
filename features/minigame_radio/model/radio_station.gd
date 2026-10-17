class_name RadioStation extends RefCounted
## Станция на шкале: частота и ключ текста передачи.

var frequency: float
var text_key: String


static func create(p_frequency: float, p_text_key: String) -> RadioStation:
	var station := RadioStation.new()
	station.frequency = p_frequency
	station.text_key = p_text_key
	return station
