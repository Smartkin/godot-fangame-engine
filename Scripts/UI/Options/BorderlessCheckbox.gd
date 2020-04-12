extends StyledButtonCheckbox

var borderless := false

func _ready():
	if (borderless):
		rightLbl = "ON"
	else:
		rightLbl = "OFF"

func _process(delta):
	if (borderless):
		rightLbl = "ON"
	else:
		rightLbl = "OFF"
