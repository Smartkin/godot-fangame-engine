extends Control

func _ready() -> void:
	pass

func _on_KeyboardSettings_pressed() -> void:
	$OptionsTabs.current_tab = 1
	$Center/ChangeControlPopup.keyType = $Center/ChangeControlPopup.INPUT_WAIT.KEYBOARD

func _on_ControllerSettings_pressed() -> void:
	$OptionsTabs.current_tab = 2
	$Center/ChangeControlPopup.keyType = $Center/ChangeControlPopup.INPUT_WAIT.JOYPAD

func _on_Popup_controlKeyInput(newKey: InputEvent, actionName: String) -> void:
	print(newKey.as_text() + ' key assigned')


func _on_BindButton_keyBindPressed(bind: String) -> void:
	$Center/ChangeControlPopup.keyToChange = bind
	$Center/ChangeControlPopup.show()


func _on_BackKeyboard_pressed() -> void:
	$OptionsTabs.current_tab = 0


func _on_Button_pressed():
	WorldController.saveConfig()
	get_tree().change_scene("res://Rooms/Title.tscn")


func _on_MasterVolumeSlider_exited():
	pass # Replace with function body.
