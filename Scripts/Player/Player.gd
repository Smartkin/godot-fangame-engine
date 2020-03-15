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
const GROUND_SNAP := Vector2.DOWN * 10
const REVERSE_SNAP := Vector2.UP * 10
const DEBUG_OUTPUT_RATE := 60
const MAX_COYOTE := 2
const MAX_JUMP_BUFFER := 2
const DEFAULT_RUN := 190
const DEFAULT_FALL := 420
const DEFAULT_JUMP := 450
const DEFAULT_DJUMP := 350
const DEFAULT_GRAV := 20
const MAX_SLOP_ANGLE := deg2rad(50)

var speed := Vector2.ZERO
var snap := GROUND_SNAP
var canJump := true
var canDjump := true
var setRunSprite := false
var loseDjump := false
var canSave := false
var inWater := false
var hadDjump := false
var jumpedInWater := false
var onPlatform := false
var platform: Node2D = null
var savePoint: Node2D = null
var faceDirection: int = DIRECTION.RIGHT
var grabbables: Array = []
var waters: Array = []
var gravDir := UP
var curSnap := GROUND_SNAP
var runSpeed := DEFAULT_RUN
var fallSpeed := DEFAULT_FALL
var jumpHeight := -DEFAULT_JUMP
var djumpHeight := -DEFAULT_DJUMP
var gravity := DEFAULT_GRAV
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
	# Check if player is currently on floor
	if (is_on_floor()):
		if (curState == STATE.GRAB): # Something was being grabbed set free
			revertState("resetSprite")
		# Regain jumping
		canJump = true
		canDjump = true
		coyoteFrames = MAX_COYOTE
		snap = curSnap
	else: # When ground is left give some leeway before taking the single jump away
		coyoteFrames -= 1
		if (coyoteFrames <= 0):
			canJump = false
	# Check for any current water collisions
	if (waters.size() != 0):
		if (!inWater): # If water was just entered
			hadDjump = canDjump
		applyWaterEffects()
		inWater = true
	else:
		if (inWater): # If water was just left
			inWater = false
			resetFallingSpeed() # Revert fallspeed to standard one
			if (loseDjump): # Check if water doesn't give djump back
				canDjump = hadDjump # Get djump back if it wasn't used while in water
				loseDjump = false
	if (curState != STATE.GRAB): # If nothing is grabbed apply gravity
			applyGravity()
	handleInputs() # Process player's current inputs
	# Perform player movement but preserve only vertical momentum since we don't want any for horizontal
	speed.y = move_and_slide_with_snap(speed, snap, gravDir, !onPlatform, 4, MAX_SLOP_ANGLE).y
	onPlatform = false
	for i in range(get_slide_count()): # Handle all the collisions that occured if needed
		handleCollision(get_slide_collision(i))
	# Handle current sprite depending on player's state
	match curState:
		STATE.RUN:
			if (speed.x == 0 && is_on_floor() && !setRunSprite):
				$Sprite.play("Idle")
			if (getFalling()):
				$Sprite.play("Fall")
			setRunSprite = false
	# Debug output
#	debugPrint()

func applyWaterEffects() -> void:
	var water: WaterBase = waters.back() # Get the last entered water tile
	setFallingSpeed(water.fallSpeed) # Match our fall speed with its
	match water.type: # Change player's jumping logic depending on water type
		WaterBase.TYPE.Water1:
			canJump = true
			canDjump = true
		WaterBase.TYPE.Water2:
			loseDjump = true
			canDjump = true
		WaterBase.TYPE.Water3:
			canDjump = true

# Whether player is currently falling
func getFalling() -> bool:
	var falling = speed.y > 0 if !WorldController.reverseGrav else speed.y < 0
	# Due to how slopes operate in Godot there can still be some leftover vertical speed
	# so additionally check if player is currently standing on a ground
	return falling && !is_on_floor()

# Resets player's fall speed to his default one
func resetFallingSpeed() -> void:
	fallSpeed = DEFAULT_FALL

# Sets player's fall speed
func setFallingSpeed(newFallSpeed: int) -> void:
	fallSpeed = newFallSpeed

