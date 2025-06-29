class_name WebSensors

static var permission_callbacks: Array[Callable] = []

static var is_setup: bool = false

static var _orientation: JavaScriptObject
static var _acceleration: JavaScriptObject
static var _gravity: JavaScriptObject
static var _gyroscope: JavaScriptObject

static var _permission_callback := JavaScriptBridge.create_callback(_on_permission_callback)

static func _on_permission_callback(args: Array) -> void:
	for callback in permission_callbacks:
		callback.call(args)
	permission_callbacks = []

static func _static_init() -> void:
	if not OS.has_feature("web"):
		return
	JavaScriptBridge.eval("var _godotPermissionHelper = {}", true)
	JavaScriptBridge.get_interface("_godotPermissionHelper").callback = _permission_callback

static func request_permission() -> void:
	if not OS.has_feature("web"):
		return
	JavaScriptBridge.eval("""
if (typeof DeviceMotionEvent.requestPermission === "function") {
	DeviceMotionEvent.requestPermission().then(_godotPermissionHelper.callback)
}
	""", true)

static func setup() -> void:
	if not OS.has_feature("web"):
		return
	
	is_setup = true
	
	JavaScriptBridge.eval("""
var _godotDeviceOrientation = { x: 0, y: 0, z: 0 };
var _godotDeviceAcceleration = { x: 0, y: 0, z: 0 };
var _godotDeviceGravity = { x: 0, y: 0, z: 0 };
var _godotDeviceGyroscope = { x: 0, y: 0, z: 0 };
var _godotScreenOrientation = ""
var _godotScreenOrientationAngle = 0

window.ondeviceorientation = function(event) {
	_godotDeviceOrientation.x = event.beta;
	_godotDeviceOrientation.y = event.gamma;
	_godotDeviceOrientation.z = event.alpha;
}

window.ondevicemotion = function(event) {
	if (event.acceleration.x === null) return;
	
	_godotDeviceAcceleration.x = event.accelerationIncludingGravity.x;
	_godotDeviceAcceleration.y = event.accelerationIncludingGravity.y;
	_godotDeviceAcceleration.z = event.accelerationIncludingGravity.z;
	
	_godotDeviceGravity.x = event.accelerationIncludingGravity.x;
	_godotDeviceGravity.y = event.accelerationIncludingGravity.y;
	_godotDeviceGravity.z = event.accelerationIncludingGravity.z;
	
	_godotDeviceGyroscope.x = event.rotationRate.alpha;
	_godotDeviceGyroscope.y = event.rotationRate.beta;
	_godotDeviceGyroscope.z = event.rotationRate.gamma;
}

screen.orientation.onchange = function(event) {
	_godotScreenOrientation = event.target.type
	_godotScreenOrientationAngle = event.target.angle
}
	""", true)

static func get_orientation() -> Vector3:
	if not OS.has_feature("web"):
		return Vector3()
	if not _orientation:
		_orientation = JavaScriptBridge.get_interface("_godotDeviceOrientation")
	return _vec3_deg_to_rad(_js_object_to_vec3(_orientation))

static func get_accelerometer() -> Vector3:
	if not OS.has_feature("web"):
		return Input.get_accelerometer()
	if not _acceleration:
		_acceleration = JavaScriptBridge.get_interface("_godotDeviceAcceleration")
	return _reoirent(_js_object_to_vec3(_acceleration))

static func get_gravity() -> Vector3:
	if not OS.has_feature("web"):
		return Input.get_gravity()
	if not _gravity:
		_gravity = JavaScriptBridge.get_interface("_godotDeviceGravity")
	return _reoirent(_js_object_to_vec3(_gravity))

static func get_gyroscope() -> Vector3:
	if not OS.has_feature("web"):
		return Input.get_gyroscope()
	if not _gyroscope:
		_gyroscope = JavaScriptBridge.get_interface("_godotDeviceGyroscope")
	return _reoirent(_vec3_deg_to_rad(_js_object_to_vec3(_gyroscope)))

static func get_screen_orientation() -> DisplayServer.ScreenOrientation:
	if not OS.has_feature("web"):
		return DisplayServer.screen_get_orientation()
	match JavaScriptBridge.eval("_godotScreenOrientation", true):
		"portrait-primary":
			return DisplayServer.SCREEN_PORTRAIT
		"portrait-secondary":
			return DisplayServer.SCREEN_REVERSE_PORTRAIT
		"landscape-primary":
			return DisplayServer.SCREEN_LANDSCAPE
		"landscape-secondary":
			return DisplayServer.SCREEN_REVERSE_LANDSCAPE
		_:
			return DisplayServer.SCREEN_PORTRAIT

static func get_screen_orientation_angle() -> float:
	if not OS.has_feature("web"):
		return 0
	return JavaScriptBridge.eval("_godotScreenOrientationAngle")

static func _reoirent(vec: Vector3) -> Vector3:
	match get_screen_orientation():
		DisplayServer.SCREEN_LANDSCAPE:
			return Vector3(-vec.y, vec.x, vec.z)
		DisplayServer.SCREEN_PORTRAIT:
			return Vector3(vec.x, vec.y, vec.z)
		DisplayServer.SCREEN_REVERSE_LANDSCAPE:
			return Vector3(vec.y, -vec.x, vec.z)
		DisplayServer.SCREEN_REVERSE_PORTRAIT:
			return Vector3(-vec.x, -vec.y, vec.z)
		_:
			return vec

static func _js_object_to_vec3(object: JavaScriptObject) -> Vector3:
	return Vector3(object.x, object.y, object.z)

static func _vec3_deg_to_rad(vec: Vector3) -> Vector3:
	return Vector3(
		deg_to_rad(vec.x),
		deg_to_rad(vec.y),
		deg_to_rad(vec.z)
	)