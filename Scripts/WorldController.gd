extends Node

# Enums
enum BUTTON_PROMPTS {
	KEYBOARD,
	PLAYSTATION,
	XBOX,
	GENERIC_CONTROLLER,
}

# Constants
const SAVE_FILES := 3 # Amount of save slots
const SAVE_PASSWORD := "Change me!" # Save's encryption password
const SAVE_FILE_NAME := "save" # Save file's name
const CONFIG_FILE_NAME := "config.cfg" # Config's file name
const ENCRYPT_SAVES := false # Whether saves should be encrypted
const TIME_FORMAT := "%02d:%02d:%02d.%03d" # Time format of 00:00:00.000
const SANDBOXED_SAVES := true # Whether saves are stored in user's APPDATA or along with exe file
const DEBUG_MODE := true # Whether debug mode is turned on
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
	"reverse_grav": false,
}
const DEFAULT_CONFIG := { # Default config when user starts the game
	"music": true,
	"volume_master": 1.0,
	"volume_music": 0.5,
	"volume_sfx": 0.5,
	"fullscreen": false,
	"borderless": false,
	"vsync": false,
	"button_prompts": BUTTON_PROMPTS.KEYBOARD,
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
		"pause": ord("P"),
	},
	"controller_controls": {
		"left": JOY_DPAD_LEFT,
		"right": JOY_DPAD_RIGHT,
		"up": JOY_DPAD_UP,
		"down": JOY_DPAD_DOWN,
		"jump": JOY_SONY_X,
		"shoot": JOY_SONY_SQUARE,
		"restart": JOY_SONY_TRIANGLE,
		"skip": JOY_SONY_CIRCLE,
		"suicide": JOY_SELECT,
		"pause": JOY_START,
	},
}

# Public members
var reverse_grav := false setget set_reverse_grav, get_reverse_grav # Whether gravity is currently inverted
var save_slot := 0 setget set_save_slot, get_save_slot # Currently played on save slot
var game_started := false # Whether game has started
var new_game_started := false # Whether new game has been started
var music_to_play := "" setget set_music, get_music # What music to play on scene change

# Public readonly
var loading_save := false setget , get_loading_save # Whether save load is in progress
var cur_save_data := {} setget , get_cur_save_data # Currently stored global/save data, see _ready() for default value
var cur_config := {} setget , get_cur_config # Current user configuration, see _ready() for default value
var game_paused := false setget , get_game_paused # Whether game is currently paused

# Private, while Godot still allows to access members freely from the outside
# these should never be accessed anywhere outside of this script
var _cur_scene: Node = null # Currently played scene
var _save_data := {} # Current save data that is loaded upon restart button pressing, see _ready() for default value
var _window_caption: String = ProjectSettings.get_setting("application/config/name") # Game's window caption
var _prev_win_cap := "" # Game's previously set window caption
var _music_files := {} # Loaded music files
var _ui_sfx := {} # Loaded UI sfx
var _cur_song := "" # Currently played song filename
var _pause_menu := preload("res://Objects/UI/PauseMenu.tscn") # Pause menu object
var _transition := preload("res://Objects/Transition.tscn") # Transition object
var _cur_pause_menu: Node = null # Current pause menu object instance
var _cur_transition: Node = null # Current transition object instance
var _scene_tree: SceneTree = null # Game's scene tree
var _is_fade_music := false # Whether we are currently fading the music
var _fade_val := 1.0 # Current fade out value

func _ready() -> void:
	print("World created")
	_scene_tree = get_tree() # Get game's scene tree
	pause_mode = PAUSE_MODE_PROCESS # Set pause mode to not affect World
	# Set the default values of global save data and user configuration
	cur_save_data = EMPTY_SAVE.duplicate(true)
	_save_data = EMPTY_SAVE.duplicate(true)
	cur_config = DEFAULT_CONFIG.duplicate(true)
	# Init the global music player
	var music_node := AudioStreamPlayer.new()
	music_node.name = "MusicPlayer"
	music_node.bus = "Music"
	add_child(music_node)
	assert(SAVE_FILES > 0) # Make sure that we have more than 0 save slots
	_scene_tree.connect("tree_changed", self, "_on_tree_changed") # Tracks when scene finishes building
	connect("tree_exiting", self, "_on_game_ended") # Connect to game ending signal
	_load_music() # Load music
	_load_ui_sfx() # Load UI sfx
	_load_config() # Load user's configuration

