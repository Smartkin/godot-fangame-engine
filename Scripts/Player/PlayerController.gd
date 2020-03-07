extends Node2D

func _on_Player_dead(playerPos: Vector2) -> void:
	print(playerPos)
	position = get_viewport_rect().position
	$GameOver.visible = true
	$Sounds/Death.play()


func _on_Player_shoot() -> void:
	$Sounds/Shoot.play()


func _on_Player_sound(soundName: String) -> void:
	var sound = get_node("Sounds/" + soundName)
	sound.play()
