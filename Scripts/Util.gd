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
