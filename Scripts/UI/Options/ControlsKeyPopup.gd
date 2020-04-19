extends Popup

signal control_key_input

# What input type we are binding
enum INPUT_WAIT {
	KEYBOARD,
	JOYPAD,
}

var key_to_change := "" # What key we are changing
var key_type = INPUT_WAIT.KEYBOARD

func _input(event: InputEvent) -> void:
	if (visible):
		# Consume all inputs because we don't want anything else to happen
		get_tree().set_input_as_handled()
		# Check that the input is appropriate
		if ((event is InputEventKey && key_type == INPUT_WAIT.KEYBOARD) \
		|| (event is InputEventJoypadButton && key_type == INPUT_WAIT.JOYPAD)):
			emit_signal("control_key_input", event, key_to_change)
			hide()
