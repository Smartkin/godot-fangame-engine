extends Node2D

func _on_Player_dead(playerPos):
	print(playerPos)
	position = get_viewport_rect().position
	$GameOver.visible = true
	$Sounds/Death.play()


func _on_Player_shoot():
	$Sounds/Shoot.play()


func _on_Player_sound(soundName):
	var sound = get_node("Sounds/" + soundName)
	sound.play()
