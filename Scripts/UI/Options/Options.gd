extends Control

var btnBind: Button

func _ready() -> void:
	pass

func _on_KeyboardSettings_pressed() -> void:
	$OptionsTabs.current_tab = 1
	$OptionsTabs/KeyboardOptionsTab/Left.grab_focus()
	$Center/ChangeControlPopup.keyType = $Center/ChangeControlPopup.INPUT_WAIT.KEYBOARD

func _on_ControllerSettings_pressed() -> void:
	$OptionsTabs.current_tab = 2
	$OptionsTabs/ControllerOptionsTab/Controller.grab_focus()
	$Center/ChangeControlPopup.keyType = $Center/ChangeControlPopup.INPUT_WAIT.JOYPAD

func _on_Popup_controlKeyInput(newKey: InputEvent, actionName: String) -> void:
	InputMap.action_add_event(actionName, newKey)
	print("Binded " + actionName + " to " + newKey.as_text())
	if (newKey is InputEventKey):
		btnBind.text = btnBind.bindLbl + " " + newKey.as_text()
	else:
		btnBind.text = btnBind.bindLbl + " " + Util.getControllerButtonString(newKey.button_index)


func _on_BindButton_keyBindPressed(bind: String, btn: Button) -> void:
	btnBind = btn
	$Center/ChangeControlPopup.keyToChange = bind
	$Center/ChangeControlPopup.show()


func _on_Button_pressed():
	WorldController.saveConfig()
	get_tree().change_scene("res://Rooms/Title.tscn")

