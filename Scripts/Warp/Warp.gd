extends Node2D

export(String, FILE, "*.tscn") var warpTo

func _on_Area2D_body_entered(body):
	get_tree().change_scene(warpTo)
