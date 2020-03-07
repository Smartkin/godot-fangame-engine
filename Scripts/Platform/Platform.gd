extends KinematicBody2D

const UP := Vector2.DOWN

export var startSpeed := Vector2.ZERO
export var bounce := true
export var printDebug := false

var speed := Vector2.ZERO
var startPos := Vector2.ZERO
var beforeColSpeed := Vector2.ZERO

func _ready() -> void:
	speed = startSpeed
	startPos = position
	$Debug.rect_position = Vector2(-50, -50)
	$Debug.rect_size = Vector2(800, 600)
	if (bounce):
		($CollisionChecker as KinematicBody2D).speed = speed
		($CollisionChecker as KinematicBody2D).toMove = self
	else:
		($CollisionChecker as KinematicBody2D).disconnect("block_collision", self, "on_block_collision")

func handle_collision(collider: Node2D, normal: Vector2) -> void:
	if (collider.is_in_group("Solids")):
		speed = speed.bounce(normal)
		if (printDebug):
			print("Bounce normal: " + String(normal))
		($CollisionChecker as KinematicBody2D).speed = speed

func on_block_collision(collisions: Array) -> void:
	for i in range(collisions.size()):
		handle_collision(collisions[i].collider, collisions[i].normal)


func _on_GrabArea_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		body.platform = self


func _on_GrabArea_body_exited(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		body.platform = null
