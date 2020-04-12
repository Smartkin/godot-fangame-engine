extends StyledButtonCheckbox

var vsync = false

func _ready():
	if (vsync):
		rightLbl = "ON"
	else:
		rightLbl = "OFF"

func _process(delta):
	if (vsync):
		rightLbl = "ON"
	else:
		rightLbl = "OFF"
