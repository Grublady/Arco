extends "res://scripts/input_mode_button.gd"#"uid://cxln43a233oir" # input_mode_button.gd

func _pressed() -> void:
	if OS.has_feature("web"):
		WebSensors.request_permission()
	super._pressed()
	RotationInput.calibrate()