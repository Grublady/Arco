class_name EventfulAudioStreamPlayer extends AudioStreamPlayer

@export var custom_latency: float = 0

@export_multiline var events_string: String:
	set(new_value):
		events_string = new_value
		var new_events: Array[AudioEvent] = []
		var lines := events_string.split("\n")
		for line in lines:
			var components: Array[String] = []
			components.assign(line.split(":"))
			if components.size() < 2:
				continue
			var event := AudioEvent.new()
			event.time = components.pop_front()
			event.data = components
			new_events.append(event)
		events = new_events

@onready var _output_latency := AudioServer.get_output_latency()

var events: Array[AudioEvent]
var _previous_time: float = 0

class AudioEvent:
	var time: float
	var data: Array[String]

func _process(_delta: float) -> void:
	var time := get_playback_position()
	time += AudioServer.get_time_since_last_mix()
	time -= _output_latency
	time -= custom_latency
	if time <= _previous_time:
		return
	var triggered_events := events.filter(
		func(event) -> bool:
			return (event.time <= time) and (event.time > _previous_time)
	)
	for event in triggered_events:
		EventBus.audio_event.emit(event.data)
	_previous_time = time

func reset() -> void:
	_previous_time = 0