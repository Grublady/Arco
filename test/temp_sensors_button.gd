extends Button

func _pressed() -> void:
	if OS.has_feature("web"):
		WebSensors.request_permission()