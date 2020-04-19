extends Node2D

# Constants
# Bullet object information
const Bullet := preload("res://Objects/Player/Bullet.tscn")

# Public
var player_dead := false

func _physics_process(delta: float) -> void:
	if (!player_dead):
		$Camera.position = $Player.position


func _input(event: InputEvent) -> void:
	var zoomSpeed = Vector2(0.05, 0.05)
	var maxZoomOut = Vector2(1, 1)
	var maxZoomIn = Vector2(0.05, 0.05)
	if (WorldController.DEBUG_MODE):
		if (Input.is_mouse_button_pressed(BUTTON_WHEEL_UP)):
			if ($Camera.zoom.x - zoomSpeed.x <= maxZoomIn.x):
				$Camera.zoom = maxZoomIn
			else:
				$Camera.zoom -= zoomSpeed
			print($Camera.zoom.length())
		if (Input.is_mouse_button_pressed(BUTTON_WHEEL_DOWN)):
			$Camera.zoom += zoomSpeed
			print($Camera.zoom.length())
			if ($Camera.zoom.x >= maxZoomOut.x):
				$Camera.zoom = maxZoomOut

# Callback from WorldController when scene is changed and finishes being built
func _on_scene_built() -> void:
	if (WorldController.loading_save):
		position.x = WorldController.cur_save_data.playerPosX
		position.y = WorldController.cur_save_data.playerPosY
	$Camera.current = true

# Callback when player shoots
func _on_Player_shoot(direction: int) -> void:
	$Sounds/Shoot.play()
	var b := Bullet.instance() # Create bullet object
	var xPosOffset := -5 if direction == -1 else 5
	var yPosOffset := -7 if WorldController.reverse_grav else 7 # Offset it against player's vertical position
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

# Callback when player dies
func _on_Player_dead(playerPos: Vector2) -> void:
	global_position = playerPos
	$Camera.position = Vector2.ZERO
	$CameraFollowLayer/UiCentered/GameOver.visible = true
	$Blood.emitting = true
	$Blood.global_position = playerPos
	$BloodTimer.start()
	$Sounds/Death.play()
	player_dead = true
	WorldController.cur_save_data.deaths += 1
	WorldController.save_to_file() # Save only deaths/time
