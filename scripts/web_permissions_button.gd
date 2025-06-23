extends Button

func _ready() -> void:
	if OS.has_feature("web"):
		show()
	else:
		hide()

func _process(_delta: float) -> void:
	if WebSensors.get_orientation().x != 0:
		hide()

func _pressed() -> void:
	WebSensors.request_permission()
	hide()
