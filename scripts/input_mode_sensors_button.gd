extends "res://scripts/input_mode_button.gd"#"uid://cxln43a233oir" # input_mode_button.gd

func _pressed() -> void:
	RotationInput.calibrate()
	if OS.has_feature("web"):
		WebSensors.permission_callbacks.append(_calibrate_callback.unbind(1))
		WebSensors.request_permission()
	super._pressed()

func _calibrate_callback() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	RotationInput.calibrate()