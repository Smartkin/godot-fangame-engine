extends Area2D

func _on_Hitbox_body_entered(body: Node2D) -> void:
	body.waters.append(get_parent())


func _on_Hitbox_body_exited(body: Node2D) -> void:
	body.waters.erase(get_parent())