# Any globally handled user input
func _input(event: InputEvent) -> void:
	if (game_started):
		if (event.is_action_pressed("restart")):
			load_game()
		if (event.is_action_pressed("pause")):
			pause_game()
	if (DEBUG_MODE && !game_started):
		if (event.is_action_pressed("restart")):
			_scene_tree.change_scene(_scene_tree.current_scene.filename)
	if (Input.is_key_pressed(KEY_F2)):
		restart_game()


# Any additional processing you wanna do every game frame
func _process(delta):
	# In-game time, doesn't include pausing
	if (game_started && !game_paused):
		cur_save_data.time.milliseconds += delta * 1000
		if (cur_save_data.time.milliseconds >= 1000):
			cur_save_data.time.seconds += 1
			cur_save_data.time.milliseconds -= 1000
			if (cur_save_data.time.seconds >= 60):
				cur_save_data.time.minutes += 1
				cur_save_data.time.seconds -= 60
				if (cur_save_data.time.minutes >= 60):
					cur_save_data.time.hours += 1
					cur_save_data.time.minutes -= 60
	var win_cap = _window_caption
	if (game_started): # Add additional caption if game started
		win_cap += " -" + " Deaths: " + str(cur_save_data.deaths)
		win_cap += " Time: " + get_time_string_formatted(cur_save_data.time).substr(0, 8)
	# We only want to change title when it actually changed
	# OS calls are quite taxing on performance
	if (win_cap != _prev_win_cap):
		OS.set_window_title(win_cap)
		_prev_win_cap = win_cap
	if _is_fade_music:
		_fade_music(delta)

# Plays a UI sfx
func play_ui_sfx(fileName: String) -> void:
	var ui_sfx_node := AudioStreamPlayer.new()
	ui_sfx_node.name = "UiSfxPlayer"
	ui_sfx_node.bus = "Sfx"
	add_child(ui_sfx_node)
	assert(_ui_sfx[fileName + ".wav.import"] != null)
	ui_sfx_node.stream = _ui_sfx[fileName + ".wav.import"]
	ui_sfx_node.play()
	ui_sfx_node.connect("finished", ui_sfx_node, "queue_free")

# Plays a specified music track
func play_music(fileName := "") -> void:
	if (cur_config.music): # Check that music is currently turned on
		_is_fade_music = false
		Util.set_volume("Master", cur_config.volume_master)
		var music_player := $MusicPlayer as AudioStreamPlayer
		if (_cur_song != fileName && fileName != ""):
			# Make sure we will play a loaded song
			assert(_music_files[fileName + ".ogg.import"] != null)
			music_player.stream = _music_files[fileName + ".ogg.import"]
			music_player.play()
			_cur_song = fileName
		if (fileName == ""): # If no file was specified stop playing music
			stop_music()
		if (music_to_play != ""): # Reset music to play so it stops any music from playing when no music object is provided
			music_to_play = ""

func pitch_music(pitch: float) -> void:
	var music_player := $MusicPlayer as AudioStreamPlayer
	music_player.pitch_scale = pitch

func fade_music() -> void:
	if not _is_fade_music:
		_fade_val = 1.0
	_is_fade_music = true

func _fade_music(delta: float) -> void:
	if _fade_val > 0:
		Util.set_volume("Master", _fade_val * cur_config.volume_master)
		_fade_val -= 1 * delta
	else:
		_fade_val = 1
		_is_fade_music = false

func stop_music() -> void:
	var music_player := $MusicPlayer as AudioStreamPlayer
	_cur_song = ""
	music_player.stop()

func get_music() -> String:
	return music_to_play

func set_music(fileName: String) -> void:
	music_to_play = fileName

# Get time string in 00:00:00.000 format
func get_time_string_formatted(timeJson: Dictionary) -> String:
	return TIME_FORMAT % [timeJson.hours, timeJson.minutes, timeJson.seconds, timeJson.milliseconds]

func pause_game() -> void:
	# Pause/unpause scene tree
	_scene_tree.paused = !_scene_tree.paused
	game_paused = !game_paused
	if (game_paused): # If we are paused, spawn the pause menu object
		_cur_pause_menu = _pause_menu.instance()
		add_child(_cur_pause_menu)
	else: # Otherwise delete it
		_cur_pause_menu.queue_free()

func restart_game():
	save_to_file() # Save death/time
	if (game_paused):
		pause_game() # Unpause the game if it was paused
	_scene_tree.change_scene(ProjectSettings.get_setting("application/run/main_scene"))
	game_started = false

func get_reverse_grav() -> bool:
	if (loading_save):
		return !_save_data.reverse_grav
	return reverse_grav

