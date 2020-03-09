extends Area2D

signal saved

func save():
	emit_signal("saved")

func _on_Area2D_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		body.canSave = true
		body.savePoint = self
	else:
		WorldController.saveGame()
		save()

func _on_Area2D_body_exited(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		body.canSave = false
		body.savePoint = null
