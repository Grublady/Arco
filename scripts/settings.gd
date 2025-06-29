class_name Settings
static var latency: float = 0

static func _static_init() -> void:
	if OS.has_feature("web"):
		latency = -100.0 / 1000.0