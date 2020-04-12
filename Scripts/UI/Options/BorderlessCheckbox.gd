extends StyledButtonCheckbox

var borderless := false

func _ready() -> void:
	if (borderless):
		rightLbl = "ON"
	else:
		rightLbl = "OFF"

func _process(delta: float) -> void:
	if (borderless):
		rightLbl = "ON"
	else:
		rightLbl = "OFF"
