extends RigidBody2D

var speed := Vector2.ZERO

func _ready():
	$Timer.start()

func _integrate_forces(state: Physics2DDirectBodyState):
	linear_velocity = speed
	if (state.get_contact_count() != 0):
		queue_free()


func _on_Timer_timeout():
	queue_free()
