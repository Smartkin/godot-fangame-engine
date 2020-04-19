extends Node
# This static class holds any utility functions that are useful to have globally

# Returns a controller button string depending on button's index
func get_controller_button_string(btnIndex: int) -> String:
	match btnIndex:
		JOY_SONY_X:
			return "A/Cross"
		JOY_SONY_SQUARE:
			return "X/Square"
		JOY_SONY_TRIANGLE:
			return "Y/Triangle"
		JOY_SONY_CIRCLE:
			return "B/Circle"
		JOY_DPAD_DOWN:
			return "D-Pad Down"
		JOY_DPAD_LEFT:
			return "D-Pad Left"
		JOY_DPAD_RIGHT:
			return "D-Pad Right"
		JOY_DPAD_UP:
			return "D-Pad Up"
		JOY_START:
			return "Start"
		JOY_SELECT:
			return "Select"
		JOY_L:
			return "Left Bumper/L1"
		JOY_L2:
			return "Left Trigger/L2"
		JOY_L3:
			return "Left Stick Button/L3"
		JOY_R:
			return "Right Bumper/R1"
		JOY_R2:
			return "Right Trigger/R2"
		JOY_R3:
			return "Right Stick Button/R3"
	return "Button " + str(btnIndex)


# Wrapper for call_group_flags(tree.GROUP_CALL_REALTIME, groupName, funcName)
func call_group(groupName: String, funcName: String) -> void:
	var tree := get_tree()
	tree.call_group_flags(tree.GROUP_CALL_REALTIME, groupName, funcName)


# Sets volume on a certain channel, value should range from 0 to 1
func set_volume(channel: String, value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(channel), linear2db(value))


# Integer version of abs since we use static typing abs only works with floats
func absi(a: int) -> int:
	if (a < 0):
		return -a
	return a
