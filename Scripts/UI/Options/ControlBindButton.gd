extends StyledButtonCheckbox

export(String, "left", "right", "up", "down", "jump", \
	"shoot", "restart", "skip", "suicide", "pause") var bind
export(bool) var controllerBind = false

signal keyBindPressed

func _ready() -> void:
	if (!controllerBind):
		rightLbl = InputMap.get_action_list(bind)[0].as_text()
	else:
		rightLbl = Util.getControllerButtonString(InputMap.get_action_list(bind)[1].button_index)

func _on_KeyBind_pressed() -> void:
	emit_signal("keyBindPressed", bind, self)
