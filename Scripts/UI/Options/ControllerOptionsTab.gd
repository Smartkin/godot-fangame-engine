extends VBoxContainer

signal resetControllerControls

func _ready() -> void:
	$ControllerPrompts.selected = WorldController.currentConfig.controller_controls.controller

func _on_ResetControls_pressed() -> void:
	WorldController.currentConfig.controller_controls = WorldController.DEFAULT_CONFIG.controller_controls.duplicate(true)
	emit_signal("resetControllerControls")


func _on_ControllerPrompts_item_selected(id: int) -> void:
	WorldController.currentConfig.controller_controls.controller = id
