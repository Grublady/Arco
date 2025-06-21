extends Node

var calibration := PI
var is_web := false
var mode := Mode.sensor
var rotation: float = 0

var _previous_joystick := Vector2.ZERO

enum Mode {
	sensor,
	mouse,
	joystick
}

func _init() -> void:
	if JavaScriptBridge.eval("true"):
		is_web = true

func _ready() -> void:
	if is_web:
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
		Mode.sensor:
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
			else: # not web
				var device_gravity: Vector3 = Input.get_gravity()
				var gravity_2d := Vector2(device_gravity.x, device_gravity.y)
				rotation = -gravity_2d.angle() - PI/2
		Mode.mouse:
			var mouse_pos := get_viewport().get_mouse_position()
			var center := get_viewport().get_visible_rect().size / 2
			var direction := mouse_pos - center
			rotation = direction.angle() + PI/2

func _input(event: InputEvent) -> void:
	match mode:
		Mode.joystick:
			if event is InputEventJoypadMotion:
				var new_joystick := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
				if _previous_joystick.is_zero_approx() or new_joystick.is_zero_approx():
					_previous_joystick = new_joystick
					return
				
				rotation += _previous_joystick.angle_to(new_joystick)
				_previous_joystick = new_joystick

func get_rotation() -> float:
	return rotation