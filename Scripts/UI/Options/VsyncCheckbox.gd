extends Button

var vsync = false

func _ready():
	if (vsync):
		text = "Vsync on"
	else:
		text = "Vsync off"

func _process(delta):
	if (vsync):
		text = "Vsync on"
	else:
		text = "Vsync off"