func get_game_paused() -> bool:
	return game_paused

func set_reverse_grav(on: bool) -> void:
	reverse_grav = on

func get_cur_save_data() -> Dictionary:
	return cur_save_data

func get_save_slot() -> int:
	return save_slot

func get_cur_config() -> Dictionary:
	return cur_config

func set_save_slot(slot: int) -> void:
	if (slot >= 0 && slot < SAVE_FILES):
		save_slot = slot

func get_loading_save() -> bool:
	return loading_save

func free_transition() -> void:
	_cur_transition = null

func do_transition() -> void:
	if _cur_transition != null:
		_cur_transition.queue_free()
		free_transition()
	_cur_transition = _transition.instance()
	add_child(_cur_transition)

func do_post_transition() -> void:
	do_transition()
	_cur_transition.set_time(1.0)
	_cur_transition.set_state(_cur_transition.STATE.TO)

# Save player's configuration
func save_config() -> void:
	var config := ConfigFile.new()
	config.set_value("General", "music", cur_config.music)
	config.set_value("General", "volume_master", cur_config.volume_master)
	config.set_value("General", "volume_music", cur_config.volume_music)
	config.set_value("General", "volume_sfx", cur_config.volume_sfx)
	config.set_value("General", "fullscreen", cur_config.fullscreen)
	config.set_value("General", "borderless", cur_config.borderless)
	config.set_value("General", "vsync", cur_config.vsync)
	config.set_value("General", "button_prompts", cur_config.button_prompts)
	config.set_value("keyboard", "left", cur_config.keyboard_controls.left)
	config.set_value("keyboard", "right", cur_config.keyboard_controls.right)
	config.set_value("keyboard", "up", cur_config.keyboard_controls.up)
	config.set_value("keyboard", "down", cur_config.keyboard_controls.down)
	config.set_value("keyboard", "jump", cur_config.keyboard_controls.jump)
	config.set_value("keyboard", "shoot", cur_config.keyboard_controls.shoot)
	config.set_value("keyboard", "restart", cur_config.keyboard_controls.restart)
	config.set_value("keyboard", "skip", cur_config.keyboard_controls.skip)
	config.set_value("keyboard", "suicide", cur_config.keyboard_controls.suicide)
	config.set_value("keyboard", "pause", cur_config.keyboard_controls.pause)
	config.set_value("controller", "left", cur_config.controller_controls.left)
	config.set_value("controller", "right", cur_config.controller_controls.right)
	config.set_value("controller", "up", cur_config.controller_controls.up)
	config.set_value("controller", "down", cur_config.controller_controls.down)
	config.set_value("controller", "jump", cur_config.controller_controls.jump)
	config.set_value("controller", "shoot", cur_config.controller_controls.shoot)
	config.set_value("controller", "restart", cur_config.controller_controls.restart)
	config.set_value("controller", "skip", cur_config.controller_controls.skip)
	config.set_value("controller", "suicide", cur_config.controller_controls.suicide)
	config.set_value("controller", "pause", cur_config.controller_controls.pause)
	config.save(_get_config_path())


func save_game() -> void:
	var tree := _scene_tree
	var scene := tree.current_scene
	var player_controller := scene.find_node("PlayerController")
	if (player_controller != null && !player_controller.player_dead):
		# Transfer needed data
		cur_save_data.playerPosX = player_controller.find_node("Player").global_position.x
		cur_save_data.playerPosY = player_controller.find_node("Player").global_position.y
		cur_save_data.scene = scene.filename
		cur_save_data.sceneName = scene.name
		cur_save_data.reverse_grav = reverse_grav
		# Save the data to a file
		save_to_file()

# Load game data for a chosen save slot
func get_game_data(slot: int) -> Dictionary:
	var load_file := File.new()
	var data := {}
	if (!load_file.file_exists(_get_save_path(slot))):
		# Set a message that no save file or data is present
		data.message = "No data"
		return data
	_open_save_file(load_file, slot, File.READ)
	data = parse_json(load_file.get_line())
	data.message = "Has data"
	return data

func load_game(loadFromSave := false) -> void:
	var tree := _scene_tree
	loading_save = true
	if (loadFromSave):
		var load_file := File.new()
		if (!load_file.file_exists(_get_save_path(save_slot))):
			# Realistically this should never happen but as a safe guard
			# this is here as a debug check
			print("FILE WAS NOT FOUND!")
			print_stack()
			return
		_open_save_file(load_file, save_slot, File.READ)
		_save_data = parse_json(load_file.get_line())
		cur_save_data = _save_data
	# Load data
	reverse_grav = _save_data.reverse_grav
	tree.change_scene(_save_data.scene)

