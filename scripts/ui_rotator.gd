extends Rotator2D

func update_rotation_mode(mode: RotationInput.Mode) -> void:
	if mode == RotationInput.Mode.sensor:
		rotating = true
	else:
		rotating = false

func _ready() -> void:
	EventBus.input_mode_changed.connect(update_rotation_mode)
	update_rotation_mode(RotationInput.mode)

func _set_rotating(new_value: bool) -> void:
	rotation = 0
	super._set_rotating(new_value)