extends Control

@onready var selection_rotator := $Confirmation/Rotator2D

func _ready() -> void:
	for button in $InputModeSelection/ButtonContainer.get_children():
		button.pressed.connect(_on_input_mode_button_pressed)
	$Confirmation/ConfirmOption.pressed.connect(_on_input_confirm_pressed)
	$Confirmation/CancelButton.pressed.connect(_on_input_cancel_pressed)
	$LatencyCheck/ConfirmButton.pressed.connect(_on_latency_confirm_pressed)
	$LatencyCheck/CancelButton.pressed.connect(_on_latency_cancel_pressed)
	$Confirmation.process_mode = Node.PROCESS_MODE_DISABLED

func _process(_delta: float) -> void:
	if absf(angle_difference(selection_rotator.rotation, PI)) < PI/6:
		$Confirmation/ConfirmOption.active = true
		$Confirmation/PressTarget.show()
		$Confirmation/TutorialArrow.hide()
	else:
		$Confirmation/ConfirmOption.active = false
		$Confirmation/PressTarget.hide()
		$Confirmation/TutorialArrow.show()

func _on_input_mode_button_pressed() -> void:
	$InputModeSelection.hide()
	$InputModeSelection.process_mode = Node.PROCESS_MODE_DISABLED
	$Confirmation.show()
	$Confirmation.process_mode = Node.PROCESS_MODE_INHERIT
	selection_rotator.rotating = true

func _on_input_cancel_pressed() -> void:
	$InputModeSelection.show()
	$InputModeSelection.process_mode = Node.PROCESS_MODE_INHERIT
	$Confirmation.hide()
	$Confirmation.process_mode = Node.PROCESS_MODE_DISABLED
	selection_rotator.rotating = false
	selection_rotator.rotation = 0

func _on_input_confirm_pressed() -> void:
	$Confirmation.hide()
	$Confirmation.process_mode = Node.PROCESS_MODE_DISABLED
	selection_rotator.rotating = false
	selection_rotator.rotation = 0
	$LatencyCheck.start()

func _on_latency_cancel_pressed() -> void:
	$LatencyCheck.end()
	$InputModeSelection.show()
	$InputModeSelection.process_mode = Node.PROCESS_MODE_INHERIT

func _on_latency_confirm_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/songs/xogot_jam_jam.tscn")