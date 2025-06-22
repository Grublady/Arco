extends Rotator2D

@onready var arc := $Arc2D

func _set_rotating(new_value: bool) -> void:
	super._set_rotating(new_value)
	if rotating:
		arc.modulate = Color.WHITE
	else:
		arc.modulate = Color(1, 1, 1, 0.5)