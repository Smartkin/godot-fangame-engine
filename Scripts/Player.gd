extends KinematicBody2D

const UP = Vector2(0, -1)
const SLOPE_SNAP = Vector2(0, -10)
const DEBUG_OUTPUT_RATE = 60
const MAX_COYOTE = 2
const MAX_JUMP_BUFFER = 2

var speed = Vector2(0, 0)
var canJump = true
var canDjump = true
var runSpeed = 200
var jumpHeight = -450
var djumpHeight = -350
var gravity = 20
var coyoteFrames = 0
var jumpBuffer = 0
var debugOutputTimer = 0

func _ready():
	$Sprite.play("Idle") # Set default sprite animation to idle

func _physics_process(_delta):
	debugOutputTimer += 1
	handleInputs()
	applyGravity()
	if (is_on_floor()):
		canJump = true
		canDjump = true
		coyoteFrames = MAX_COYOTE
	else:
		coyoteFrames -= 1
		if (coyoteFrames <= 0):
			canJump = false
	speed = move_and_slide_with_snap(speed, SLOPE_SNAP, UP, false, 4, 0.785398, false)
	if (speed.x == 0 && speed.y == 0):
		$Sprite.play("Idle")
	if (speed.y > 0):
		$Sprite.play("Fall")
	# Debug output
	if (debugOutputTimer >= DEBUG_OUTPUT_RATE):
		debugOutputTimer = 0
		print("Is on floor: " + String(is_on_floor()))
		print("Is on ceiling: " + String(is_on_ceiling()))
		print("Is touching wall: " + String(is_on_wall()))

# Player jumping logic
func jump(inputBuffer):
	var jumped = false
	if (canJump):
		speed.y = jumpHeight
		canJump = false
		jumped = true
		$Sounds/sndJump.play()
	elif (canDjump):
		speed.y = djumpHeight
		canDjump = false
		jumped = true
		$Sounds/sndDjump.play()
	if (jumped):
		$Sprite.play("Jump")
		return 0 # Indicate that the jump buffer input was consumed
	return inputBuffer - 1

func cutJump():
	speed.y *= 0.5

func applyGravity():
	speed.y += gravity

# Player running logic
func run(direction = 0):
	speed.x = runSpeed * direction
	if (direction != 0):
		if (speed.y == 0):
			$Sprite.play("Run")
		$Sprite.flip_h = (direction == -1)

func handleInputs():
	# Handle player jump
	if (Input.is_action_just_pressed("pl_jump")):
		jumpBuffer = MAX_JUMP_BUFFER
	if (jumpBuffer > 0):
		jumpBuffer = jump(jumpBuffer)
	# Handle player jump release
	if (Input.is_action_just_released("pl_jump")):
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

func shoot():
	$Sounds/sndShoot.play()
