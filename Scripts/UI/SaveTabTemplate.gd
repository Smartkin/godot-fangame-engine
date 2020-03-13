extends VBoxContainer

signal LoadGamePressed
signal NewGamePressed


func _on_Load_pressed():
	emit_signal("LoadGamePressed")

func _on_New_pressed():
	emit_signal("NewGamePressed")
