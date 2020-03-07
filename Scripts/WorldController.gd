extends Node

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("pl_reset")):
		get_tree().reload_current_scene()
