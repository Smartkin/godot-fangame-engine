extends StyledButtonCheckbox

signal key_bind_pressed

# Button bindings, should be named exactly like in InputMap
export(String, "left", "right", "up", "down", "jump", \
	"shoot", "restart", "skip", "suicide", "pause") var bind
# Whether this button binds a controller input
export(bool) var controller_bind = false

func _ready() -> void:
	# Get the button label
	if (!controller_bind):
		right_lbl = InputMap.get_action_list(bind)[0].as_text()
	else:
		right_lbl = Util.get_controller_button_string(InputMap.get_action_list(bind)[1].button_index)

func _on_KeyBind_pressed() -> void:
	emit_signal("key_bind_pressed", bind, self)
