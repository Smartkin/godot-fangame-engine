extends VBoxContainer

signal resetKeyboardControls

func _on_ResetControls_pressed() -> void:
	WorldController.currentConfig.keyboard_controls = WorldController.DEFAULT_CONFIG.keyboard_controls.duplicate(true)
	emit_signal("resetKeyboardControls")
