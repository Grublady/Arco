class_name Rotator2D extends Node2D

enum RotationInputMode {
	sensor,
	mouse,
	joystick
}

var mode := RotationInputMode.sensor

func _process(_delta: float) -> void:
	match mode:
		RotationInputMode.sensor:
			var device_accel := Input.get_gravity()
			var accel_2d := Vector2(device_accel.x, device_accel.y)
			rotation = -accel_2d.angle() - PI/2

func _unhandled_input(event: InputEvent) -> void:
	match mode:
		RotationInputMode.mouse:
			if event is InputEventMouseMotion:
				var dir: Vector2 = event.position - position
				rotation = dir.angle() + PI/2
		RotationInputMode.joystick:
			if event is InputEventJoypadMotion:
				var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
				rotation = dir.angle()