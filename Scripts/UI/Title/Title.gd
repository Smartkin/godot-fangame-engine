extends Control

func _ready() -> void:
	$Layout/StartGame.grab_focus()


func _on_StartGame_pressed():
	get_tree().change_scene("res://Rooms/FileSelect.tscn")


func _on_Exit_pressed():
	get_tree().quit()


func _on_Options_pressed():
	get_tree().change_scene("res://Rooms/Options.tscn")
