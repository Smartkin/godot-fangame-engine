extends Area2D

signal saved

func save():
	emit_signal("saved")

func _on_Area2D_body_entered(body: Node2D) -> void:
	if (body is Player):
		body.can_save = true
		body.save_point = self
	else:
		WorldController.save_game()
		save()

func _on_Area2D_body_exited(body: Node2D) -> void:
	if (body is Player):
		body.can_save = false
		body.save_point = null
