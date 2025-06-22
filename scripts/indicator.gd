@tool
extends Arc2D

@export var target_radius: float = 50
@export var tween_time: float = 1

func _ready() -> void:
	var _tween := create_tween()
	_tween.tween_property(self, "radius", target_radius, tween_time)
	_tween.tween_callback(queue_free)