extends VBoxContainer

signal load_game_pressed
signal new_game_pressed


func _on_Load_pressed():
	emit_signal("load_game_pressed")

func _on_New_pressed():
	emit_signal("new_game_pressed")
