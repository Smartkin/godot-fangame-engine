extends StyledButtonCheckbox

var musicValue := true

func _ready() -> void:
	if (musicValue):
		rightLbl = "ON"
	else:
		rightLbl = "OFF"

func _process(delta: float) -> void:
	if (musicValue):
		rightLbl = "ON"
	else:
		rightLbl = "OFF"
