class_name Rotator2D extends Node2D

@export var rotating := true:
	set(new_value):
		if new_value == rotating:
			return
		rotating = new_value
		if rotating:
			_auto_offset = global_rotation - RotationInput.rotation
@export var auto_offset_enabled := true
@export var manual_offset: float = 0

var _auto_offset: float = 0

func _process(_delta: float) -> void:
	if rotating:
		var new_rotation := RotationInput.rotation
		new_rotation += TAU * manual_offset
		if auto_offset_enabled:
			new_rotation += _auto_offset
		global_rotation = new_rotation
