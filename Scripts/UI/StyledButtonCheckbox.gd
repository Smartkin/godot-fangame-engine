extends Button

class_name StyledButtonCheckbox

export(Array, String) var toggleLabels = ["Off", "On"]
export(bool) var toggled = false

func _ready() -> void:
	$HBoxContainer/ToggleLbl.text = toggleLabels[0 if !toggled else 1]
