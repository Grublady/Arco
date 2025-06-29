extends Node2D

func _ready() -> void:
	$EventfulAudioStreamPlayer.custom_latency = Settings.latency
	$EventfulAudioStreamPlayer.finished.connect(get_tree().change_scene_to_file.bind("res://scenes/menu.tscn"))