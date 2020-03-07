extends KinematicBody2D

const UP = Vector2.DOWN

signal block_collision

var speed := Vector2.ZERO
var toMove: Node2D = null

func _physics_process(delta: float) -> void:
	set_sync_to_physics(false)
	speed = move_and_slide(speed, UP, true)
	set_sync_to_physics(true)
	position -= speed * delta
	if (toMove != null):
		toMove.position += speed * delta
		position += speed * delta
	var collisions := []
	for i in range(get_slide_count()):
		collisions.append(get_slide_collision(i))
	if (collisions.size() != 0):
		emit_signal("block_collision", collisions)
