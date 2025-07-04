extends Node

@warning_ignore("unused_signal")
signal audio_event(event: AudioEvent)
class AudioEvent:
	var id: int
	var time: float
	var duration: float
	var data: Array[String]
@warning_ignore("unused_signal")
signal check_event(success: bool, position: Vector2, rotation: float, kind: String)
@warning_ignore("unused_signal")
signal input_mode_changed(mode: RotationInput.Mode)