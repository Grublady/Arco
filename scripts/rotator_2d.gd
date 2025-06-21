class_name Rotator2D extends Node2D

static var _is_web := false

enum RotationInputMode {
	sensor,
	mouse,
	joystick
}

var mode := RotationInputMode.sensor

static func _static_init() -> void:
	if JavaScriptBridge.eval("true"):
		_is_web = true
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
			if _is_web:
				var beta: float = JavaScriptBridge.eval("_godotDeviceOrientationBeta", true)
				rotation_degrees = -1 * beta
			else:
				var device_gravity: Vector3 = Input.get_gravity()
				var gravity_2d := Vector2(device_gravity.x, device_gravity.y)
				rotation = -gravity_2d.angle() - PI/2

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