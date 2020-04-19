extends StyledButtonCheckbox

var vsync := false

func _ready() -> void:
	if (vsync):
		right_lbl = "ON"
	else:
		right_lbl = "OFF"

func _process(delta: float) -> void:
	if (vsync):
		right_lbl = "ON"
	else:
		right_lbl = "OFF"
