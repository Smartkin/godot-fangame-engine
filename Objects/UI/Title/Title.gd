extends Control

func _ready() -> void:
	$Layout/StartGame.grab_focus()


func _on_StartGame_pressed():
	get_tree().change_scene("res://Rooms/FileSelect.tscn")
