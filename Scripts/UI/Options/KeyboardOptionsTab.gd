extends VBoxContainer

signal keyboard_controls_reset_pressed

func _on_ResetControls_pressed() -> void:
	WorldController.cur_config.keyboard_controls = WorldController.DEFAULT_CONFIG.keyboard_controls.duplicate(true)
	emit_signal("keyboard_controls_reset_pressed")
