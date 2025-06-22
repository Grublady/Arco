extends Button

func _ready() -> void:
	if OS.has_feature("web"):
		show()
	else:
		queue_free()

func _process(_delta: float) -> void:
	if WebSensors.get_orientation().x != 0:
		queue_free()

func _pressed() -> void:
	WebSensors.request_permission()
	queue_free()
