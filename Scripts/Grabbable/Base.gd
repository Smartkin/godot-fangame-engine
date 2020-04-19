class_name GrabbableBase
extends KinematicBody2D

enum TYPE {
	LEFT,
	RIGHT,
	FRONT,
	BACK,
}

var type: int setget ,getType
var slide_speed: int setget ,getSlideSpeed

func _ready() -> void:
	set_physics_process(false)
	add_to_group("Grabbables")

func getType() -> int:
	return type

func getSlideSpeed() -> int:
	return slide_speed
