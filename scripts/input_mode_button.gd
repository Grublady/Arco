extends Button

@export var mode: RotationInput.Mode

func _pressed() -> void:
	RotationInput.mode = mode