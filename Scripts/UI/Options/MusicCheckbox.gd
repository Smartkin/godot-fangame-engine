extends Button

var musicValue := true

func _ready():
	if (musicValue):
		text = "Music on"
	else:
		text = "Music off"

func _process(delta):
	if (musicValue):
		text = "Music on"
	else:
		text = "Music off"
