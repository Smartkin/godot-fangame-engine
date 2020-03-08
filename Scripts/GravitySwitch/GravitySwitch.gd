extends Area2D


func _on_Hitbox_body_entered(body: Node2D):
	if (!WorldController.reverseGrav):
		WorldController.reverseGrav = true
		var gravNodes := get_tree().get_nodes_in_group("GravityAffected")
		for i in range(gravNodes.size()):
			if (gravNodes[i].has_method("reverseGravity")):
				gravNodes[i].reverseGravity()
