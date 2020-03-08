extends Area2D

signal saved

func save():
	emit_signal("saved")

func _on_Area2D_body_entered(body: Node2D):
	body.canSave = true
	body.savePoint = self


func _on_Area2D_body_exited(body: Node2D):
	body.canSave = false
	body.savePoint = null
