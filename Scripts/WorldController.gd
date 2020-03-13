extends Node

# Public members
var reverseGrav := false setget setGrav,getGrav
var saveData := {
	"playerPos": Vector2.ZERO,
	"scene": "res://TestBed2.tscn",
	"reverseGrav": false
} setget setSaveData, getSaveData
var saveSlot := 0
var saveFiles := 3

# Readonly
var loadingSave := false setget , getLoadingSave

# Private
var currentScene: Node = null

func _ready() -> void:
	print("World created")
	get_tree().connect("tree_changed", self, "onTreeChange")

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("pl_reset")):
		loadGame()

func getGrav() -> bool:
	if (loadingSave):
		return !saveData.reverseGrav
	return reverseGrav

func setGrav(on: bool) -> void:
	reverseGrav = on

func getSaveData() -> Dictionary:
	return saveData

func setSaveData(data: Dictionary) -> void:
	if (data.has_all(saveData.keys())): # Check that new data has all the required keys
		saveData = data

func getLoadingSave() -> bool:
	return loadingSave

func saveGame() -> void:
	var tree := get_tree()
	var scene := tree.current_scene
	var playerContronller := scene.find_node("PlayerController")
	saveData.playerPos = playerContronller.find_node("Player").global_position
	saveData.scene = scene.filename
	saveData.reverseGrav = reverseGrav

# Monitor tree change and if scene changed apply post scene finishing effects
func onTreeChange() -> void:
	var tree := get_tree()
	if (tree != null):
		if (currentScene != tree.current_scene):
			currentScene = tree.current_scene
			if (currentScene != null):
				onSceneFinished()

func loadGame() -> void:
	var tree := get_tree()
	loadingSave = true
	# Load data
	reverseGrav = saveData.reverseGrav
	tree.change_scene(saveData.scene)

# Wrapper for call_group_flags(tree.GROUP_CALL_REALTIME, groupName, funcName)
func callGroup(groupName: String, funcName: String) -> void:
	var tree := get_tree()
	tree.call_group_flags(tree.GROUP_CALL_REALTIME, groupName, funcName)

func onSceneFinished() -> void:
	var tree := get_tree()
	print("Applying global effects after scene building")
	callGroup("Saved", "sceneBuilt")
	if (reverseGrav): # Reverse gravity of all objects that need it
		callGroup("GravityAffected", "reverseGravity")
	loadingSave = false
