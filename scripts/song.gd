extends Node2D

func _ready() -> void:
	$EventfulAudioStreamPlayer.custom_latency = Settings.latency