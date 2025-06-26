extends Node2D

@export var particle_kinds: Dictionary[String, Color]

var particles_scene: PackedScene = preload("res://scenes/check_hit_particles.tscn")

func _ready() -> void:
	EventBus.check_event.connect(_on_check_event)

func _on_check_event(success: bool, event_position: Vector2, event_rotation: float, kind: String) -> void:
	if not success:
		return
	
	var new_particles := particles_scene.instantiate()
	add_child(new_particles)
	
	new_particles.global_position = event_position
	new_particles.rotation = event_rotation
	if particle_kinds.has(kind):
		new_particles.modulate = particle_kinds[kind]
	
	new_particles.emitting = true