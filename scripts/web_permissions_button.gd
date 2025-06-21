extends Button

func _ready() -> void:
	if Rotator2D.is_web:
		show()
	else:
		queue_free()

func _pressed() -> void:
	JavaScriptBridge.eval("DeviceOrientationEvent.requestPermission()", true)
	queue_free()