func save_to_file() -> void:
	# Create/Open save file
	var save_file := File.new()
	_open_save_file(save_file, save_slot, File.WRITE)
	# Save needed data
	_save_data = cur_save_data
	# Write to save file
	save_file.store_string(to_json(_save_data))
	save_file.close()


func _get_save_path(slot: int) -> String:
	return (SAVE_FILE_NAME + String(slot)) if (!SANDBOXED_SAVES) else ("user://" + SAVE_FILE_NAME + String(slot))

func _get_config_path() -> String:
	return (CONFIG_FILE_NAME) if (!SANDBOXED_SAVES) else ("user://" + CONFIG_FILE_NAME)


func _open_save_file(file: File, slot: int, mode: int):
	if (!ENCRYPT_SAVES): # Check if we encrypt save files
		file.open(_get_save_path(slot), mode)
	else:
		file.open_encrypted_with_pass(_get_save_path(slot), mode, SAVE_PASSWORD)

# Loads all the music into memory for faster access later on
func _load_music() -> void:
	var music_dir := Directory.new()
	music_dir.open("res://Music")
	music_dir.list_dir_begin(true)
	_load_music_recursively(music_dir)

# Load music from all included folders so we can neatly sort the music
# e.g. into stages
func _load_music_recursively(cur_dir: Directory) -> void:
	var music_file_or_dir := cur_dir.get_next()
	while (music_file_or_dir != ""):
		if (music_file_or_dir.ends_with(".ogg.import")):
			var import_file := ConfigFile.new()
			var er := import_file.load(cur_dir.get_current_dir() + "/" + music_file_or_dir)
			_music_files[music_file_or_dir] = load(import_file.get_value("remap", "path"))
		elif (cur_dir.dir_exists(music_file_or_dir)):
			var newDir = Directory.new()
			newDir.open(cur_dir.get_current_dir() + "/" + music_file_or_dir)
			newDir.list_dir_begin(true)
			_load_music_recursively(newDir)
		music_file_or_dir = cur_dir.get_next()

func _load_ui_sfx() -> void:
	var sfx_dir := Directory.new()
	sfx_dir.open("res://Sounds/UI")
	sfx_dir.list_dir_begin(true)
	_load_ui_sfx_recursively(sfx_dir)


func _load_ui_sfx_recursively(cur_dir: Directory) -> void:
	var sfx_file_or_dir := cur_dir.get_next()
	while (sfx_file_or_dir != ""):
		if (sfx_file_or_dir.ends_with(".wav.import")):
			var import_file := ConfigFile.new()
			var er := import_file.load(cur_dir.get_current_dir() + "/" + sfx_file_or_dir)
			_ui_sfx[sfx_file_or_dir] = load(import_file.get_value("remap", "path"))
		elif (cur_dir.dir_exists(sfx_file_or_dir)):
			var new_dir = Directory.new()
			new_dir.open(cur_dir.get_current_dir() + "/" + sfx_file_or_dir)
			new_dir.list_dir_begin(true)
			_load_ui_sfx_recursively(new_dir)
		sfx_file_or_dir = cur_dir.get_next()

