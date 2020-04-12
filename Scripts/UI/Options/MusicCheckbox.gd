extends StyledButtonCheckbox

var musicValue := true

func _ready():
	if (musicValue):
		rightLbl = "ON"
	else:
		rightLbl = "OFF"

func _process(delta):
	if (musicValue):
		rightLbl = "ON"
	else:
		rightLbl = "OFF"
