extends Control

func _ready() -> void:
	EventBus.audio_event.connect(_on_audio_event)
	$SpinBox.value_changed.connect(_on_value_changed)
	$SpinBox.value = Settings.latency * 1000
	
	$ConfirmButton.pressed.connect(get_tree().change_scene_to_file.bind("res://scenes/menu.tscn"))
	
	$SpinBox/LRButtonLabel.visible = (RotationInput.mode == RotationInput.Mode.joystick)
	
	$ConfirmButton.grab_focus()
	
	$EventfulAudioStreamPlayer.play()

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

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_spinbox_increase"):
		$SpinBox.value += $SpinBox.custom_arrow_step
	elif event.is_action_pressed("ui_spinbox_decrease"):
		$SpinBox.value -= $SpinBox.custom_arrow_step