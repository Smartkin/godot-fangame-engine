extends KinematicBody2D

const UP = Vector2.DOWN
const DEBUG_OUTPUT_RATE = 60

export var startSpeed = Vector2.ZERO
export var bounce = true
var speed = Vector2.ZERO
var time = 0
var debugOutputTimer = 0
var startPos = Vector2.ZERO
var beforeColSpeed = Vector2.ZERO

func _ready():
	speed = startSpeed
	startPos = position
	$Debug.rect_position = Vector2(-50, -50)
	$Debug.rect_size = Vector2(800, 600)
	if (bounce):
		$CollisionChecker.speed = speed
		$CollisionChecker.toMove = self
	else:
		$CollisionChecker.disconnect("block_collision", self, "on_block_collision")

func handle_collision(collider, normal):
	if (collider.is_in_group("Solids")):
		print("Collision with solid")
		print(normal)
		speed = speed.bounce(normal)
		print(speed)
		$CollisionChecker.speed = speed

func on_block_collision(collisions):
	for i in range(collisions.size()):
		handle_collision(collisions[i].collider, collisions[i].normal)


func _on_GrabArea_body_entered(body):
	if (body.is_in_group("Player")):
		body.grabbable = self


func _on_GrabArea_body_exited(body):
	if (body.is_in_group("Player")):
		body.grabbable = null
