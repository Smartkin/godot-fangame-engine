extends KinematicBody2D

signal dead
signal shoot
signal sound

enum STATE {
	RUN,
	GRAB,
	CUTSCENE,
	DEAD
}

enum DIRECTION {
	LEFT = -1,
	IDLE = 0,
	RIGHT = 1
}

const UP := Vector2.UP
const DOWN := Vector2.DOWN
const GROUND_SNAP := Vector2.DOWN * 5
const REVERSE_SNAP := Vector2.UP * 5
const DEBUG_OUTPUT_RATE := 60
const MAX_COYOTE := 2
const MAX_JUMP_BUFFER := 2

var speed := Vector2.ZERO
var snap := GROUND_SNAP
var canJump := true
var canDjump := true
var setRunSprite := false
var reverseGrav := false
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

onready var collisionPivotDistance := Vector2(abs($Pivot.position.x - $Hitbox.position.x), abs($Pivot.position.y - $Hitbox.position.y))
onready var collisionStartPos: Vector2 = $Hitbox.position

onready var grabPivotDistance := Vector2(abs($Pivot.position.x - $GrabHitbox/CollisionShape2D.position.x), abs($Pivot.position.y - $GrabHitbox/CollisionShape2D.position.y))
onready var grabStartPos: Vector2 = $GrabHitbox/CollisionShape2D.position

func _ready() -> void:
	$Sprite.play("Idle") # Set default sprite animation to idle

func _physics_process(delta: float) -> void:
	var up := UP if !reverseGrav else DOWN
	if (is_on_floor()):
		if (curState == STATE.GRAB):
			revertState("resetSprite")
		canJump = true
		canDjump = true
		coyoteFrames = MAX_COYOTE
		snap = GROUND_SNAP if !reverseGrav else REVERSE_SNAP
	else:
		if (curState != STATE.GRAB):
			applyGravity()
		coyoteFrames -= 1
		if (coyoteFrames <= 0):
			canJump = false
	handleInputs()
	speed = move_and_slide_with_snap(speed, snap, up)
	for i in range(get_slide_count()):
		handleCollision(get_slide_collision(i))
	match curState:
		STATE.RUN:
			var fallCondition: bool = speed.y > 0 if !reverseGrav else speed.y < 0
			if (speed.x == 0 && speed.y == 0 && !setRunSprite):
				$Sprite.play("Idle")
			if (fallCondition):
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
			mirrorHitboxHor(hitboxDirection)
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
		mirrorHitboxHor(direction)

# Mirrors a given point against another one
func mirrorAgainstPivot(direction: int, origin: float, distance: float) -> float:
	return origin - 2 * distance if (direction == DIRECTION.LEFT) else origin

# Mirrors player's hitbox around X axis against a central pivot point
func mirrorHitboxHor(direction: int) -> void:
	$Hitbox.position.x = mirrorAgainstPivot(direction, collisionStartPos.x, collisionPivotDistance.x)
	$GrabHitbox/CollisionShape2D.position.x = mirrorAgainstPivot(direction, grabStartPos.x, grabPivotDistance.x)

# Mirrors player's hitbox around Y axis against a central pivot point
func mirrorHitboxVer(direction: int) -> void:
	$Hitbox.position.y = mirrorAgainstPivot(direction, collisionStartPos.y, collisionPivotDistance.y)
	$GrabHitbox/CollisionShape2D.position.y = mirrorAgainstPivot(direction, grabStartPos.y, grabPivotDistance.y)

# Vine sliding logic
func slideOnGrab(direction: int = 0) -> String:
	var neededAction = ""
	var priorityGrabbed: GrabbableBase = grabbables.back()
	var type = priorityGrabbed.type
	var slideSpeed = priorityGrabbed.slideSpeed
	match type:
		GrabbableBase.TYPE.LEFT:
			$Sprite.play("VineSlide")
			$Sprite.position = Vector2(vineSlideOffset.x, vineSlideOffset.y if !reverseGrav else -vineSlideOffset.y)
			$Sprite.flip_h = false
			speed.y = slideSpeed if !reverseGrav else -slideSpeed
			neededAction = "pl_right"
		GrabbableBase.TYPE.RIGHT:
			$Sprite.play("VineSlide")
			$Sprite.position = Vector2(-vineSlideOffset.x, vineSlideOffset.y if !reverseGrav else -vineSlideOffset.y)
			$Sprite.flip_h = true
			speed.y = slideSpeed if !reverseGrav else -slideSpeed
			neededAction = "pl_left"
	return neededAction

# Reverse player's gravity
func reverseGravity() -> void:
	if (!reverseGrav):
		reverseGrav = true
		gravity = -absi(gravity)
		jumpHeight = absi(jumpHeight)
		djumpHeight = absi(djumpHeight)
		canDjump = true
		speed.y = 0
		$Sprite.flip_v = true
		mirrorHitboxVer(DIRECTION.LEFT)

func normalGravity() -> void:
	if (reverseGrav):
		reverseGrav = false
		gravity = absi(gravity)
		jumpHeight = -absi(jumpHeight)
		djumpHeight = -absi(djumpHeight)
		canDjump = true
		speed.y = 0
		$Sprite.flip_v = false
		mirrorHitboxVer(DIRECTION.RIGHT)

# Integer abs
func absi(a: int) -> int:
	return abs(a as float) as int

func handleInputs() -> void:
	# Handle player run
	var direction: int = DIRECTION.IDLE
	var action := "pl_right"
	if (Input.is_action_pressed("pl_right")):
		direction = DIRECTION.RIGHT
	elif (Input.is_action_pressed("pl_left")):
		direction = DIRECTION.LEFT
	# Check for player state
	match curState:
		STATE.RUN:
			run(direction)
		STATE.GRAB:
			run(direction)
			action = slideOnGrab(direction)
	# Handle player jump
	var jumpFromVine: bool = (Input.is_action_pressed("pl_jump") && Input.is_action_just_pressed(action) && curState == STATE.GRAB)
	if (Input.is_action_just_pressed("pl_jump") || jumpFromVine):
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
	if (curState != STATE.DEAD): # To prevent emitting this twice
		emit_signal("dead", global_position)
		switchState(STATE.DEAD)
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
	print("Reset sprite")
	$Sprite.position = Vector2.ZERO
	var grabDirection = getGrabDirection()
	if (grabDirection == GrabbableBase.TYPE.LEFT):
		$Sprite.flip_h = true
	elif (grabDirection == GrabbableBase.TYPE.RIGHT):
		$Sprite.flip_h = false

func _on_Grab_body_entered(body: GrabbableBase) -> void:
	print("Touched grabbable surface")
	grabbables.push_back(body)
	if (!is_on_floor() && curState != STATE.CUTSCENE):
		switchState(STATE.GRAB)

func _on_Grab_body_exited(body: GrabbableBase) -> void:
	print("Left grabbable surface")
	revertState("resetSprite")
	grabbables.erase(body)
