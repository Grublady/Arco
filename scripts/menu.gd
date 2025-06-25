extends Node2D

@onready var rotator: Rotator2D = $Rotator2D

@onready var options: Array[CanvasItem] = [
	$Song1,
	$Song2,
	$Song3
]

func _process(_delta: float) -> void:
	rotator.global_rotation
	for option in options:
		option