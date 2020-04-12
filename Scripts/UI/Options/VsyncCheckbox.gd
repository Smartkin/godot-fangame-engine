extends StyledButtonCheckbox

var vsync := false

func _ready() -> void:
	if (vsync):
		rightLbl = "ON"
	else:
		rightLbl = "OFF"

func _process(delta: float) -> void:
	if (vsync):
		rightLbl = "ON"
	else:
		rightLbl = "OFF"
