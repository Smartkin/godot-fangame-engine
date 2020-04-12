extends VBoxContainer

signal resetKeyboardControls

func _ready() -> void:
	pass


func _on_ResetControls_pressed():
	WorldController.currentConfig.keyboard_controls = WorldController.DEFAULT_CONFIG.keyboard_controls
	emit_signal("resetKeyboardControls")
