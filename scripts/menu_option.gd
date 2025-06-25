extends Label

signal pressed

@export var active := false:
	set = _set_active
@export var rotating := true
@export var menu_center := Vector2.ZERO

func rotate_around_center() -> void:
	rotation = get_global_rect().get_center().angle_to_point(menu_center) - PI/2

func _process(_delta: float) -> void:
	if rotating and RotationInput.mode == RotationInput.Mode.sensor:
		rotation = RotationInput.rotation
	else:
		rotation = 0

func _input(event: InputEvent) -> void:
	if not active:
		return
	if not event.is_pressed():
		return
	
	if (
		event is InputEventScreenTouch
		or event is InputEventMouseButton
		or event is InputEventJoypadButton
	):
		pressed.emit()

func _set_active(new_value: bool) -> void:
	active = new_value
	if active:
		$Panel.modulate = Color.WHITE
	else:
		$Panel.modulate = Color(0.5, 0.5, 0.5)