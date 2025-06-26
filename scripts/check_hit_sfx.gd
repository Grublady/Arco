extends AudioStreamPlayer

func _ready() -> void:
	EventBus.check_event.connect(_on_check_event)

func _on_check_event(success: bool, _event_position: Vector2, _event_rotation: float, _kind: String) -> void:
	if success:
		play()