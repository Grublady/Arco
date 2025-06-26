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
var pin_scene: PackedScene = preload("res://scenes/pin.tscn")

var _pins: Dictionary[int, Node]
var _active_pin: Node

func _ready() -> void:
	EventBus.audio_event.connect(_on_audio_event)

func _on_audio_event(event: EventBus.AudioEvent) -> void:
	match event.data.pop_front():
		"activate":
			activate_ring(event.data[0])
		"indicator":
			create_indicator(indicator_scene, event.data[0], float(event.data[1]), event.duration)
		"pin":
			var new_pin := create_indicator(pin_scene, event.data[0], float(event.data[1]), event.duration)
			_pins[event.id] = new_pin
		"end":
			match event.data.pop_front():
				"indicator":
					check(event.data[0], float(event.data[1]))
				"pin":
					if is_instance_valid(_active_pin):
						_active_pin.destroy()
					_active_pin = _pins[event.id]
					_pins.erase(event.id)
					
					check(event.data[0], float(event.data[1]))
					match event.data.pop_front():
						"ring1":
							activate_ring("ring2")
							_active_pin.reparent(ring1)
						"ring2":
							activate_ring("ring1")
							_active_pin.reparent(ring2)
		"print":
			print(event.data[0])
		_:
			return

func activate_ring(ring_name: String) -> void:
	match ring_name:
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

func create_indicator(source_scene: PackedScene, ring_name: String, event_rotation: float, event_duration: float) -> Node:
	var new_indicator := source_scene.instantiate()
	new_indicator.radius = 320
	match ring_name:
		"ring1":
			new_indicator.target_radius = ring1_arc.radius + ring1_arc.width / 4
			new_indicator.color = new_indicator.color_ring1
		"ring2":
			new_indicator.target_radius = ring2_arc.radius + ring2_arc.width / 4
			new_indicator.color = new_indicator.color_ring2
	new_indicator.rotation = TAU * event_rotation
	new_indicator.tween_time = event_duration
	add_child(new_indicator)
	return new_indicator

func check(ring_name: String, target_rotation: float) -> void:
	var current_rotation: float
	var location_radius: float
	match ring_name:
		"ring1":
			current_rotation = ring1.global_rotation
			location_radius = ring1_arc.radius
		"ring2":
			current_rotation = ring2.global_rotation
			location_radius = ring2_arc.radius
	
	var difference := angle_difference(target_rotation * TAU, current_rotation)
	var success := (absf(difference) <= PI * check_hit_range)
	
	var event_position := to_global(position + Vector2.UP.rotated(target_rotation * TAU) * location_radius)
	
	EventBus.check_event.emit(success, event_position, current_rotation)