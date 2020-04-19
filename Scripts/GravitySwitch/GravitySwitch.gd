extends Area2D


func _on_Hitbox_body_entered(body: Node2D) -> void:
	if (!WorldController.reverse_grav):
		WorldController.reverse_grav = true
		Util.call_group("GravityAffected", "_reverse_gravity")
