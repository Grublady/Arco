class_name Rotator2D extends Node2D

@export var rotating := true:
	set(new_value):
		if new_value == rotating:
			return
		rotating = new_value
		if rotating:
			offset = -RotationInput.rotation
@export var offset: float = 0

func _process(_delta: float) -> void:
	if rotating:
		rotation = RotationInput.rotation + offset