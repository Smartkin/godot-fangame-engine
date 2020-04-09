extends OptionButton

func _ready() -> void:
	var controllers := Input.get_connected_joypads()
	for cIndex in controllers:
		add_item("Controller: " + Input.get_joy_name(cIndex), cIndex)
