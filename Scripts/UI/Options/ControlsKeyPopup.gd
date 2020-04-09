extends Popup

signal controlKeyInput

var keyToChange := ""
enum INPUT_WAIT {
	KEYBOARD,
	JOYPAD
}
var keyType = INPUT_WAIT.KEYBOARD

func _input(event: InputEvent) -> void:
	if (visible):
		# Consume all inputs because we don't want anything else to happen
		get_tree().set_input_as_handled()
		if ((event is InputEventKey && keyType == INPUT_WAIT.KEYBOARD) \
		|| (event is InputEventJoypadButton && keyType == INPUT_WAIT.JOYPAD)):
			emit_signal("controlKeyInput", event, keyToChange)
			hide()