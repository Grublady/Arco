@tool
extends Node2D

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
			match data[1]:
				"ring1":
					new_indicator.target_radius = ring1_arc.radius
				"ring2":
					new_indicator.target_radius = ring2_arc.radius
			if data.size() >= 3:
				new_indicator.tween_time = float(data[2])
			add_child(new_indicator)
		"print":
			print(data[1])
		_:
			return