class_name RadioStation extends RefCounted
## Станция на шкале: частота и ключ текста передачи.

var frequency: float
var text_key: String
## Сколько периодов синусоиды рисуется на экране, когда станция поймана.
var wave_cycles: float


static func create(p_frequency: float, p_text_key: String, p_wave_cycles: float) -> RadioStation:
	var station := RadioStation.new()
	station.frequency = p_frequency
	station.text_key = p_text_key
	station.wave_cycles = p_wave_cycles
	return station
