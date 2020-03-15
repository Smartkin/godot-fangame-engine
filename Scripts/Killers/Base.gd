extends KinematicBody2D

class_name KillerBase

func _ready() -> void:
	add_to_group("Killers")
	set_physics_process(false)
