extends Control

func start() -> void:
	show()
	$EventfulAudioStreamPlayer.play()

func end() -> void:
	hide()
	$EventfulAudioStreamPlayer.stop()

func _ready() -> void:
	EventBus.audio_event.connect(_on_audio_event)
	$SpinBox.value_changed.connect(_on_value_changed)
	if OS.has_feature("web"):
		$SpinBox.value = -100


func _on_audio_event(event: EventBus.AudioEvent) -> void:
	var data := event.data.duplicate()
	if data.pop_front() == "test":
		EventBus.check_event.emit(true, Vector2.ZERO, 0, "")
		
		var modulate_1: Color = $FlashContainer/Flash1.modulate
		var modulate_2: Color = $FlashContainer/Flash2.modulate
		$FlashContainer/Flash1.modulate = modulate_2
		$FlashContainer/Flash2.modulate = modulate_1

func _on_value_changed(value: float) -> void:
	Settings.latency = value / 1000
	$EventfulAudioStreamPlayer.custom_latency = Settings.latency