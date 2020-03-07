extends KinematicBody2D

signal dead
signal shoot
signal sound

const UP := Vector2.UP
const GROUND_SNAP := Vector2.DOWN * 5
const DEBUG_OUTPUT_RATE := 60
const MAX_COYOTE := 2
const MAX_JUMP_BUFFER := 2

var speed := Vector2.ZERO
var snap := GROUND_SNAP
var canJump := true
var canDjump := true
var setRunSprite := false
var grabbable: Node2D = null
var runSpeed := 190
var fallSpeed := 420
var jumpHeight := -450
var djumpHeight := -350
var gravity := 20
var coyoteFrames := 0
var jumpBuffer := 0
var debugOutputTimer := 0
onready var pivotDistance := abs($Pivot.position.x - $CollisionShape2D.position.x)
onready var collisionStartPos: Vector2 = $CollisionShape2D.position

func _ready() -> void:
	$Sprite.play("Idle") # Set default sprite animation to idle

func _physics_process(delta: float) -> void:
	if (is_on_floor()):
		canJump = true
		canDjump = true
		coyoteFrames = MAX_COYOTE
		snap = GROUND_SNAP
	else:
		applyGravity()
		coyoteFrames -= 1
		if (coyoteFrames <= 0):
			canJump = false
	handleInputs()
	speed = move_and_slide_with_snap(speed, snap, UP)
	for i in range(get_slide_count()):
		handleCollision(get_slide_collision(i))
	if (speed.x == 0 && speed.y == 0 && !setRunSprite):
		$Sprite.play("Idle")
	if (speed.y > 0):
		$Sprite.play("Fall")
	setRunSprite = false
	# Debug output
#	debugOutputTimer += 1
#	if (debugOutputTimer >= DEBUG_OUTPUT_RATE):
#		debugOutputTimer = 0
#		print("Speed: " + String(speed))
#		print("Is on floor: " + String(is_on_floor()))
#		print("Is on ceiling: " + String(is_on_ceiling()))
#		print("Is touching wall: " + String(is_on_wall()))

# Player jumping logic
func jump(inputBuffer: int) -> int:
	var jumped := false
	if (canJump || grabbable != null):
		# Jumping in the platform
		if (grabbable != null):
			canDjump = true
		else:
			canJump = false
		speed.y = jumpHeight
		jumped = true
		emit_signal("sound", "Jump")
	elif (canDjump):
		speed.y = djumpHeight
		canDjump = false
		jumped = true
		emit_signal("sound", "Djump")
	if (jumped):
		$Sprite.play("Jump")
		snap = Vector2.ZERO
		return 0 # Indicate that the jump buffer input was consumed
	return inputBuffer - 1

func cutJump() -> void:
	speed.y *= 0.5

func applyGravity() -> void:
	speed.y += gravity
	# Cap fall speed
	if (speed.y >= fallSpeed):
		speed.y = fallSpeed

# Player running logic
func run(direction: int = 0) -> void:
	speed.x = runSpeed * direction
	if (direction != 0):
		if (speed.y == 0):
			setRunSprite = true
			$Sprite.play("Run")
		$Sprite.flip_h = (direction == -1)
		$CollisionShape2D.position.x = collisionStartPos.x - 2 * pivotDistance if (direction == -1) else collisionStartPos.x


func handleInputs() -> void:
	# Handle player jump
	if (Input.is_action_just_pressed("pl_jump")):
		jumpBuffer = MAX_JUMP_BUFFER
	if (jumpBuffer > 0):
		jumpBuffer = jump(jumpBuffer)
	# Handle player jump release
	if (Input.is_action_just_released("pl_jump") && speed.y < 0):
		cutJump()
	# Handle player run
	if (Input.is_action_pressed("pl_left")):
		run(-1)
	elif (Input.is_action_pressed("pl_right")):
		run(1)
	else:
		run()
	# Handle player shooting
	if (Input.is_action_just_pressed("pl_shoot")):
		shoot()
	debugInputs()


func handleCollision(collision: KinematicCollision2D) -> void:
	if (collision.collider.is_in_group("Killers")):
		kill()

func debugInputs() -> void:
	if (Input.is_key_pressed(ord("W"))): # Warp player to mouse
		global_position = get_global_mouse_position()

func shoot() -> void:
	emit_signal("shoot")

func kill() -> void:
	emit_signal("dead", position)
	queue_free()
