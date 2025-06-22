@tool
extends Node2D

@export var width: float = 10:
	set(new_value):
		width = new_value
		queue_update()
@export var gap: float = 10:
	set(new_value):
		gap = new_value
		queue_update()
@export var inner_radius: float = 40:
	set(new_value):
		inner_radius = new_value
		queue_update()
@export_range(0, 1, 0.01) var arc_length: float = 0.9:
	set(new_value):
		arc_length = new_value
		queue_update()

var _update_queued := false

func _process(_delta: float) -> void:
	if _update_queued:
		_update_queued = false
		_update()

func queue_update() -> void:
	_update_queued = true

func _update() -> void:
	var rings = get_children().filter(func(node) -> bool: return node is Ring)
	for i in rings.size():
		var ring_inner := i * (width + gap) + inner_radius
		rings[i].arc_segment._inner_radius = ring_inner
		rings[i].arc_segment._outer_radius = ring_inner + width
		rings[i].arc_segment.arc_length = arc_length
		rings[i].arc_segment.arc_offset = 0
		rings[i].update_shape()