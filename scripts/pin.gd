@tool
extends Arc2D

@export var color_ring1: Color = Color.BLUE
@export var color_ring2: Color = Color.RED
@export var target_radius: float = 0
@export var tween_time: float = 1

func _ready() -> void:
	if not Engine.is_editor_hint():
		var _tween := create_tween()
		_tween.set_parallel(true)
		modulate = Color(1, 1, 1, 0)
		_tween.tween_property(self, "modulate", Color(1, 1, 1, 1), tween_time/8)
		_tween.tween_property(self, "radius", target_radius, tween_time)
		_tween.set_parallel(false)

func destroy() -> void:
	var _tween := create_tween()
	_tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.1)
	_tween.tween_callback(queue_free)