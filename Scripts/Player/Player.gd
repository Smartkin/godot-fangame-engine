extends KinematicBody2D

signal dead
signal shoot
signal sound

const UP := Vector2.UP
const GROUND_SNAP := Vector2.DOWN * 5
const DEBUG_OUTPUT_RATE := 60
const MAX_COYOTE := 2
const MAX_JUMP_BUFFER := 2

enum STATE {
	RUN,
	GRAB,
	CUTSCENE
}

enum DIRECTION {
	LEFT = -1,
	IDLE = 0,
	RIGHT = 1
}

var speed := Vector2.ZERO
var snap := GROUND_SNAP
var canJump := true
var canDjump := true
var setRunSprite := false
var platform: Node2D = null
var grabbables: Array = []
var runSpeed := 190
var fallSpeed := 420
var jumpHeight := -450
var djumpHeight := -350
var gravity := 20
var coyoteFrames := 0
var jumpBuffer := 0
var debugOutputTimer := 0
var curState: int = STATE.RUN
var statesStack: Array = [STATE.RUN]
var vineSlideOffset := Vector2(9, 6)

onready var collisionPivotDistance := abs($Pivot.position.x - $Hitbox.position.x)
onready var collisionStartPos: Vector2 = $Hitbox.position

onready var grabPivotDistance := abs($Pivot.position.x - $GrabHitbox/CollisionShape2D.position.x)
onready var grabStartPos: Vector2 = $GrabHitbox/CollisionShape2D.position

func _ready() -> void:
	$Sprite.play("Idle") # Set default sprite animation to idle

func _physics_process(delta: float) -> void:
	if (is_on_floor()):
		if (curState == STATE.GRAB):
			revertState("resetSprite")
		canJump = true
		canDjump = true
		coyoteFrames = MAX_COYOTE
		snap = GROUND_SNAP
	else:
		if (curState != STATE.GRAB):
			applyGravity()
		coyoteFrames -= 1
		if (coyoteFrames <= 0):
			canJump = false
	handleInputs()
	speed = move_and_slide_with_snap(speed, snap, UP)
	for i in range(get_slide_count()):
		handleCollision(get_slide_collision(i))
	match curState:
		STATE.RUN:
			if (speed.x == 0 && speed.y == 0 && !setRunSprite):
				$Sprite.play("Idle")
			if (speed.y > 0):
				$Sprite.play("Fall")
			setRunSprite = false
	
	# Debug output
#	debugPrint()

# Player jumping logic
func jump(inputBuffer: int) -> int:
	var jumped := false
	match curState:
		STATE.RUN:
			if (canJump || platform != null):
				# Jumping in the platform
				if (platform != null):
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
		STATE.GRAB:
			var grabDirection = getGrabDirection()
			var hitboxDirection = DIRECTION.IDLE
			if (grabDirection == GrabbableBase.TYPE.LEFT):
				hitboxDirection = DIRECTION.RIGHT
			elif (grabDirection == GrabbableBase.TYPE.RIGHT):
				hitboxDirection = DIRECTION.LEFT
			revertState("resetSprite")
			emit_signal("sound", "Jump")
			mirrorHitbox(hitboxDirection)
			speed = Vector2(3 * runSpeed * hitboxDirection, jumpHeight)
			jumped = true
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

func getGrabDirection() -> int:
	var priorityGrabbed: GrabbableBase = grabbables.back()
	return priorityGrabbed.type

# Player running logic
func run(direction: int = 0) -> void:
	speed.x = runSpeed * direction
	if (direction != DIRECTION.IDLE):
		if (speed.y == 0):
			setRunSprite = true
			$Sprite.play("Run")
		$Sprite.flip_h = (direction == DIRECTION.LEFT)
		mirrorHitbox(direction)

# Mirrors a given point against another one
func mirrorAgainstPivot(direction: int, origin: float, distance: float) -> float:
	return origin - 2 * distance if (direction == DIRECTION.LEFT) else origin

# Mirrors player's hitbox around X axis against a central pivot point
func mirrorHitbox(direction: int) -> void:
	$Hitbox.position.x = mirrorAgainstPivot(direction, collisionStartPos.x, collisionPivotDistance)
	$GrabHitbox/CollisionShape2D.position.x = mirrorAgainstPivot(direction, grabStartPos.x, grabPivotDistance)

# Vine sliding logic
func slideOnGrab(direction: int = 0) -> void:
	var priorityGrabbed: GrabbableBase = grabbables.back()
	var type = priorityGrabbed.type
	var slideSpeed = priorityGrabbed.slideSpeed
	match type:
		GrabbableBase.TYPE.LEFT:
			$Sprite.play("VineSlide")
			$Sprite.position = vineSlideOffset
			$Sprite.flip_h = false
			speed.y = slideSpeed
		GrabbableBase.TYPE.RIGHT:
			$Sprite.play("VineSlide")
			$Sprite.position = Vector2(-vineSlideOffset.x, vineSlideOffset.y)
			$Sprite.flip_h = true
			speed.y = slideSpeed

func handleInputs() -> void:
	# Handle player run
	var direction: int = DIRECTION.IDLE
	if (Input.is_action_pressed("pl_right")):
		direction = DIRECTION.RIGHT
	elif (Input.is_action_pressed("pl_left")):
		direction = DIRECTION.LEFT
	# Check for player state
	match curState:
		STATE.RUN:
			run(direction)
		STATE.GRAB:
			slideOnGrab(direction)
	# Handle player jump
	if (Input.is_action_just_pressed("pl_jump")):
		jumpBuffer = MAX_JUMP_BUFFER
	if (jumpBuffer > 0):
		jumpBuffer = jump(jumpBuffer)
		print(speed)
	# Handle player jump release
	if (Input.is_action_just_released("pl_jump") && speed.y < 0):
		cutJump()
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

func debugPrint() -> void:
	debugOutputTimer += 1
	if (debugOutputTimer >= DEBUG_OUTPUT_RATE):
		debugOutputTimer = 0
		print("Speed: " + String(speed))
		print("Is on floor: " + String(is_on_floor()))
		print("Is on ceiling: " + String(is_on_ceiling()))
		print("Is touching wall: " + String(is_on_wall()))

func shoot() -> void:
	emit_signal("shoot")

func kill() -> void:
	emit_signal("dead", position)
	queue_free()

# Puts player in a new state
func switchState(newState: int) -> void:
	statesStack.push_back(curState)
	curState = newState

# Reverts player to previous state
func revertState(callback := "") -> void:
	if (callback != ""):
		call(callback)
	if (statesStack.size() != 0):
		curState = statesStack.pop_back()

func resetSprite() -> void:
	$Sprite.position = Vector2.ZERO
	var grabDirection = getGrabDirection()
	print("Reset grab state")
	if (grabDirection == GrabbableBase.TYPE.LEFT):
		$Sprite.flip_h = true
	elif (grabDirection == GrabbableBase.TYPE.RIGHT):
		$Sprite.flip_h = false

func _on_Grab_body_entered(body: GrabbableBase) -> void:
	print("Touched grabbable surface")
	if (!is_on_floor() && curState != STATE.CUTSCENE):
		switchState(STATE.GRAB)
		grabbables.push_back(body)

func _on_Grab_body_exited(body: GrabbableBase) -> void:
	print("Left grabbable surface")
	revertState("resetSprite")
	grabbables.erase(body)
