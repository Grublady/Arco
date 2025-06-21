class_name Rotator2D extends Node2D

static var calibration := PI
static var is_web := false
static var mode := RotationInputMode.mouse

enum RotationInputMode {
	sensor,
	mouse,
	joystick
}

static func _static_init() -> void:
	if JavaScriptBridge.eval("true"):
		is_web = true
		JavaScriptBridge.eval(
			"""
			var _godotDeviceOrientationAlpha = 0;
			var _godotDeviceOrientationBeta = 0;
			var _godotDeviceOrientationGamma = 0;
			window.addEventListener(
				'deviceorientation',
				function(event){
					_godotDeviceOrientationAlpha = event.alpha
					_godotDeviceOrientationBeta = event.beta
					_godotDeviceOrientationGamma = event.gamma
				}
			);
			""",
			true
		)

func _process(_delta: float) -> void:
	match mode:
		RotationInputMode.sensor:
			if is_web:
				var alpha: float = deg_to_rad(JavaScriptBridge.eval("_godotDeviceOrientationAlpha", true))
				var beta: float = deg_to_rad(JavaScriptBridge.eval("_godotDeviceOrientationBeta", true))
				var gamma: float = deg_to_rad(JavaScriptBridge.eval("_godotDeviceOrientationGamma", true))
				
				var quat_z := Quaternion(Vector3(0, 0, 1), alpha)
				var quat_x := Quaternion(Vector3(1, 0, 0), beta)
				var quat_y := Quaternion(Vector3(0, 1, 0), gamma)
				
				# Multiply in reverse order for intrinsic application
				var basis := Basis(quat_y * quat_x * quat_z)
				var direction := basis.z.normalized()
				var projected := Vector2(direction.x, direction.y).normalized()
				var angle := atan2(projected.y, projected.x)
				
				var screen_rotation: float = deg_to_rad(JavaScriptBridge.eval("screen.orientation.angle", true))
				
				rotation = calibration + screen_rotation - angle
			else:
				var device_gravity: Vector3 = Input.get_gravity()
				var gravity_2d := Vector2(device_gravity.x, device_gravity.y)
				rotation = -gravity_2d.angle() - PI/2
		RotationInputMode.mouse:
			var direction := get_global_mouse_position() - global_position
			rotation = direction.angle() + PI/2

func _unhandled_input(event: InputEvent) -> void:
	match mode:
#		RotationInputMode.mouse:
#			if event is InputEventMouseMotion:
#				var dir: Vector2 = event.position - get_viewport_transform()
#				rotation = dir.angle() + PI/2
		RotationInputMode.joystick:
			if event is InputEventJoypadMotion:
				var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
				rotation = dir.angle()