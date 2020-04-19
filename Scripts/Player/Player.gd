class_name Player
extends KinematicBody2D

# Signals
signal dead
signal shoot
signal sound

# Enums
enum STATE {
	RUN,
	GRAB,
	CUTSCENE,
	DEAD,
}
enum DIRECTION_H {
	LEFT = -1,
	IDLE = 0,
	RIGHT = 1,
}
enum DIRECTION_V {
	UP = -1,
	IDLE = 0,
	DOWN = 1,
}

# Constants
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
const VINE_SLIDE_OFFSET := Vector2(9, 6)

# Public
var speed := Vector2.ZERO
var snap := GROUND_SNAP
var can_jump := true
var can_djump := true
var set_run_sprite := false
var lose_djump := false
var can_save := false
var in_water := false
var had_djump := false
var jumped_in_water := false
var on_platform := false
var platform: Node2D = null
var save_point: Node2D = null
var face_direction: int = DIRECTION_H.RIGHT
var grabbables: Array = []
var waters: Array = []
var grav_dir := UP
var cur_snap := GROUND_SNAP
var run_speed := DEFAULT_RUN
var fall_speed := DEFAULT_FALL
var jump_height := -DEFAULT_JUMP
var djump_height := -DEFAULT_DJUMP
var gravity := DEFAULT_GRAV
var coyote_frames := 0
var jump_buffer := 0
var cur_state: int = STATE.RUN
var states_stack: Array = [STATE.RUN]

# Private
var _debug_output_timer := 0

# Onready vars
onready var collision_pivot_distance := Vector2(abs($Pivot.position.x - $Hitbox.position.x), abs($Pivot.position.y - $Hitbox.position.y))
onready var collision_start_pos: Vector2 = $Hitbox.position
onready var grab_pivot_distance := Vector2(abs($Pivot.position.x - $GrabHitbox/CollisionShape2D.position.x), abs($Pivot.position.y - $GrabHitbox/CollisionShape2D.position.y))
onready var grab_start_pos: Vector2 = $GrabHitbox/CollisionShape2D.position

func _ready() -> void:
	$Sprite.play("Idle") # Set default sprite animation to idle

func _physics_process(delta: float) -> void:
	# Check if player is currently on floor
	if (is_on_floor()):
		if (cur_state == STATE.GRAB): # Something was being grabbed set free
			_revert_state("_reset_sprite")
		# Regain jumping
		can_jump = true
		can_djump = true
		coyote_frames = MAX_COYOTE
		snap = cur_snap
	else: # When ground is left give some leeway before taking the single jump away
		coyote_frames -= 1
		if (coyote_frames <= 0):
			can_jump = false
	# Check for any current water collisions
	if (waters.size() != 0):
		if (!in_water): # If water was just entered
			had_djump = can_djump
		_apply_water_effects()
		in_water = true
	else:
		if (in_water): # If water was just left
			in_water = false
			reset_falling_speed() # Revert fallspeed to standard one
			if (lose_djump): # Check if water doesn't give djump back
				can_djump = had_djump # Get djump back if it wasn't used while in water
				lose_djump = false
	if (cur_state != STATE.GRAB): # If nothing is grabbed apply gravity
		_apply_gravity()
	_handle_inputs() # Process player's current inputs
	# Perform player movement but preserve only vertical momentum since we don't want any for horizontal
	speed.y = move_and_slide_with_snap(speed, snap, grav_dir, !on_platform, 4, MAX_SLOP_ANGLE).y
	on_platform = false
	for i in range(get_slide_count()): # Handle all the collisions that occured if needed
		_handle_collision(get_slide_collision(i))
	# Handle current sprite depending on player's state
	match cur_state:
		STATE.RUN:
			if (speed.x == 0 && is_on_floor() && !set_run_sprite):
				$Sprite.play("Idle")
			if (get_falling()):
				$Sprite.play("Fall")
			set_run_sprite = false
	# Debug output
	_debug_print()

# Whether player is currently falling
func get_falling() -> bool:
	var falling = speed.y > 0 if !WorldController.reverse_grav else speed.y < 0
	# Due to how slopes operate in Godot there can still be some leftover vertical speed
	# so additionally check if player is currently standing on a ground
	return falling && !is_on_floor()

# Resets player's fall speed to his default one
func reset_falling_speed() -> void:
	fall_speed = DEFAULT_FALL

# Sets player's fall speed
func set_falling_speed(new_fall_speed: int) -> void:
	fall_speed = new_fall_speed

