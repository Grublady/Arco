extends Control

@onready var selection_rotator := $Confirmation/Rotator2D

func finish() -> void:
	get_tree().change_scene_to_file("res://scenes/songs/xogot_jam_jam.tscn")

func show_input_modes() -> void:
	$InputModeSelection.show()
func hide_input_modes() -> void:
	$InputModeSelection.hide()

func show_input_confirmation() -> void:
	$Confirmation.show()
	$Confirmation.process_mode = Node.PROCESS_MODE_INHERIT
	selection_rotator.rotating = true
	$Confirmation/RotationLockLabel.visible = (RotationInput.mode == RotationInput.Mode.sensor)
func hide_input_confirmation() -> void:
	$Confirmation.hide()
	$Confirmation.process_mode = Node.PROCESS_MODE_DISABLED
	selection_rotator.rotating = false
	selection_rotator.rotation = 0

func show_latency_check() -> void:
	$LatencyCheck.start()
func hide_latency_check() -> void:
	$LatencyCheck.end()

func _ready() -> void:
	for button in $InputModeSelection/ButtonContainer.get_children():
		button.pressed.connect(hide_input_modes)
		button.pressed.connect(show_input_confirmation)
	
	$Confirmation/ConfirmOption.pressed.connect(hide_input_confirmation)
	$Confirmation/CancelButton.pressed.connect(hide_input_confirmation)
	$Confirmation/ConfirmOption.pressed.connect(show_latency_check)
	$Confirmation/CancelButton.pressed.connect(show_input_modes)
	
	$LatencyCheck/CancelButton.pressed.connect(hide_latency_check)
	$LatencyCheck/CancelButton.pressed.connect(show_input_confirmation)
	
	$LatencyCheck/ConfirmButton.pressed.connect(finish)
	
	$Confirmation.process_mode = Node.PROCESS_MODE_DISABLED

func _process(_delta: float) -> void:
	if absf(angle_difference(selection_rotator.rotation, PI)) < PI/6:
		$Confirmation/ConfirmOption.active = true
		$Confirmation/PressTarget.show()
		$Confirmation/RotateArrow.hide()
		$Confirmation/RotateArrow2.hide()
	else:
		$Confirmation/ConfirmOption.active = false
		$Confirmation/PressTarget.hide()
		$Confirmation/RotateArrow.show()
		$Confirmation/RotateArrow2.show()