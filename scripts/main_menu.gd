extends Control

func _ready() -> void:
	for button in $InputModeButtons.get_children():
		button.pressed.connect(_on_input_mode_button_pressed)
	$CancelButton.pressed.connect(_on_cancel_button_pressed)
	$ConfirmOption.pressed.connect(_on_confirm_option_pressed)

func _process(_delta: float) -> void:
	if absf(angle_difference($Rotator2D.rotation, PI)) < PI/4:
		$ConfirmOption.active = true
	else:
		$ConfirmOption.active = false

func _on_input_mode_button_pressed() -> void:
	$InputModeButtons.hide()
	$InputModeLabel.hide()
	$Rotator2D.show()
	$ConfirmOption.show()
	$CancelButton.show()

func _on_cancel_button_pressed() -> void:
	$InputModeButtons.show()
	$InputModeLabel.show()
	$Rotator2D.hide()
	$ConfirmOption.hide()
	$CancelButton.hide()

func _on_confirm_option_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/songs/xogot_jam_jam.tscn")