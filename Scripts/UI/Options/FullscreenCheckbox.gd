extends Button

var fullscreen := false

func _ready() -> void:
	if (fullscreen):
		text = "Fullscreen on"
	else:
		text = "Fullscreen off"

func _process(delta):
	if (fullscreen):
		text = "Fullscreen on"
	else:
		text = "Fullscreen off"
