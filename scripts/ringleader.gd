@tool
extends Node2D

@onready var ring1 := $Ring1
@onready var ring2 := $Ring1/Ring2

func _ready() -> void:
	EventBus.audio_event.connect(_on_audio_event)

func _on_audio_event(data: Array[String]) -> void:
	match data[0]:
		"ring1":
			ring1.rotating = true
			ring2.rotating = false
		"ring2":
			ring1.rotating = false
			ring2.rotating = true
		"print":
			print(data[1])
		_:
			return