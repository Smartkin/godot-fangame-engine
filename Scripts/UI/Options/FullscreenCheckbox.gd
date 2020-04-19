extends StyledButtonCheckbox

var fullscreen := false

func _ready() -> void:
	if (fullscreen):
		right_lbl = "ON"
	else:
		right_lbl = "OFF"

func _process(delta: float) -> void:
	if (fullscreen):
		right_lbl = "ON"
	else:
		right_lbl = "OFF"