# Player jumping logic
func jump(input_buffer: int) -> int:
	var jumped := false
	match cur_state: # Change jumping logic depending on state
		STATE.RUN: # Player is roaming/running around
			if (can_jump || platform != null):
				# Jumping in the platform
				if (platform != null):
					can_djump = true
				else: # If platform is not collided with take single jump away
					can_jump = false
				speed.y = jump_height
				jumped = true
				emit_signal("sound", "Jump")
			elif (can_djump):
				had_djump = false
				speed.y = djump_height
				can_djump = false
				jumped = true
				emit_signal("sound", "Djump")
		STATE.GRAB: # Player is grabbing onto something(ex. a vine)
			var grab_direction = get_grab_direction()
			var hitbox_direction = DIRECTION_H.IDLE
			if (grab_direction == GrabbableBase.TYPE.LEFT):
				hitbox_direction = DIRECTION_H.RIGHT
			elif (grab_direction == GrabbableBase.TYPE.RIGHT):
				hitbox_direction = DIRECTION_H.LEFT
			_revert_state("_reset_sprite") # Jump off the grabbable object
			emit_signal("sound", "Jump")
			_mirror_hitbox_hor(hitbox_direction)
			# TODO: set speed depending on the grabbed surface
			speed = Vector2(3 * run_speed * hitbox_direction, jump_height)
			jumped = true
	if (jumped): # If the player jumped
		$Sprite.play("Jump")
		snap = Vector2.ZERO
		return 0 # Indicate that the jump buffer input was consumed
	return input_buffer - 1

# Returns last grabbed surface's type
func get_grab_direction() -> int:
	var priority_grabbed: GrabbableBase = grabbables.back()
	return priority_grabbed.type

# Player running logic
func run(direction: int = DIRECTION_H.IDLE) -> void:
	speed.x = run_speed * direction
	if (direction != DIRECTION_H.IDLE):
		face_direction = direction
		if (is_on_floor()):
			set_run_sprite = true
			$Sprite.play("Run")
		$Sprite.flip_h = (direction == DIRECTION_H.LEFT)
		_mirror_hitbox_hor(direction)

# Player shooting logic
func shoot() -> void:
	var direction = face_direction
	if (cur_state == STATE.GRAB): # If we are grabbed onto something allow to manipulate shoot direction logic
		var grab: GrabbableBase = grabbables.back()
		var type = grab.getType()
		match type:
			GrabbableBase.TYPE.LEFT:
				direction = DIRECTION_H.RIGHT
			GrabbableBase.TYPE.RIGHT:
				direction = DIRECTION_H.LEFT
	emit_signal("shoot", direction) # Tell player controller to create a bullet

# Kill the player
func kill() -> void:
	if (cur_state != STATE.DEAD): # To prevent emitting this twice
		emit_signal("dead", global_position) # Tell player controller to do all the necessary post death logic
		_switch_state(STATE.DEAD)
	queue_free() # Destroy the player

# Any necessary debug inputs like warping to mouse, saving anywhere, godmode, etc.
func _debug_inputs() -> void:
	if (WorldController.DEBUG_MODE):
		if (Input.is_key_pressed(ord("W"))): # Warp player to mouse
			global_position = get_global_mouse_position()

# Any debug information that needs to be printed into the console
func _debug_print() -> void:
	if (WorldController.DEBUG_MODE):
		_debug_output_timer += 1
		if (_debug_output_timer >= DEBUG_OUTPUT_RATE):
			_debug_output_timer = 0
			print("Speed: " + String(speed))
			print("Is on floor: " + String(is_on_floor()))
			print("Is on ceiling: " + String(is_on_ceiling()))
			print("Is touching wall: " + String(is_on_wall()))

# Allows for variable jump heights
func _cut_jump() -> void:
	speed.y *= 0.5

# Apply gravity to the player
func _apply_gravity() -> void:
	# TODO: Potentially allow for arbitrary gravity direction make it Vector2
	speed.y += gravity
	# Cap fall speed depending on world's gravity
	if (!WorldController.reverse_grav):
		if (speed.y >= fall_speed):
			speed.y = fall_speed
	else:
		if (speed.y <= -fall_speed):
			speed.y = -fall_speed

# Puts player in a new state and pushes the previous state onto a stack
func _switch_state(newState: int) -> void:
	states_stack.push_back(cur_state)
	cur_state = newState

# Reverts player to previous state, pops the state stack if it's not empty and performs a function call if one was set
func _revert_state(callback := "") -> void:
	if (callback != ""):
		call(callback)
	if (states_stack.size() != 0):
		cur_state = states_stack.pop_back()

# Resets sprite's parameters like if it was offset from player's origin or flipped
func _reset_sprite() -> void:
	print("Reset sprite")
	$Sprite.position = Vector2.ZERO
	var grab_direction = get_grab_direction()
	if (grab_direction == GrabbableBase.TYPE.LEFT):
		$Sprite.flip_h = true
	elif (grab_direction == GrabbableBase.TYPE.RIGHT):
		$Sprite.flip_h = false


func _apply_water_effects() -> void:
	var water: WaterBase = waters.back() # Get the last entered water tile
	set_falling_speed(water.fall_speed) # Match our fall speed with its
	match water.type: # Change player's jumping logic depending on water type
		WaterBase.TYPE.WATER_1:
			can_jump = true
			can_djump = true
		WaterBase.TYPE.WATER_2:
			lose_djump = true
			can_djump = true
		WaterBase.TYPE.WATER_3:
			can_djump = true

# Mirrors a given point against another one
func _mirror_against_pivot(direction: int, origin: float, distance: float) -> float:
	return origin - 2 * distance if (direction == DIRECTION_H.LEFT) else origin

