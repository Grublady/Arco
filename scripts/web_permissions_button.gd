extends Button

func _ready() -> void:
	if RotationInput.is_web:
		show()
	else:
		queue_free()

func _process(_delta: float) -> void:
	if JavaScriptBridge.eval("_godotDeviceOrientationBeta") != 0:
		queue_free()

func _pressed() -> void:
	JavaScriptBridge.eval("DeviceOrientationEvent.requestPermission()", true)
	queue_free()
