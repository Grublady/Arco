@tool
class_name Arc2D extends Node2D

@export var radius: float = 50:
	set(new_value):
		if new_value == radius:
			return
		radius = new_value
		queue_redraw()
@export var width: float = 10:
	set(new_value):
		if new_value == width:
			return
		width = new_value
		queue_redraw()
@export_range(0, 1, 0.01) var length: float = 0.1:
	set(new_value):
		if new_value == length:
			return
		length = new_value
		queue_redraw()
@export_range(-1, 1, 0.01) var offset: float = -0.25:
	set(new_value):
		if new_value == offset:
			return
		offset = new_value
		queue_redraw()
@export var color: Color = Color.WHITE:
	set(new_value):
		if new_value == color:
			return
		color = new_value
		queue_redraw()

func _draw() -> void:
	var start_angle := offset * TAU - length * PI
	var end_angle := offset * TAU + length * PI
	draw_arc(Vector2.ZERO, radius, start_angle, end_angle, 64, color, width, true)