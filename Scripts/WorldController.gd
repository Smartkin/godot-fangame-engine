extends Node

var reverseGrav := false setget setGrav,getGrav

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("pl_reset")):
		get_tree().reload_current_scene()

func getGrav() -> bool:
	return reverseGrav

func setGrav(on: bool) -> void:
	reverseGrav = on
