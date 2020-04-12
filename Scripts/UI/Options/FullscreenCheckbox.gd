extends StyledButtonCheckbox

var fullscreen := false

func _ready():
	if (fullscreen):
		rightLbl = "ON"
	else:
		rightLbl = "OFF"

func _process(delta):
	if (fullscreen):
		rightLbl = "ON"
	else:
		rightLbl = "OFF"
