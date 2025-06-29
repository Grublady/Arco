extends Control

@onready var selection_rotator := $Confirmation/Rotator2D

func finish() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func show_input_modes() -> void:
	$Title.show()
	$InputModeSelection.show()
	$InputModeSelection/ButtonContainer/SensorsButton.grab_focus()
func hide_input_modes() -> void:
	$Title.hide()
	$InputModeSelection.hide()

func show_input_confirmation() -> void:
	$Confirmation.show()
	$Confirmation.process_mode = Node.PROCESS_MODE_INHERIT
	RotationInput.rotation = 0
	selection_rotator.rotating = true
	if RotationInput.mode == RotationInput.Mode.sensor:
		$Confirmation/RotationLockLabel.show()
		$Confirmation/ConfirmOption.rotation = PI
	else:
		$Confirmation/RotationLockLabel.hide()
		$Confirmation/ConfirmOption.rotation = 0
func hide_input_confirmation() -> void:
	$Confirmation.hide()
	$Confirmation.process_mode = Node.PROCESS_MODE_DISABLED
	selection_rotator.rotating = false
	selection_rotator.rotation = 0

func _on_press_target_pressed() -> void:
	if $Confirmation.visible and $Confirmation/ConfirmOption.active:
		finish()

func _ready() -> void:
	$PressTarget.pressed.connect(_on_press_target_pressed)
	
	for button in $InputModeSelection/ButtonContainer.get_children():
		button.pressed.connect(hide_input_modes)
		button.pressed.connect(show_input_confirmation)
	
	$Confirmation/CancelButton.pressed.connect(hide_input_confirmation)
	$Confirmation/CancelButton.pressed.connect(show_input_modes)
	
	$Confirmation/ResetButton.pressed.connect(RotationInput.calibrate)
	
	$Confirmation.process_mode = Node.PROCESS_MODE_DISABLED
	
	$InputModeSelection/ButtonContainer/SensorsButton.grab_focus()

func _process(_delta: float) -> void:
	var active: bool = $Confirmation/ConfirmOption.active
	$Confirmation/RotateArrow.visible = (not active)
	$Confirmation/RotateArrow2.visible = (not active)
	$Confirmation/RotationLockLabel.visible = (RotationInput.mode == RotationInput.Mode.sensor and not active)
	$Confirmation/Rotator2D/TutorialLabel.visible = (not active)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if $Confirmation.visible:
			get_viewport().set_input_as_handled()
			hide_input_confirmation()
			show_input_modes()