extends Node2D

func onSave():
	$Sprite.frame = 1
	$Timer.start()

func _on_Timer_timeout():
	$Sprite.frame = 0

func reverseGravity():
	$Sprite.scale.y = -1

func normalGravity():
	$Sprite.scale.y = 1
