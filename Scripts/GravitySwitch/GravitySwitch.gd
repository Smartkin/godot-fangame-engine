extends Area2D


func _on_Hitbox_body_entered(body: Node2D) -> void:
	if (!WorldController.reverseGrav):
		WorldController.reverseGrav = true
		WorldController.callGroup("GravityAffected", "reverseGravity")
