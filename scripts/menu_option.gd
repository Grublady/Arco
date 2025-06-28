extends Label

signal pressed

@export var active := false:
	set = _set_active
@export var rotating := true
@export var menu_center := Vector2.ZERO

func get_offset_from_menu() -> Vector2:
	return global_position - menu_center + (size/2).rotated(rotation)

func rotate_around_center() -> void:
	rotation = get_offset_from_menu().angle() - PI/2

func _ready() -> void:
	_set_active(active)

func _process(_delta: float) -> void:
	if rotating and RotationInput.mode == RotationInput.Mode.sensor:
		rotation = RotationInput.rotation
	else:
		rotation = 0
	
	var angle := get_offset_from_menu().angle() + PI/2
	active = ( abs(angle_difference(RotationInput.rotation, angle)) <= PI/6 ) # 30°

func _input(event: InputEvent) -> void:
	if not active:
		return
	if not event.is_pressed():
		return
	
	if event is InputEventJoypadButton:
		pressed.emit()
	elif event is InputEventMouseButton or event is InputEventScreenTouch:
		if (event.position - get_viewport_rect().size/2).length_squared() <= 80**2:
			pressed.emit()

func _set_active(new_value: bool) -> void:
	active = new_value
	if active:
		self_modulate = Color(1, 1, 1, 0.5)
		$Panel.show()
	else:
		self_modulate = Color(0.5, 0.5, 0.5, 1)
		$Panel.hide()