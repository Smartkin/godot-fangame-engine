extends Button

var borderless := false

func _ready() -> void:
	if (borderless):
		text = "Borderless on"
	else:
		text = "Borderless off"

func _process(delta):
	if (borderless):
		text = "Borderless on"
	else:
		text = "Borderless off"
