extends Node2D

var particles_scene: PackedScene = preload("res://scenes/check_hit_particles.tscn")

func _ready() -> void:
	EventBus.check_event.connect(_on_check_event)

func _on_check_event(success: bool, event_position: Vector2, event_rotation: float) -> void:
	if not success:
		return
	var new_particles := particles_scene.instantiate()
	add_child(new_particles)
	new_particles.global_position = event_position
	print(event_position)
	new_particles.rotation = event_rotation
	new_particles.emitting = true