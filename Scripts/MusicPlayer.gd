extends Node2D

export(String) var music

func _ready() -> void:
	$Sprite.visible = false

func _enter_tree():
	WorldController.music_to_play = music
