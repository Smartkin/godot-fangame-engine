extends KinematicBody2D

signal block_collision(collisions)

const UP := Vector2.DOWN

var speed := Vector2.ZERO
var to_move: Node2D = null

func _physics_process(delta: float) -> void:
	# Ugh, kind of hacked in but we wanna keep the sync
	# but we also wanna move and detect collisions internally by Godot
	# instead of attempting our own math
	set_sync_to_physics(false)
	speed = move_and_slide(speed, UP, true, 1)
	set_sync_to_physics(true)
	# Also a hack to move parent along with us
	position -= speed * delta
	if (to_move != null):
		to_move.position += speed * delta
		position += speed * delta
	# Array of KinematicCollision2D
	var collisions := []
	for i in range(get_slide_count()):
		collisions.append(get_slide_collision(i))
	# Check if any block collisions were detected, so parent can react accordingly
	if (collisions.size() != 0):
		emit_signal("block_collision", collisions)
