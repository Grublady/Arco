extends Sprite2D

@export var time: float = 2
@export var curve: Curve

var progress: float = 0

func _process(delta: float) -> void:
	progress += delta
	progress = fmod(progress, time)
	var sample := curve.sample_baked(progress / time)
	scale = Vector2(sample, sample)
