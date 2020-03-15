extends Node2D

export(String) var music

func _ready():
	WorldController.musicToPlay = music
	$Sprite.visible = false
