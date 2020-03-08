extends Node

var reverseGrav := false setget setGrav,getGrav
var loadedFromSave := false
var currentScene: Node = null
var saveData := {
	"playerPos": Vector2.ZERO,
	"scene": "res://TestBed2.tscn",
	"reverseGrav": false
} setget setSaveData, getSaveData

func _ready() -> void:
	print("World created")
	get_tree().connect("tree_changed", self, "onTreeChange")

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
	saveData.reverseGrav = reverseGrav

# Monitor tree change and if scene changed apply post scene finishing effects
func onTreeChange() -> void:
	if (get_tree() != null):
		if (currentScene != get_tree().current_scene):
			currentScene = get_tree().current_scene
			if (currentScene != null):
				if (currentScene.filename == saveData.scene):
					onSceneFinished()

func loadGame() -> void:
	var tree := get_tree()
	loadedFromSave = true
	# Load data
	reverseGrav = saveData.reverseGrav
	tree.change_scene(saveData.scene)

func onSceneFinished() -> void:
	print("Applying global effects after scene building")
	if (reverseGrav): # Reverse gravity of all objects that need it
		get_tree().call_group("GravityAffected", "reverseGravity")
