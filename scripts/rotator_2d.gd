class_name Rotator2D extends Node2D

@export var rotating := true

func _process(_delta: float) -> void:
	if rotating:
		global_rotation = RotationInput.rotation