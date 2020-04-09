extends Label

var time := 0.0

func _process(delta: float) -> void:
	rect_position.y = sin(time) * 10
	time += delta * 2
