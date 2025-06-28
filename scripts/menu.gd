extends Node2D

func _ready() -> void:
	$MenuOption.pressed.connect(_on_option_pressed.bind(&"opt1"))
	$MenuOption2.pressed.connect(_on_option_pressed.bind(&"opt2"))
	$MenuOption3.pressed.connect(_on_option_pressed.bind(&"opt3"))

func _on_option_pressed(id: StringName) -> void:
	match id:
		"opt2":
			get_tree().change_scene_to_file("res://scenes/songs/xogot_jam_jam.tscn")
		_:
			pass