# Load player's configuration
func _load_config() -> void:
	var config := ConfigFile.new()
	var err := config.load(_get_config_path())
	if err != OK:
		save_config()
		_load_config()
	else:
		cur_config.music = config.get_value("General", "music", DEFAULT_CONFIG.music)
		cur_config.volume_master = config.get_value("General", "volume_master", DEFAULT_CONFIG.volume_master)
		cur_config.volume_music = config.get_value("General", "volume_music", DEFAULT_CONFIG.volume_music)
		cur_config.volume_sfx = config.get_value("General", "volume_sfx", DEFAULT_CONFIG.volume_sfx)
		cur_config.fullscreen = config.get_value("General", "fullscreen", DEFAULT_CONFIG.fullscreen)
		cur_config.borderless = config.get_value("General", "borderless", DEFAULT_CONFIG.borderless)
		cur_config.vsync = config.get_value("General", "vsync", DEFAULT_CONFIG.vsync)
		cur_config.button_prompts = config.get_value("General", "button_prompts", DEFAULT_CONFIG.button_prompts)
		cur_config.keyboard_controls.left = config.get_value("keyboard", "left", DEFAULT_CONFIG.keyboard_controls.left)
		cur_config.keyboard_controls.right = config.get_value("keyboard", "right", DEFAULT_CONFIG.keyboard_controls.right)
		cur_config.keyboard_controls.up = config.get_value("keyboard", "up", DEFAULT_CONFIG.keyboard_controls.up)
		cur_config.keyboard_controls.down = config.get_value("keyboard", "down", DEFAULT_CONFIG.keyboard_controls.down)
		cur_config.keyboard_controls.jump = config.get_value("keyboard", "jump", DEFAULT_CONFIG.keyboard_controls.jump)
		cur_config.keyboard_controls.shoot = config.get_value("keyboard", "shoot", DEFAULT_CONFIG.keyboard_controls.shoot)
		cur_config.keyboard_controls.restart = config.get_value("keyboard", "restart", DEFAULT_CONFIG.keyboard_controls.restart)
		cur_config.keyboard_controls.skip = config.get_value("keyboard", "skip", DEFAULT_CONFIG.keyboard_controls.skip)
		cur_config.keyboard_controls.suicide = config.get_value("keyboard", "suicide", DEFAULT_CONFIG.keyboard_controls.suicide)
		cur_config.keyboard_controls.pause = config.get_value("keyboard", "pause", DEFAULT_CONFIG.keyboard_controls.pause)
		cur_config.controller_controls.left = config.get_value("controller", "left", DEFAULT_CONFIG.controller_controls.left)
		cur_config.controller_controls.right = config.get_value("controller", "right", DEFAULT_CONFIG.controller_controls.right)
		cur_config.controller_controls.up = config.get_value("controller", "up", DEFAULT_CONFIG.controller_controls.up)
		cur_config.controller_controls.down = config.get_value("controller", "down", DEFAULT_CONFIG.controller_controls.down)
		cur_config.controller_controls.jump = config.get_value("controller", "jump", DEFAULT_CONFIG.controller_controls.jump)
		cur_config.controller_controls.shoot = config.get_value("controller", "shoot", DEFAULT_CONFIG.controller_controls.shoot)
		cur_config.controller_controls.restart = config.get_value("controller", "restart", DEFAULT_CONFIG.controller_controls.restart)
		cur_config.controller_controls.skip = config.get_value("controller", "skip", DEFAULT_CONFIG.controller_controls.skip)
		cur_config.controller_controls.suicide = config.get_value("controller", "suicide", DEFAULT_CONFIG.controller_controls.suicide)
		cur_config.controller_controls.pause = config.get_value("controller", "pause", DEFAULT_CONFIG.controller_controls.pause)
		_apply_config()

# Apply's just loaded configuration, only used on start up
func _apply_config() -> void:
	OS.window_borderless = cur_config.borderless
	OS.window_fullscreen = cur_config.fullscreen
	OS.vsync_enabled = cur_config.vsync
	# Set channel volumes
	Util.set_volume("Master", cur_config.volume_master)
	Util.set_volume("Music", cur_config.volume_music)
	Util.set_volume("Sfx", cur_config.volume_sfx)
	# Add keyboard binds
	for keyboard_control in cur_config.keyboard_controls:
		var ev := InputEventKey.new()
		ev.scancode = cur_config.keyboard_controls[keyboard_control]
		InputMap.action_add_event(keyboard_control, ev)
	# Add controller binds
	for controller_controls in cur_config.controller_controls:
		if (controller_controls == "controller"):
			continue
		var ev := InputEventJoypadButton.new()
		ev.button_index = cur_config.controller_controls[controller_controls]
		ev.pressed = true
		InputMap.action_add_event(controller_controls, ev)

# Monitor tree change and if scene changed apply post scene finishing effects
func _on_tree_changed() -> void:
	var tree := _scene_tree
	if (tree != null):
		if (_cur_scene != tree.current_scene):
			_cur_scene = tree.current_scene
			if (_cur_scene != null):
				_on_scene_finished()

# Tracks when the game was ended by the player
func _on_game_ended() -> void:
	print("Game ended. World destroyed")
	if (game_started):
		save_to_file() # Save death/time

# Called when scene is finished building
func _on_scene_finished() -> void:
	print("Scene finished building")
	play_music(music_to_play)
	if (new_game_started):
		cur_save_data = EMPTY_SAVE.duplicate(true)
		save_game()
		new_game_started = false
	# Tell objects that are in the saved group that the scene finished building
	Util.call_group("Saved", "_on_scene_built")
	if (reverse_grav): # Reverse gravity of all objects that need to
		Util.call_group("GravityAffected", "_reverse_gravity")
	loading_save = false
