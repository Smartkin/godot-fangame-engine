extends StyledButtonCheckbox

var music_value := true

func _ready() -> void:
	if (music_value):
		right_lbl = "ON"
	else:
		right_lbl = "OFF"

func _process(delta: float) -> void:
	if (music_value):
		right_lbl = "ON"
	else:
		right_lbl = "OFF"
