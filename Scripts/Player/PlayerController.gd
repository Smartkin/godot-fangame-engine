extends Node2D

# Bullet object information
var bullet := preload("res://Objects/Player/Bullet.tscn")

var playerDead := false

# Callback from WorldController when a finish is changed and finishes being built
func sceneBuilt() -> void:
	if (WorldController.loadingSave):
		position = WorldController.saveData.playerPos
	$Camera.current = true

func _physics_process(delta: float) -> void:
	if (!playerDead):
		$Camera.position = $Player.position

# Callback when player dies
func _on_Player_dead(playerPos: Vector2) -> void:
	global_position = playerPos
	$Camera.position = Vector2.ZERO
	$CameraFollowLayer/UiCentered/GameOver.visible = true
	$Blood.emitting = true
	$Blood.global_position = playerPos
	$BloodTimer.start()
	$Sounds/Death.play()
	playerDead = true

func _input(event: InputEvent) -> void:
	var zoomSpeed = Vector2(0.05, 0.05)
	var maxZoomOut = Vector2(1, 1)
	var maxZoomIn = Vector2(0.05, 0.05)
	if (Input.is_mouse_button_pressed(BUTTON_WHEEL_UP)):
		$Camera.zoom -= zoomSpeed
		print($Camera.zoom.length())
		if ($Camera.zoom.x <= maxZoomIn.x):
			$Camera.zoom = maxZoomIn
	if (Input.is_mouse_button_pressed(BUTTON_WHEEL_DOWN)):
		$Camera.zoom += zoomSpeed
		print($Camera.zoom.length())
		if ($Camera.zoom.x >= maxZoomOut.x):
			$Camera.zoom = maxZoomOut

# Callback when player shoots
func _on_Player_shoot(direction: int) -> void:
	$Sounds/Shoot.play()
	var b := bullet.instance() # Create bullet object
	var xPosOffset := -5 if direction == -1 else 5
	var yPosOffset := -7 if WorldController.reverseGrav else 7 # Offset it against player's vertical position
	add_child(b)
	b.speed = Vector2(1500 * direction, 0)
	b.position = Vector2($Player.position.x + xPosOffset, $Player.position.y + yPosOffset)

# Callback when player needs to play a sound
func _on_Player_sound(soundName: String) -> void:
	var sound = get_node("Sounds/" + soundName)
	sound.play()

# Callback when blood timer times out
func _on_BloodTimer_timeout():
	$Blood.emitting = false
