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
	$OptionsTabs/ControllerOptionsTab/ControllerPrompts.grab_focus()
	$Center/ChangeControlPopup.keyType = $Center/ChangeControlPopup.INPUT_WAIT.JOYPAD

func _on_Popup_controlKeyInput(newKey: InputEvent, actionName: String) -> void:
	var keyInput := InputMap.get_action_list(actionName)[0] as InputEventKey
	var controllerInput := InputMap.get_action_list(actionName)[1] as InputEventJoypadButton
	InputMap.action_erase_event(actionName, keyInput)
	InputMap.action_erase_event(actionName, controllerInput)
	if (newKey is InputEventKey):
		InputMap.action_add_event(actionName, newKey)
		InputMap.action_add_event(actionName, controllerInput)
		WorldController.currentConfig.keyboard_controls[actionName] = newKey.scancode
		btnBind.rightLbl = newKey.as_text()
	else:
		InputMap.action_add_event(actionName, keyInput)
		InputMap.action_add_event(actionName, newKey)
		WorldController.currentConfig.controller_controls[actionName] = newKey.button_index
		btnBind.rightLbl = Util.getControllerButtonString(newKey.button_index)


func _on_BindButton_keyBindPressed(bind: String, btn: Button) -> void:
	btnBind = btn
	$Center/ChangeControlPopup.keyToChange = bind
	$Center/ChangeControlPopup.show()


func _on_Button_pressed():
	WorldController.saveConfig()
	get_tree().change_scene("res://Rooms/Title.tscn")


# Update labels and input map for keyboard
func _on_KeyboardOptionsTab_resetKeyboardControls():
	var curConf :=  WorldController.currentConfig.keyboard_controls as Dictionary
	for keyboard_control in curConf:
		var controllerInput := InputMap.get_action_list(keyboard_control)[1] as InputEventJoypadButton
		var ev := InputEventKey.new()
		ev.scancode = curConf[keyboard_control]
		# Erase and readd the keys to not reorder keyboard and controller binds
		InputMap.erase_action(keyboard_control)
		InputMap.action_add_event(keyboard_control, ev)
		InputMap.action_add_event(keyboard_control, controllerInput)

# Update labels and input map for controller
func _on_ControllerOptionsTab_resetControllerControls():
	var curConf :=  WorldController.currentConfig.controller_controls as Dictionary
	for controller_control in curConf:
		var keyboardControl := InputMap.get_action_list(controller_control)[0] as InputEventKey
		var ev := InputEventKey.new()
		ev.scancode = curConf[controller_control]
		# Erase and readd the keys to not reorder keyboard and controller binds
		InputMap.erase_action(controller_control)
		InputMap.action_add_event(controller_control, keyboardControl)
		InputMap.action_add_event(controller_control, ev)
