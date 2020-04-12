extends StyledButtonCheckbox

var fullscreen := false

func _ready() -> void:
	if (fullscreen):
		rightLbl = "ON"
	else:
		rightLbl = "OFF"

func _process(delta: float) -> void:
	if (fullscreen):
		rightLbl = "ON"
	else:
		rightLbl = "OFF"
