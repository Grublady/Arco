class_name EventfulAudioStreamPlayer extends AudioStreamPlayer

@export_multiline var events_string: String:
	set(new_value):
		events_string = new_value
		var new_events: Array[AudioEvent] = []
		var lines := events_string.split("\n")
		for line in lines:
			var components := line.split(":")
			if components.size() < 2:
				continue
			var event := AudioEvent.new()
			event.time = float(components[0])
			event.id = components[1]
			new_events.append(event)
		events = new_events

var events: Array[AudioEvent]
var _previous_time: float = 0

class AudioEvent:
	var time: float
	var id: StringName

func _process(_delta: float) -> void:
	var time := get_playback_position() + AudioServer.get_time_since_last_mix()
	var triggered_events := events.filter(
		func(event) -> bool:
			return (event.time <= time) and (event.time > _previous_time)
	)
	for event in triggered_events:
		EventBus.audio_event.emit(event.id)
	_previous_time = time
