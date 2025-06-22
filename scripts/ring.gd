@tool
class_name Ring extends Rotator2D

@onready var collision_shape := CircleShape2D.new()
@onready var arc_segment: ArcSegment2D = $ArcSegment2D

func _ready() -> void:
	$Area2D/CollisionShape2D.shape = collision_shape

func update_shape() -> void:
	collision_shape.radius = arc_segment.get_outer_radius()