extends KinematicBody2D

const UP := Vector2.DOWN

export var start_speed := Vector2.ZERO
export var bounce := true

var speed := Vector2.ZERO
var start_pos := Vector2.ZERO

func _ready() -> void:
	speed = start_speed
	start_pos = position
	$Debug.rect_position = Vector2(-50, -50)
	$Debug.rect_size = Vector2(800, 600)
	if (bounce):
		($CollisionChecker as KinematicBody2D).speed = speed
		($CollisionChecker as KinematicBody2D).to_move = self
	else:
		($CollisionChecker as KinematicBody2D).disconnect("block_collision", self, "on_block_collision")

func _physics_process(delta):
	if (!bounce):
		position += speed * delta

func handle_collision(collider: Node2D, normal: Vector2) -> void:
	if (collider.is_in_group("Solids")):
		speed = speed.bounce(normal)
		($CollisionChecker as KinematicBody2D).speed = speed

func _reverse_gravity() -> void:
	$CollisionShape2D.scale.y = -1

func _normal_gravity() -> void:
	$CollisionShape2D.scale.y = 1

func on_block_collision(collisions: Array) -> void:
	for i in range(collisions.size()):
		handle_collision(collisions[i].collider, collisions[i].normal)


func _on_GrabArea_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		body.platform = self


func _on_GrabArea_body_exited(body: Node2D) -> void:
	if (body.is_in_group("Player")):
		body.platform = null
