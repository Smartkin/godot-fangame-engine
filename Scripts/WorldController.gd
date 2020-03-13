extends Node

const SAVE_FILES := 3

# Public members
var reverseGrav := false setget setGrav, getGrav
var saveData := {
	"playerPosX": 0, # JSON doesn't support Vector2
	"playerPosY": 0,
	"deaths": 0,
	"time": "",
	"scene": "res://TestBed2.tscn",
	"reverseGrav": false
} setget setSaveData, getSaveData
var saveSlot := 0 setget setSaveSlot, getSaveSlot
var gameStarted := false
var startNewGame := false

# Readonly
var loadingSave := false setget , getLoadingSave
var globalData := {
	"playerPosX": 0, # JSON doesn't support Vector2
	"playerPosY": 0,
	"deaths": 0,
	"time": "",
	"scene": "res://TestBed2.tscn",
	"reverseGrav": false
} setget , getGlobalData

# Private
var currentScene: Node = null
var sandboxedSaves := true # Whether saves are stored in user's APPDATA or along with exe file
var saveFilePath := "save0" if !sandboxedSaves else "user://save0"

func _ready() -> void:
	print("World created")
	get_tree().connect("tree_changed", self, "onTreeChange")

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("pl_reset") && gameStarted):
		loadGame()

func getGrav() -> bool:
	if (loadingSave):
		return !saveData.reverseGrav
	return reverseGrav

func setGrav(on: bool) -> void:
	reverseGrav = on

func getGlobalData() -> Dictionary:
	return globalData

func getSaveData() -> Dictionary:
	return saveData

func setSaveData(data: Dictionary) -> void:
	if (data.has_all(saveData.keys())): # Check that new data has all the required keys
		saveData = data

func getSaveSlot() -> int:
	return saveSlot

func setSaveSlot(slot: int) -> void:
	if (slot >= 0 && slot < SAVE_FILES):
		if (!sandboxedSaves):
			saveFilePath = "save" + String(slot)
		else:
			saveFilePath = "user://save" + String(slot)
		saveSlot = slot

func getLoadingSave() -> bool:
	return loadingSave

func saveGame() -> void:
	var tree := get_tree()
	var scene := tree.current_scene
	var playerController := scene.find_node("PlayerController")
	if (playerController != null && !playerController.playerDead):
		# Transfer needed data
		globalData.playerPosX = playerController.find_node("Player").global_position.x
		globalData.playerPosY = playerController.find_node("Player").global_position.y
		globalData.scene = scene.filename
		globalData.reverseGrav = reverseGrav
		
		# Save the data to a file
		saveToFile()

func saveToFile() -> void:
	# Create/Open save file
	var saveFile := File.new()
	saveFile.open(saveFilePath, File.WRITE)
	
	# Save needed data
	saveData = globalData
	
	# Write to save file
	saveFile.store_string(to_json(saveData))
	saveFile.close()

# Monitor tree change and if scene changed apply post scene finishing effects
func onTreeChange() -> void:
	var tree := get_tree()
	if (tree != null):
		if (currentScene != tree.current_scene):
			currentScene = tree.current_scene
			if (currentScene != null):
				onSceneFinished()

func loadGame(loadFromSave := false) -> void:
	var tree := get_tree()
	loadingSave = true
	if (loadFromSave):
		var loadFile := File.new()
		if (!loadFile.file_exists(saveFilePath)):
			print("FILE WAS NOT FOUND!")
		loadFile.open(saveFilePath, File.READ)
		saveData = parse_json(loadFile.get_line())
		globalData = saveData
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
	if (startNewGame):
		saveGame()
		startNewGame = false
	# Tell objects that are saved in any manner that the scene finished building
	callGroup("Saved", "sceneBuilt")
	if (reverseGrav): # Reverse gravity of all objects that need it
		callGroup("GravityAffected", "reverseGravity")
	loadingSave = false
