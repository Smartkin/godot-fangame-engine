extends Node

# Constants
const SAVE_FILES := 3 # Amount of save slots
const SAVE_PASSWORD := "Change me!" # Save's encryption password
const SAVE_FILE_NAME := "save" # Save file's name
const ENCRYPT_SAVES := false # Whether saves should be encrypted
const TIME_FORMAT := "%02d:%02d:%02d.%03d" # Time format of 00:00:00.000
const EMPTY_SAVE := { # Default save data when no save is present
	"playerPosX": 0, # JSON doesn't support Vector2
	"playerPosY": 0,
	"deaths": 0,
	"time": {
		"hours": 0,
		"minutes": 0,
		"seconds": 0,
		"milliseconds": 0
	},
	"scene": "res://TestBed.tscn",
	"sceneName": "TestBed",
	"reverseGrav": false
}

# Public members
var reverseGrav := false setget setGrav, getGrav # Whether gravity is currently inverted
var saveSlot := 0 setget setSaveSlot, getSaveSlot # Currently played on save slot
var gameStarted := false # Whether game has started
var startNewGame := false # Whether new game has been started
var musicToPlay := "" setget setMusic, getMusic # What music to play on scene change

# Readonly
var loadingSave := false setget , getLoadingSave
var globalData := EMPTY_SAVE setget , getGlobalData

# Private, while Godot still allows to access members freely from the outside
# these should never be accessed anywhere outside of this script
var currentScene: Node = null
var saveData := EMPTY_SAVE
var sandboxedSaves := true # Whether saves are stored in user's APPDATA or along with exe file
var windowCaption: String = ProjectSettings.get_setting("application/config/name")
var prevWinCap := ""
var musicFiles := {}
var currentSong := ""

func _ready() -> void:
	print("World created")
	var musicNode := AudioStreamPlayer.new()
	musicNode.name = "MusicPlayer"
	musicNode.bus = "Music"
	add_child(musicNode)
	assert(SAVE_FILES > 0)
	get_tree().connect("tree_changed", self, "onTreeChange") # Tracks when scene finishes building
	connect("tree_exiting", self, "onGameEnd")
	loadMusic() # Load music

# Loads all the music into memory for faster access later on
func loadMusic() -> void:
	var musicDir := Directory.new()
	musicDir.open("res://Music")
	musicDir.list_dir_begin(true)
	var musicFile := musicDir.get_next()
	while (musicFile != ""):
		print(musicDir.get_current_dir() + "/" + musicFile)
		if (musicFile.ends_with(".ogg")):
			musicFiles[musicFile] = load(musicDir.get_current_dir() + "/" + musicFile)
		musicFile = musicDir.get_next()

func playMusic(fileName := "") -> void:
	var musicPlayer := $MusicPlayer as AudioStreamPlayer
	if (currentSong != fileName && fileName != ""):
		musicPlayer.stream = musicFiles[fileName + ".ogg"]
		musicPlayer.play()
		currentSong = fileName
	if (fileName == ""):
		musicPlayer.stop()
	if (musicToPlay != ""): # Reset music to play so it stops any music from playing when no music object is provided
		musicToPlay = ""

func getMusic() -> String:
	return musicToPlay

func setMusic(fileName: String) -> void:
	musicToPlay = fileName

func onGameEnd() -> void:
	print("Game ended. World destroyed")
	if (gameStarted):
		saveToFile() # Save death/time

func getTimeStringFormatted(timeJson: Dictionary) -> String:
	return TIME_FORMAT % [timeJson.hours, timeJson.minutes, timeJson.seconds, timeJson.milliseconds]

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("pl_reset") && gameStarted):
		loadGame()
	if (Input.is_key_pressed(KEY_F2)):
		restartGame()

func restartGame():
	saveToFile() # Save death/time
	get_tree().change_scene(ProjectSettings.get_setting("application/run/main_scene"))
	gameStarted = false

func openSaveFile(file: File, slot: int, mode: int):
	if (!ENCRYPT_SAVES):
		file.open(getSavePath(slot), mode)
	else:
		file.open_encrypted_with_pass(getSavePath(slot), mode, SAVE_PASSWORD)

func _process(delta):
	if (gameStarted):
		globalData.time.milliseconds += delta * 1000
		if (globalData.time.milliseconds >= 1000):
			globalData.time.seconds += 1
			globalData.time.milliseconds -= 1000
			if (globalData.time.seconds >= 60):
				globalData.time.minutes += 1
				globalData.time.seconds -= 60
				if (globalData.time.minutes >= 60):
					globalData.time.hours += 1
					globalData.time.minutes -= 60
	var winCap = windowCaption
	if (gameStarted): # Add additional caption if game started
		winCap += " -" + " Deaths: " + str(globalData.deaths)
		winCap += " Time: " + getTimeStringFormatted(globalData.time).substr(0, 8)
	# We only want to change title when it actually changed
	# OS calls are quite taxing on performance
	if (winCap != prevWinCap):
		OS.set_window_title(winCap)
		prevWinCap = winCap

func getGrav() -> bool:
	if (loadingSave):
		return !saveData.reverseGrav
	return reverseGrav

func setGrav(on: bool) -> void:
	reverseGrav = on

func getGlobalData() -> Dictionary:
	return globalData

func getSaveSlot() -> int:
	return saveSlot

func getSavePath(slot: int) -> String:
	return (SAVE_FILE_NAME + String(slot)) if (!sandboxedSaves) else ("user://" + SAVE_FILE_NAME + String(slot))

func setSaveSlot(slot: int) -> void:
	if (slot >= 0 && slot < SAVE_FILES):
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
		globalData.sceneName = scene.name
		globalData.reverseGrav = reverseGrav
		
		# Save the data to a file
		saveToFile()

func getGameData(slot: int) -> Dictionary:
	var loadFile := File.new()
	var data := {}
	if (!loadFile.file_exists(getSavePath(slot))):
		data.message = "No data"
		return data
	openSaveFile(loadFile, slot, File.READ)
	data = parse_json(loadFile.get_line())
	data.message = "Has data"
	return data

func loadGame(loadFromSave := false) -> void:
	var tree := get_tree()
	loadingSave = true
	if (loadFromSave):
		var loadFile := File.new()
		if (!loadFile.file_exists(getSavePath(saveSlot))):
			print("FILE WAS NOT FOUND!")
			return
		openSaveFile(loadFile, saveSlot, File.READ)
		saveData = parse_json(loadFile.get_line())
		globalData = saveData
	# Load data
	reverseGrav = saveData.reverseGrav
	tree.change_scene(saveData.scene)

func saveToFile() -> void:
	# Create/Open save file
	var saveFile := File.new()
	openSaveFile(saveFile, saveSlot, File.WRITE)
	
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

# Wrapper for call_group_flags(tree.GROUP_CALL_REALTIME, groupName, funcName)
func callGroup(groupName: String, funcName: String) -> void:
	var tree := get_tree()
	tree.call_group_flags(tree.GROUP_CALL_REALTIME, groupName, funcName)

func onSceneFinished() -> void:
	print("Scene finished building")
	playMusic(musicToPlay)
	if (startNewGame):
		globalData = EMPTY_SAVE
		saveGame()
		startNewGame = false
	# Tell objects that are in the saved group that the scene finished building
	callGroup("Saved", "sceneBuilt")
	if (reverseGrav): # Reverse gravity of all objects that need to
		callGroup("GravityAffected", "reverseGravity")
	loadingSave = false
