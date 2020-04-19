extends VBoxContainer

signal controller_controls_reset_pressed

func _on_ResetControls_pressed() -> void:
	WorldController.cur_config.controller_controls = WorldController.DEFAULT_CONFIG.controller_controls.duplicate(true)
	emit_signal("controller_controls_reset_pressed")
