extends Control

@onready var selection_rotator := $Confirmation/Rotator2D

func finish() -> void:
#	get_tree().change_scene_to_file("res://scenes/songs/xogot_jam_jam.tscn")
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func show_input_modes() -> void:
	$InputModeSelection.show()
	$InputModeSelection/ButtonContainer/SensorsButton.grab_focus()
func hide_input_modes() -> void:
	$InputModeSelection.hide()

func show_input_confirmation() -> void:
	$Confirmation.show()
	$Confirmation.process_mode = Node.PROCESS_MODE_INHERIT
	RotationInput.rotation = 0
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

func _on_press_target_pressed() -> void:
	if $Confirmation.visible and $Confirmation/ConfirmOption.active:
		hide_input_confirmation()
		show_latency_check()

func _ready() -> void:
	$PressTarget.pressed.connect(_on_press_target_pressed)
	
	for button in $InputModeSelection/ButtonContainer.get_children():
		button.pressed.connect(hide_input_modes)
		button.pressed.connect(show_input_confirmation)
	
	$Confirmation/CancelButton.pressed.connect(hide_input_confirmation)
	$Confirmation/CancelButton.pressed.connect(show_input_modes)
	
	$LatencyCheck/CancelButton.pressed.connect(hide_latency_check)
	$LatencyCheck/CancelButton.pressed.connect(show_input_confirmation)
	
	$LatencyCheck/ConfirmButton.pressed.connect(finish)
	
	$Confirmation.process_mode = Node.PROCESS_MODE_DISABLED
	
	$InputModeSelection/ButtonContainer/SensorsButton.grab_focus()

func _process(_delta: float) -> void:
	var active: bool = $Confirmation/ConfirmOption.active
	$Confirmation/RotateArrow.visible = (not active)
	$Confirmation/RotateArrow2.visible = (not active)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if $InputModeSelection.visible:
			return
		elif $Confirmation.visible:
			hide_input_confirmation()
			show_input_modes()
		elif $LatencyCheck.visible:
			hide_latency_check()
			show_input_confirmation()