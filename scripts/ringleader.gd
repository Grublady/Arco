@tool
extends Node2D

@onready var ring1 := $Ring1
@onready var ring2 := $Ring1/Ring2
var indicator_scene: PackedScene = preload("res://scenes/indicator.tscn")

var _indicators: Array[Node] = []

func _ready() -> void:
	EventBus.audio_event.connect(_on_audio_event)

func _process(_delta: float) -> void:
	for indicator in _indicators:
		indicator.radius -= 1

func _on_audio_event(data: Array[String]) -> void:
	match data[0]:
		"ring1":
			ring1.rotating = true
			ring2.rotating = false
		"ring2":
			ring1.rotating = false
			ring2.rotating = true
		"indicator":
			var new_indicator := indicator_scene.instantiate()
			add_child(new_indicator)
			_indicators.append(new_indicator)
		"print":
			print(data[1])
		_:
			return