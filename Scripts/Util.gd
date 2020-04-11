extends Node

func getControllerButtonString(btnIndex: int) -> String:
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
	return "Unknown button"
