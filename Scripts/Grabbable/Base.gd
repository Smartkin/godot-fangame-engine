extends KinematicBody2D

class_name GrabbableBase

enum TYPE {
	LEFT,
	RIGHT,
	FRONT,
	BACK
}

var type: int setget ,getType
var slideSpeed: int setget ,getSlideSpeed

func _ready() -> void:
	set_physics_process(false)
	add_to_group("Grabbables")

func getType() -> int:
	return type

func getSlideSpeed() -> int:
	return slideSpeed
