extends Node2D

@onready var options: Dictionary[Node, String] = {
	$SongXJJOption: "res://scenes/songs/xogot_jam_jam.tscn",
	$SongOakwoodOption: "res://scenes/songs/oakwood.tscn",
	$MainMenuOption: "res://scenes/main_menu.tscn",
	$LatencyOption: "res://scenes/latency_check.tscn",
}

func _ready() -> void:
	$PressTarget.pressed.connect(_on_press_target_pressed)

func _on_press_target_pressed() -> void:
	for node in options.keys():
		if node.active:
			get_tree().change_scene_to_file(options[node])
			return