# Player jumping logic
func jump(inputBuffer: int) -> int:
	var jumped := false
	match curState: # Change jumping logic depending on state
		STATE.RUN: # Player is roaming/running around
			if (canJump || platform != null):
				# Jumping in the platform
				if (platform != null):
					canDjump = true
				else: # If platform is not collided with take single jump away
					canJump = false
				speed.y = jumpHeight
				jumped = true
				emit_signal("sound", "Jump")
			elif (canDjump):
				hadDjump = false
				speed.y = djumpHeight
				canDjump = false
				jumped = true
				emit_signal("sound", "Djump")
		STATE.GRAB: # Player is grabbing onto something(ex. a vine)
			var grabDirection = getGrabDirection()
			var hitboxDirection = DIRECTION.IDLE
			if (grabDirection == GrabbableBase.TYPE.LEFT):
				hitboxDirection = DIRECTION.RIGHT
			elif (grabDirection == GrabbableBase.TYPE.RIGHT):
				hitboxDirection = DIRECTION.LEFT
			revertState("resetSprite") # Jump off the grabbable object
			emit_signal("sound", "Jump")
			mirrorHitboxHor(hitboxDirection)
			# TODO: set speed depending on the grabbed surface
			speed = Vector2(3 * runSpeed * hitboxDirection, jumpHeight)
			jumped = true
	if (jumped): # If the player jumped
		$Sprite.play("Jump")
		snap = Vector2.ZERO
		return 0 # Indicate that the jump buffer input was consumed
	return inputBuffer - 1

# Allows for variable jump heights
func cutJump() -> void:
	speed.y *= 0.5

# Apply gravity to the player
func applyGravity() -> void:
	# TODO: Potentially allow for arbitrary gravity direction make it Vector2
	speed.y += gravity
	# Cap fall speed depending on world's gravity
	if (!WorldController.reverseGrav):
		if (speed.y >= fallSpeed):
			speed.y = fallSpeed
	else:
		if (speed.y <= -fallSpeed):
			speed.y = -fallSpeed

# Returns last grabbed surface's type
func getGrabDirection() -> int:
	var priorityGrabbed: GrabbableBase = grabbables.back()
	return priorityGrabbed.type

# Player running logic
func run(direction: int = DIRECTION.IDLE) -> void:
	speed.x = runSpeed * direction
	if (direction != DIRECTION.IDLE):
		faceDirection = direction
		if (is_on_floor()):
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

# Sliding logic
func slideOnGrab(direction: int = 0) -> String:
	var neededAction = "" # Required input to let go of the grabbed surface
	var priorityGrabbed: GrabbableBase = grabbables.back() # Check against the last grabbed surface
	var type = priorityGrabbed.type
	var slideSpeed = priorityGrabbed.slideSpeed
	match type: # Change logic depending on what type of grabbed surface it is
		GrabbableBase.TYPE.LEFT:
			$Sprite.play("VineSlide")
			$Sprite.position = Vector2(vineSlideOffset.x, vineSlideOffset.y if !WorldController.reverseGrav else -vineSlideOffset.y)
			$Sprite.flip_h = false
			speed.y = slideSpeed if !WorldController.reverseGrav else -slideSpeed
			neededAction = "pl_right"
		GrabbableBase.TYPE.RIGHT:
			$Sprite.play("VineSlide")
			$Sprite.position = Vector2(-vineSlideOffset.x, vineSlideOffset.y if !WorldController.reverseGrav else -vineSlideOffset.y)
			$Sprite.flip_h = true
			speed.y = slideSpeed if !WorldController.reverseGrav else -slideSpeed
			neededAction = "pl_left"
	return neededAction

# Reverse player's gravity
func reverseGravity() -> void:
	gravity = -DEFAULT_GRAV
	jumpHeight = DEFAULT_JUMP
	djumpHeight = DEFAULT_DJUMP
	canDjump = true
	gravDir = DOWN
	curSnap = REVERSE_SNAP
	speed.y = 0
	$Sprite.flip_v = true
	mirrorHitboxVer(DIRECTION.LEFT)

