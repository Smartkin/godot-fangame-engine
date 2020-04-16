extends VBoxContainer

signal resetControllerControls

func _on_ResetControls_pressed() -> void:
	WorldController.currentConfig.controller_controls = WorldController.DEFAULT_CONFIG.controller_controls.duplicate(true)
	emit_signal("resetControllerControls")
