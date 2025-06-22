@tool
extends Rotator2D

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
@export_range(0, 0.5, 0.01) var gap: float = 0.1:
	set(new_value):
		if new_value == gap:
			return
		gap = new_value
		queue_redraw()
@export var color: Color = Color.WHITE:
	set(new_value):
		if new_value == color:
			return
		color = new_value
		queue_redraw()

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		super._process(delta)

func _draw() -> void:
	var start_angle := -PI/2 + gap * TAU
	var end_angle := 3*PI/2 - gap * TAU
	draw_arc(Vector2.ZERO, radius, start_angle, end_angle, 64, color, width, true)