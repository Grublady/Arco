extends Label

var score: int = 0

func _ready() -> void:
	EventBus.check_event.connect(_on_check_event)

func _on_check_event(success: bool, _event_position: Vector2, _event_rotation: float) -> void:
	if success:
		score += 10
		update_text()

func update_text() -> void:
	text = "Score: " + var_to_str(score)