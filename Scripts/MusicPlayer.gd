extends Node2D

export(String) var music

func _ready() -> void:
	WorldController.musicToPlay = music
	$Sprite.visible = false
