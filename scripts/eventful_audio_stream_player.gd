class_name EventfulAudioStreamPlayer extends AudioStreamPlayer

@export var custom_latency: float = 0
@export var tempo: float = 120

@export_multiline var events_string: String:
	set(new_value):
		events_string = new_value
		var new_events: Array[EventBus.AudioEvent] = []
		var lines := events_string.split("\n")
		for line in lines:
			var components: Array[String] = []
			components.assign(line.split(":"))
			if components.size() < 2:
				continue
			
			var event := EventBus.AudioEvent.new()
			event.time = float(components.pop_front()) * 60 / tempo
			event.duration = float(components.pop_front()) * 60 / tempo
			event.data.assign(components)
			new_events.append(event)
			
			if event.duration > 0:
				var end_event := EventBus.AudioEvent.new()
				end_event.time = event.time + event.duration
				end_event.duration = 0
				components.insert(0, "end")
				end_event.data.assign(components)
				new_events.append(end_event)
		events = new_events

@onready var _output_latency := AudioServer.get_output_latency()

var events: Array[EventBus.AudioEvent]
var _previous_time: float = 0

func _process(_delta: float) -> void:
	var time := get_playback_position()
	time += AudioServer.get_time_since_last_mix()
	time -= _output_latency
	time -= custom_latency
	if time <= _previous_time:
		return
	var triggered_events := events.filter(
		func(event) -> bool:
			return (event.time < time) and (event.time >= _previous_time)
	)
	for event in triggered_events:
		EventBus.audio_event.emit(event)
	_previous_time = time

func reset() -> void:
	_previous_time = 0