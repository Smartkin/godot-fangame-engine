extends Node

# Constants
const SAVE_FILES := 3 # Amount of save slots
const SAVE_PASSWORD := "Change me!" # Save's encryption password
const SAVE_FILE_NAME := "save" # Save file's name
const CONFIG_FILE_NAME := "config.cfg" # Config's file name
const ENCRYPT_SAVES := false # Whether saves should be encrypted
const TIME_FORMAT := "%02d:%02d:%02d.%03d" # Time format of 00:00:00.000
const SANDBOXED_SAVES := true # Whether saves are stored in user's APPDATA or along with exe file
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
const DEFAULT_CONFIG := { # Default config when user starts the game
	"music": true,
	"volume_master": 1.0,
	"volume_music": 0.5,
	"volume_sfx": 0.5,
	"fullscreen": false,
	"borderless": false,
	"vsync": false,
	"keyboard_controls": {
		"left": KEY_LEFT,
		"right": KEY_RIGHT,
		"up": KEY_UP,
		"down": KEY_DOWN,
		"jump": KEY_SHIFT,
		"shoot": ord("Z"),
		"restart": ord("R"),
		"skip": ord("S"),
		"suicide": ord("Q"),
		"pause": ord("P")
	},
	"controller_controls": {
		"controller": -1,
		"left": JOY_DPAD_LEFT,
		"right": JOY_DPAD_RIGHT,
		"up": JOY_DPAD_UP,
		"down": JOY_DPAD_DOWN,
		"jump": JOY_DS_A,
		"shoot": JOY_DS_X,
		"restart": JOY_DS_B,
		"skip": JOY_DS_Y,
		"suicide": JOY_SELECT,
		"pause": JOY_START
	}
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
var currentConfig := DEFAULT_CONFIG setget , getCurrentConfig

# Private, while Godot still allows to access members freely from the outside
# these should never be accessed anywhere outside of this script
var currentScene: Node = null
var saveData := EMPTY_SAVE
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
	loadConfig() # Load user's configuration

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
	if (currentConfig.music):
		var musicPlayer := $MusicPlayer as AudioStreamPlayer
		if (currentSong != fileName && fileName != ""):
			musicPlayer.stream = musicFiles[fileName + ".ogg"]
			musicPlayer.play()
			currentSong = fileName
		if (fileName == ""):
			musicPlayer.stop()
		if (musicToPlay != ""): # Reset music to play so it stops any music from playing when no music object is provided
			musicToPlay = ""

func stopMusic():
	var musicPlayer := $MusicPlayer as AudioStreamPlayer
	currentSong = ""
	musicPlayer.stop()

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
	return (SAVE_FILE_NAME + String(slot)) if (!SANDBOXED_SAVES) else ("user://" + SAVE_FILE_NAME + String(slot))

func getConfigPath() -> String:
	return (CONFIG_FILE_NAME) if (!SANDBOXED_SAVES) else ("user://" + CONFIG_FILE_NAME)

func getCurrentConfig() -> Dictionary:
	return currentConfig

func setSaveSlot(slot: int) -> void:
	if (slot >= 0 && slot < SAVE_FILES):
		saveSlot = slot

func getLoadingSave() -> bool:
	return loadingSave

func saveConfig() -> void:
	var config := ConfigFile.new()
	config.set_value("General", "music", currentConfig.music)
	config.set_value("General", "volume_master", currentConfig.volume_master)
	config.set_value("General", "volume_music", currentConfig.volume_music)
	config.set_value("General", "volume_sfx", currentConfig.volume_sfx)
	config.set_value("General", "fullscreen", currentConfig.fullscreen)
	config.set_value("General", "borderless", currentConfig.borderless)
	config.set_value("General", "vsync", currentConfig.vsync)
	config.set_value("keyboard", "left", currentConfig.keyboard_controls.left)
	config.set_value("keyboard", "right", currentConfig.keyboard_controls.right)
	config.set_value("keyboard", "up", currentConfig.keyboard_controls.up)
	config.set_value("keyboard", "down", currentConfig.keyboard_controls.down)
	config.set_value("keyboard", "jump", currentConfig.keyboard_controls.jump)
	config.set_value("keyboard", "shoot", currentConfig.keyboard_controls.shoot)
	config.set_value("keyboard", "restart", currentConfig.keyboard_controls.restart)
	config.set_value("keyboard", "skip", currentConfig.keyboard_controls.skip)
	config.set_value("keyboard", "suicide", currentConfig.keyboard_controls.suicide)
	config.set_value("keyboard", "pause", currentConfig.keyboard_controls.pause)
	config.set_value("controller", "controller", currentConfig.controller_controls.controller)
	config.set_value("controller", "left", currentConfig.controller_controls.left)
	config.set_value("controller", "right", currentConfig.controller_controls.right)
	config.set_value("controller", "up", currentConfig.controller_controls.up)
	config.set_value("controller", "down", currentConfig.controller_controls.down)
	config.set_value("controller", "jump", currentConfig.controller_controls.jump)
	config.set_value("controller", "shoot", currentConfig.controller_controls.shoot)
	config.set_value("controller", "restart", currentConfig.controller_controls.restart)
	config.set_value("controller", "skip", currentConfig.controller_controls.skip)
	config.set_value("controller", "suicide", currentConfig.controller_controls.suicide)
	config.set_value("controller", "pause", currentConfig.controller_controls.pause)
	config.save(getConfigPath())

func loadConfig() -> void:
	var config := ConfigFile.new()
	var err := config.load(getConfigPath())
	if err != OK:
		saveConfig()
		loadConfig()
	else:
		currentConfig.music = config.get_value("General", "music", DEFAULT_CONFIG.music)
		currentConfig.volume_master = config.get_value("General", "volume_master", DEFAULT_CONFIG.volume_master)
		currentConfig.volume_music = config.get_value("General", "volume_music", DEFAULT_CONFIG.volume_music)
		currentConfig.volume_sfx = config.get_value("General", "volume_sfx", DEFAULT_CONFIG.volume_sfx)
		currentConfig.fullscreen = config.get_value("General", "fullscreen", DEFAULT_CONFIG.fullscreen)
		currentConfig.borderless = config.get_value("General", "borderless", DEFAULT_CONFIG.borderless)
		currentConfig.vsync = config.get_value("General", "vsync", DEFAULT_CONFIG.vsync)
		currentConfig.keyboard_controls.left = config.get_value("keyboard", "left", DEFAULT_CONFIG.keyboard_controls.left)
		currentConfig.keyboard_controls.right = config.get_value("keyboard", "right", DEFAULT_CONFIG.keyboard_controls.right)
		currentConfig.keyboard_controls.up = config.get_value("keyboard", "up", DEFAULT_CONFIG.keyboard_controls.up)
		currentConfig.keyboard_controls.down = config.get_value("keyboard", "down", DEFAULT_CONFIG.keyboard_controls.down)
		currentConfig.keyboard_controls.jump = config.get_value("keyboard", "jump", DEFAULT_CONFIG.keyboard_controls.jump)
		currentConfig.keyboard_controls.shoot = config.get_value("keyboard", "shoot", DEFAULT_CONFIG.keyboard_controls.shoot)
		currentConfig.keyboard_controls.restart = config.get_value("keyboard", "restart", DEFAULT_CONFIG.keyboard_controls.restart)
		currentConfig.keyboard_controls.skip = config.get_value("keyboard", "skip", DEFAULT_CONFIG.keyboard_controls.skip)
		currentConfig.keyboard_controls.suicide = config.get_value("keyboard", "suicide", DEFAULT_CONFIG.keyboard_controls.suicide)
		currentConfig.keyboard_controls.pause = config.get_value("keyboard", "pause", DEFAULT_CONFIG.keyboard_controls.pause)
		currentConfig.controller_controls.controller = config.get_value("controller", "controller", DEFAULT_CONFIG.controller_controls.controller)
		currentConfig.controller_controls.left = config.get_value("controller", "left", DEFAULT_CONFIG.controller_controls.left)
		currentConfig.controller_controls.right = config.get_value("controller", "right", DEFAULT_CONFIG.controller_controls.right)
		currentConfig.controller_controls.up = config.get_value("controller", "up", DEFAULT_CONFIG.controller_controls.up)
		currentConfig.controller_controls.down = config.get_value("controller", "down", DEFAULT_CONFIG.controller_controls.down)
		currentConfig.controller_controls.jump = config.get_value("controller", "jump", DEFAULT_CONFIG.controller_controls.jump)
		currentConfig.controller_controls.shoot = config.get_value("controller", "shoot", DEFAULT_CONFIG.controller_controls.shoot)
		currentConfig.controller_controls.restart = config.get_value("controller", "restart", DEFAULT_CONFIG.controller_controls.restart)
		currentConfig.controller_controls.skip = config.get_value("controller", "skip", DEFAULT_CONFIG.controller_controls.skip)
		currentConfig.controller_controls.suicide = config.get_value("controller", "suicide", DEFAULT_CONFIG.controller_controls.suicide)
		currentConfig.controller_controls.pause = config.get_value("controller", "pause", DEFAULT_CONFIG.controller_controls.pause)
		applyConfig()

func applyConfig() -> void:
	OS.window_borderless = currentConfig.borderless
	OS.window_fullscreen = currentConfig.fullscreen
	OS.vsync_enabled = currentConfig.vsync
	setVolume("Master", currentConfig.volume_master)
	setVolume("Music", currentConfig.volume_music)
	setVolume("Sfx", currentConfig.volume_sfx)

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

func setVolume(channel: String, value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(channel), linear2db(value))

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
