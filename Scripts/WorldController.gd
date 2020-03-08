extends Node

var reverseGrav := false setget setGrav,getGrav
var loadedFromSave := false
var saveData := {
	"playerPos": Vector2.ZERO,
	"scene": "res://TestBed.tscn"
} setget setSaveData, getSaveData

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("pl_reset")):
		loadGame()

func getGrav() -> bool:
	return reverseGrav

func setGrav(on: bool) -> void:
	reverseGrav = on

func getSaveData() -> Dictionary:
	return saveData

func setSaveData(data: Dictionary) -> void:
	if (data.has_all(saveData.keys())): # Check that new data has all the required keys
		saveData = data

func saveGame() -> void:
	var tree := get_tree()
	var scene := tree.current_scene
	var playerContronller := scene.find_node("PlayerController")
	saveData.playerPos = playerContronller.find_node("Player").global_position
	saveData.scene = scene.filename

func loadGame() -> void:
	loadedFromSave = true
	get_tree().change_scene(saveData.scene)