# Return player's gravity to normal state
func normalGravity() -> void:
	gravity = DEFAULT_GRAV
	jumpHeight = -DEFAULT_JUMP
	djumpHeight = -DEFAULT_DJUMP
	canDjump = true
	gravDir = UP
	curSnap = GROUND_SNAP
	speed.y = 0
	$Sprite.flip_v = false
	mirrorHitboxVer(DIRECTION.RIGHT)

# Integer version of abs since we use static typing abs only works with floats
func absi(a: int) -> int:
	if (a < 0):
		return -a
	return a

# Input processing
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
	if (Input.is_action_just_released("pl_jump") && !getFalling()):
		cutJump()
	# Handle player shooting
	if (Input.is_action_just_pressed("pl_shoot")):
		if (canSave): # Check if we are standing in a save point
			WorldController.saveGame()
			savePoint.save()
		shoot()
	debugInputs()

# Handle any specific needed collisions
func handleCollision(collision: KinematicCollision2D) -> void:
	if (collision.collider.is_in_group("Killers")): # Check if we collided with a killer(spike, delfruit, etc.)
		kill()
	if (collision.collider.is_in_group("Platforms")):
		onPlatform = true

# Any necessary debug inputs like warping to mouse, saving anywhere, godmode, etc.
func debugInputs() -> void:
	if (Input.is_key_pressed(ord("W"))): # Warp player to mouse
		global_position = get_global_mouse_position()

# Any debug information that needs to be printed into the console
func debugPrint() -> void:
	debugOutputTimer += 1
	if (debugOutputTimer >= DEBUG_OUTPUT_RATE):
		debugOutputTimer = 0
		print("Speed: " + String(speed))
		print("Is on floor: " + String(is_on_floor()))
		print("Is on ceiling: " + String(is_on_ceiling()))
		print("Is touching wall: " + String(is_on_wall()))

# Player shooting logic
func shoot() -> void:
	var direction = faceDirection
	if (curState == STATE.GRAB): # If we are grabbed onto something allow to manipulate shoot direction logic
		var grab: GrabbableBase = grabbables.back()
		var type = grab.getType()
		match type:
			GrabbableBase.TYPE.LEFT:
				direction = DIRECTION.RIGHT
			GrabbableBase.TYPE.RIGHT:
				direction = DIRECTION.LEFT
	emit_signal("shoot", direction) # Tell player controller to create a bullet

# Kill the player
func kill() -> void:
	if (curState != STATE.DEAD): # To prevent emitting this twice
		emit_signal("dead", global_position) # Tell player controller to do all the necessary post death logic
		switchState(STATE.DEAD)
	queue_free() # Destroy the player

# Puts player in a new state and pushes the previous state onto a stack
func switchState(newState: int) -> void:
	statesStack.push_back(curState)
	curState = newState

# Reverts player to previous state, pops the state stack if it's not empty and performs a function call if one was set
func revertState(callback := "") -> void:
	if (callback != ""):
		call(callback)
	if (statesStack.size() != 0):
		curState = statesStack.pop_back()

# Resets sprite's parameters like if it was offset from player's origin or flipped
func resetSprite() -> void:
	print("Reset sprite")
	$Sprite.position = Vector2.ZERO
	var grabDirection = getGrabDirection()
	if (grabDirection == GrabbableBase.TYPE.LEFT):
		$Sprite.flip_h = true
	elif (grabDirection == GrabbableBase.TYPE.RIGHT):
		$Sprite.flip_h = false

# Grabbable surface was found
func _on_Grab_body_entered(body: GrabbableBase) -> void:
	print("Touched grabbable surface")
	grabbables.push_back(body)
	if (!is_on_floor() && curState != STATE.CUTSCENE):
		switchState(STATE.GRAB)

# Grabbable surface was exited
func _on_Grab_body_exited(body: GrabbableBase) -> void:
	print("Left grabbable surface")
	revertState("resetSprite")
	grabbables.erase(body) # We don't perform any checks since a body MUST be entered before it can be left
