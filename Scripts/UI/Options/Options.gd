extends Control

var btn_bind: Button

func _ready() -> void:
	pass

func _on_KeyboardSettings_pressed() -> void:
	$OptionsTabs.current_tab = 1
	$OptionsTabs/KeyboardOptionsTab/Left.grab_focus()
	$Center/ChangeControlPopup.key_type = $Center/ChangeControlPopup.INPUT_WAIT.KEYBOARD

func _on_ControllerSettings_pressed() -> void:
	$OptionsTabs.current_tab = 2
	$OptionsTabs/ControllerOptionsTab/Left.grab_focus()
	$Center/ChangeControlPopup.key_type = $Center/ChangeControlPopup.INPUT_WAIT.JOYPAD


func _on_Button_pressed() -> void:
	WorldController.save_config()
	get_tree().change_scene("res://Rooms/Title.tscn")


func _on_ChangeControlPopup_control_key_input(new_key: InputEvent, action_name: String) -> void:
	var key_input := InputMap.get_action_list(action_name)[0] as InputEventKey
	var controller_input := InputMap.get_action_list(action_name)[1] as InputEventJoypadButton
	InputMap.action_erase_event(action_name, key_input)
	InputMap.action_erase_event(action_name, controller_input)
	if (new_key is InputEventKey):
		InputMap.action_add_event(action_name, new_key)
		InputMap.action_add_event(action_name, controller_input)
		WorldController.cur_config.keyboard_controls[action_name] = new_key.scancode
		btn_bind.right_lbl = new_key.as_text()
	else:
		InputMap.action_add_event(action_name, key_input)
		InputMap.action_add_event(action_name, new_key)
		WorldController.cur_config.controller_controls[action_name] = new_key.button_index
		btn_bind.right_lbl = Util.get_controller_button_string(new_key.button_index)

# Update labels and input map for keyboard
func _on_KeyboardOptionsTab_keyboard_controls_reset_pressed() -> void:
	var cur_conf :=  WorldController.cur_config.keyboard_controls as Dictionary
	var btn_binds := $OptionsTabs/KeyboardOptionsTab.get_children()
	var btn_index := 0
	for keyboard_control in cur_conf:
		var controller_input := InputMap.get_action_list(keyboard_control)[1] as InputEventJoypadButton
		var ev := InputEventKey.new()
		ev.scancode = cur_conf[keyboard_control]
		# Erase and readd the keys to not reorder keyboard and controller binds
		InputMap.erase_action(keyboard_control)
		InputMap.add_action(keyboard_control)
		InputMap.action_add_event(keyboard_control, ev)
		InputMap.action_add_event(keyboard_control, controller_input)
		btn_binds[btn_index].right_lbl = ev.as_text()
		btn_index += 1


func _on_ButtonBind_key_bind_pressed(bind: String, btn: Button) -> void:
	btn_bind = btn
	$Center/ChangeControlPopup.key_to_change = bind
	$Center/ChangeControlPopup.show()

# Update labels and input map for controller
func _on_ControllerOptionsTab_controller_controls_reset_pressed() -> void:
	var cur_conf := WorldController.cur_config.controller_controls as Dictionary
	var btn_binds := $OptionsTabs/ControllerOptionsTab.get_children()
	var btn_index := 0
	for controller_control in cur_conf:
		if (controller_control == "controller"):
			btn_binds[btn_index].selected = cur_conf[controller_control]
			btn_index += 1
			continue
		var keyboardControl := InputMap.get_action_list(controller_control)[0] as InputEventKey
		var ev := InputEventJoypadButton.new()
		ev.button_index = cur_conf[controller_control]
		# Erase and readd the keys to not reorder keyboard and controller binds
		InputMap.erase_action(controller_control)
		InputMap.add_action(controller_control)
		InputMap.action_add_event(controller_control, keyboardControl)
		InputMap.action_add_event(controller_control, ev)
		btn_binds[btn_index].right_lbl = Util.get_controller_button_string(ev.button_index)
		btn_index += 1
