extends "res://scripts/input_mode_button.gd"#"uid://cxln43a233oir" # input_mode_button.gd

func _pressed() -> void:
	if OS.has_feature("web"):
		WebSensors.permission_callbacks.append(_calibrate_callback.unbind(1))
		WebSensors.request_permission()
	RotationInput.calibrate()
	super._pressed()

func _calibrate_callback() -> void:
	var timer := Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.start(0.1)
	await timer.timeout
	RotationInput.calibrate()