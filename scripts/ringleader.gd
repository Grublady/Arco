@tool
extends Node2D

@export var ring1_indicator_color: Color = Color.BLUE
@export var ring2_indicator_color: Color = Color.RED
@export var check_hit_range: float = .1

@onready var ring1 := $Ring1
@onready var ring2 := $Ring1/Ring2
@onready var ring1_arc := $Ring1/Arc2D
@onready var ring2_arc := $Ring1/Ring2/Arc2D
var indicator_scene: PackedScene = preload("res://scenes/indicator.tscn")

func _ready() -> void:
	EventBus.audio_event.connect(_on_audio_event)

func _on_audio_event(data: Array[String]) -> void:
	match data[0]:
		"ring1":
			ring1.rotating = true
			ring1_arc.modulate = Color.WHITE
			ring2.rotating = false
			ring2_arc.modulate = Color(1, 1, 1, 0.5)
		"ring2":
			ring1.rotating = false
			ring1_arc.modulate = Color(1, 1, 1, 0.5)
			ring2.rotating = true
			ring2_arc.modulate = Color.WHITE
		"indicator":
			var new_indicator := indicator_scene.instantiate()
			new_indicator.radius = 300
			match data[1]:
				"ring1":
					new_indicator.target_radius = ring1_arc.radius
					new_indicator.color = ring1_indicator_color
				"ring2":
					new_indicator.target_radius = ring2_arc.radius
					new_indicator.color = ring2_indicator_color
			new_indicator.rotation = TAU * float(data[2])
			if data.size() >= 4:
				new_indicator.tween_time = float(data[3])
			add_child(new_indicator)
		"check":
			var current_rotation: float = 0
			var location_radius: float = 0
			match data[1]:
				"ring1":
					current_rotation = ring1.global_rotation
					location_radius = ring1_arc.radius
				"ring2":
					current_rotation = ring2.global_rotation
					location_radius = ring2_arc.radius
			var target_rotation := float(data[2]) * TAU
			var success := (
				current_rotation <= target_rotation + (PI * check_hit_range)
				and current_rotation >= target_rotation - (PI * check_hit_range)
			)
			var event_position := to_global(position + Vector2.UP.rotated(target_rotation) * location_radius)
			EventBus.check_event.emit(success, event_position, current_rotation)
		"print":
			print(data[1])
		_:
			return