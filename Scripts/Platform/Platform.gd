extends KinematicBody2D

const UP = Vector2.DOWN
const DEBUG_OUTPUT_RATE = 60

export var startSpeed = Vector2.ZERO
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
	var _er = $CollisionChecker.connect("block_collision", self, "on_block_collision")
	$CollisionChecker.speed = speed
	$CollisionChecker.toMove = self

#func _physics_process(_delta):
#	position = $CollisionChecker.position
#
#func _integrate_forces(state):
#	position += speed * state.step
#	$Debug.text = "X: " + String(position.x) + "\n"
#	$Debug.text += "Y: " + String(position.y) + "\n"
#	$Debug.text += "Speed: " + String(speed) + "\n"
#	for i in range(state.get_contact_count()):
#		handleCollision(state.get_contact_collider_object(i), state.get_contact_local_normal(i))

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
