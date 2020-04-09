extends Button

export(String, "pl_left", "pl_right", "pl_up", "pl_down", "pl_jump", \
	"pl_shoot", "pl_restart", "pl_skip", "pl_suicide", "pl_pause") var bind

signal keyBindPressed

func _on_KeyBind_pressed():
	emit_signal("keyBindPressed", bind)
