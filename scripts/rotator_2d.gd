class_name Rotator2D extends Node2D

@export var rotating := true
@export var offset := -0.25

func _process(_delta: float) -> void:
	if rotating:
		global_rotation = RotationInput.rotation + TAU * offset