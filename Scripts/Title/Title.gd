extends Control

func _ready() -> void:
	$PressButton.text = "PRESS SHIFT"

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("pl_jump")):
		get_tree().change_scene("res://TestBed.tscn")
