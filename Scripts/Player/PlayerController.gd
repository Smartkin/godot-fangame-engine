extends Node2D

func _on_Player_dead(playerPos: Vector2) -> void:
	print(playerPos)
	position = get_viewport_rect().position
	$GameOver.visible = true
	$Blood.emitting = true
	$Blood.global_position = playerPos
	$BloodTimer.start()
	$Sounds/Death.play()


func _on_Player_shoot() -> void:
	$Sounds/Shoot.play()


func _on_Player_sound(soundName: String) -> void:
	var sound = get_node("Sounds/" + soundName)
	sound.play()


func _on_BloodTimer_timeout():
	$Blood.emitting = false
