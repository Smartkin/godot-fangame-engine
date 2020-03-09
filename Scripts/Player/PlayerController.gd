extends Node2D

var bullet := preload("res://Objects/Player/Bullet.tscn")

func sceneBuilt() -> void:
	if (WorldController.loadingSave):
		position = WorldController.saveData.playerPos

func _on_Player_dead(playerPos: Vector2) -> void:
	print(playerPos)
	position = get_viewport_rect().position
	$GameOver.visible = true
	$Blood.emitting = true
	$Blood.global_position = playerPos
	$BloodTimer.start()
	$Sounds/Death.play()

func _on_Player_shoot(direction: int) -> void:
	$Sounds/Shoot.play()
	var b := bullet.instance()
	var yPosOffset := -5 if WorldController.reverseGrav else 5
	add_child(b)
	b.speed = Vector2(1000 * direction, 0)
	b.position = Vector2($Player.position.x, $Player.position.y + yPosOffset)
	print(b.position)

func _on_Player_sound(soundName: String) -> void:
	var sound = get_node("Sounds/" + soundName)
	sound.play()

func _on_BloodTimer_timeout():
	$Blood.emitting = false
