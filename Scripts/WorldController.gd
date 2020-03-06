extends Node

func _input(event):
	if (event.is_action_pressed("pl_reset")):
		var _er = get_tree().reload_current_scene()
