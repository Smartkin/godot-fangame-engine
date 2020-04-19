extends StyledButtonCheckbox

var borderless := false

func _ready() -> void:
	if (borderless):
		right_lbl = "ON"
	else:
		right_lbl = "OFF"

func _process(delta: float) -> void:
	if (borderless):
		right_lbl = "ON"
	else:
		right_lbl = "OFF"