# Mirrors player's hitbox around X axis against a central pivot point
func _mirror_hitbox_hor(direction: int) -> void:
	$Hitbox.position.x = _mirror_against_pivot(direction, collision_start_pos.x, collision_pivot_distance.x)
	$GrabHitbox/CollisionShape2D.position.x = _mirror_against_pivot(direction, grab_start_pos.x, grab_pivot_distance.x)

# Mirrors player's hitbox around Y axis against a central pivot point
func _mirror_hitbox_ver(direction: int) -> void:
	$Hitbox.position.y = _mirror_against_pivot(direction, collision_start_pos.y, collision_pivot_distance.y)
	$GrabHitbox/CollisionShape2D.position.y = _mirror_against_pivot(direction, grab_start_pos.y, grab_pivot_distance.y)

# Sliding logic
func _slide_on_grab(direction: int = 0) -> String:
	var needed_action = "" # Required input to let go of the grabbed surface
	var priority_grabbed: GrabbableBase = grabbables.back() # Check against the last grabbed surface
	var type = priority_grabbed.type
	var slide_speed = priority_grabbed.slide_speed
	match type: # Change logic depending on what type of grabbed surface it is
		GrabbableBase.TYPE.LEFT:
			$Sprite.play("VineSlide")
			$Sprite.position = Vector2(VINE_SLIDE_OFFSET.x, VINE_SLIDE_OFFSET.y if !WorldController.reverse_grav else -VINE_SLIDE_OFFSET.y)
			$Sprite.flip_h = false
			speed.y = slide_speed if !WorldController.reverse_grav else -slide_speed
			needed_action = "right"
		GrabbableBase.TYPE.RIGHT:
			$Sprite.play("VineSlide")
			$Sprite.position = Vector2(-VINE_SLIDE_OFFSET.x, VINE_SLIDE_OFFSET.y if !WorldController.reverse_grav else -VINE_SLIDE_OFFSET.y)
			$Sprite.flip_h = true
			speed.y = slide_speed if !WorldController.reverse_grav else -slide_speed
			needed_action = "left"
	return needed_action

# Reverse player's gravity
func _reverse_gravity() -> void:
	gravity = -DEFAULT_GRAV
	jump_height = DEFAULT_JUMP
	djump_height = DEFAULT_DJUMP
	can_djump = true
	grav_dir = DOWN
	cur_snap = REVERSE_SNAP
	speed.y = 0
	$Sprite.flip_v = true
	_mirror_hitbox_ver(DIRECTION_V.UP)

# Return player's gravity to normal state
func _normal_gravity() -> void:
	gravity = DEFAULT_GRAV
	jump_height = -DEFAULT_JUMP
	djump_height = -DEFAULT_DJUMP
	can_djump = true
	grav_dir = UP
	cur_snap = GROUND_SNAP
	speed.y = 0
	$Sprite.flip_v = false
	_mirror_hitbox_ver(DIRECTION_V.DOWN)

# Input processing
func _handle_inputs() -> void:
	# Handle player run
	var direction: int = DIRECTION_H.IDLE
	var action := "right"
	if (Input.is_action_pressed("right")):
		direction = DIRECTION_H.RIGHT
	elif (Input.is_action_pressed("left")):
		direction = DIRECTION_H.LEFT
	# Check for player state
	match cur_state:
		STATE.RUN:
			run(direction)
		STATE.GRAB:
			run(direction)
			action = _slide_on_grab(direction)
	# Handle player jump
	var jump_from_vine: bool = (Input.is_action_pressed("jump") && Input.is_action_just_pressed(action) && cur_state == STATE.GRAB)
	if (Input.is_action_just_pressed("jump") || jump_from_vine):
		jump_buffer = MAX_JUMP_BUFFER
	if (jump_buffer > 0):
		jump_buffer = jump(jump_buffer)
		print(speed)
	# Handle player jump release
	if (Input.is_action_just_released("jump") && !get_falling()):
		_cut_jump()
	# Handle player shooting
	if (Input.is_action_just_pressed("shoot")):
		if (can_save): # Check if we are standing in a save point
			WorldController.save_game()
			save_point.save()
		shoot()
	_debug_inputs()

# Handle any specific needed collisions
func _handle_collision(collision: KinematicCollision2D) -> void:
	if (collision.collider.is_in_group("Killers")): # Check if we collided with a killer(spike, delfruit, etc.)
		kill()
	if (collision.collider.is_in_group("Platforms")):
		on_platform = true

# Grabbable surface was found
func _on_Grab_body_entered(body: GrabbableBase) -> void:
	print("Touched grabbable surface")
	grabbables.push_back(body)
	if (!is_on_floor() && cur_state != STATE.CUTSCENE):
		_switch_state(STATE.GRAB)

# Grabbable surface was exited
func _on_Grab_body_exited(body: GrabbableBase) -> void:
	print("Left grabbable surface")
	_revert_state("_reset_sprite")
	grabbables.erase(body) # We don't perform any checks since a body MUST be entered before it can be left
