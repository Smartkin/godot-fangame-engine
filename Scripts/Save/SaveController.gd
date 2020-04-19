extends Node2D

func onSave():
	$Sprite.frame = 1
	$Timer.start()

func _on_Timer_timeout():
	$Sprite.frame = 0

func _reverse_gravity():
	$Sprite.scale.y = -1

func _normal_gravity():
	$Sprite.scale.y = 1
