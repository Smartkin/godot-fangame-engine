extends Area2D

func _on_Hitbox_body_entered(pl: Player) -> void:
	pl.waters.append(get_parent())


func _on_Hitbox_body_exited(pl: Player) -> void:
	pl.waters.erase(get_parent())
