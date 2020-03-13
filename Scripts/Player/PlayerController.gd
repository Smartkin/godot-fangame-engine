extends Node2D

# Bullet object information
var bullet := preload("res://Objects/Player/Bullet.tscn")

# Callback from WorldController when a finish is changed and finishes being built
func sceneBuilt() -> void:
	if (WorldController.loadingSave):
		position = WorldController.saveData.playerPos
	$Camera.current = true

func _physics_process(delta):
	if ($Player):
		$Camera.position = $Player.position

# Callback when player dies
func _on_Player_dead(playerPos: Vector2) -> void:
	print(playerPos)
	global_position = playerPos
	$Camera.position = Vector2.ZERO
	$CameraFollowLayer/UI/GameOver.visible = true
	$Blood.emitting = true
	$Blood.global_position = playerPos
	$BloodTimer.start()
	$Sounds/Death.play()

# Callback when player shoots
func _on_Player_shoot(direction: int) -> void:
	$Sounds/Shoot.play()
	var b := bullet.instance() # Create bullet object
	var yPosOffset := -5 if WorldController.reverseGrav else 5 # Offset it against player's vertical position
	add_child(b)
	b.speed = Vector2(1000 * direction, 0)
	b.position = Vector2($Player.position.x, $Player.position.y + yPosOffset)
	print(b.position)

# Callback when player needs to play a sound
func _on_Player_sound(soundName: String) -> void:
	var sound = get_node("Sounds/" + soundName)
	sound.play()

# Callback when blood timer times out
func _on_BloodTimer_timeout():
	$Blood.emitting = false
