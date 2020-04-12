extends VBoxContainer

signal resetControllerControls

func _on_ResetControls_pressed():
	WorldController.currentConfig.controller_controls = WorldController.DEFAULT_CONFIG.controller_controls
	emit_signal("resetControllerControls")
