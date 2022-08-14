extends Node2D

export(String) var music
export(float, 5.0) var pitch = 1.0
export(bool) var fade = false

func _ready() -> void:
	$Sprite.visible = false
	WorldController.pitch_music(pitch)
	if fade:
		WorldController.fade_music()

func _enter_tree():
	WorldController.music_to_play = music
