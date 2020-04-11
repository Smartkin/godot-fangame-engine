extends Button

export(String, "left", "right", "up", "down", "jump", \
	"shoot", "restart", "skip", "suicide", "pause") var bind
export(bool) var controllerBind = false

var bindLbl := ""

signal keyBindPressed

func _ready():
	bindLbl = text
	print(InputMap.get_action_list(bind))
	if (!controllerBind):
		text = bindLbl + " " + InputMap.get_action_list(bind)[0].as_text()
	else:
		text = bindLbl + " " + Util.getControllerButtonString(InputMap.get_action_list(bind)[1].button_index)

func _on_KeyBind_pressed():
	emit_signal("keyBindPressed", bind, self)
