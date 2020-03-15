extends Control

export(String, FILE, "*.tscn") var startScene

var saveSlotUI := preload("res://Objects/UI/FileSelect/SaveTabTemplate.tscn")

func _ready() -> void:
	for i in range(WorldController.SAVE_FILES):
		# Fill the tab container with save slots
		var slotUI := saveSlotUI.instance()
		slotUI.name = "Save " + str(i + 1)
		# Connect to new/load game button presses
		slotUI.connect("LoadGamePressed", self, "_on_Save_LoadGamePressed")
		slotUI.connect("NewGamePressed", self, "_on_Save_NewGamePressed")
		$SaveSlots.add_child(slotUI)
		# Get save data from all the slots
		var saveData := WorldController.getGameData(i)
		var label := get_node("SaveSlots/Save " + str(i + 1) +"/SaveData") as Label
		if (saveData.message != "No data"):
			label.text = "Death: " + str(saveData.deaths)
			label.text += "\nTime: " + WorldController.getTimeStringFormatted(saveData.time)
			label.text += "\nScene: " + str(saveData.sceneName)
		else:
			var loadButton := get_node("SaveSlots/Save " + str(i + 1) +"/Load") as Button
			loadButton.disabled = true
			label.text = saveData.message
	var loadButton := $"SaveSlots/Save 1/Load" as Button
	if (loadButton.disabled):
		$"SaveSlots/Save 1/New".grab_focus()
	else:
		loadButton.grab_focus()

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("pl_left")):
		$SaveSlots.current_tab = clamp($SaveSlots.current_tab - 1, 0, $SaveSlots.get_tab_count() - 1)
	if (event.is_action_pressed("pl_right")):
		$SaveSlots.current_tab = clamp($SaveSlots.current_tab + 1, 0, $SaveSlots.get_tab_count() - 1)

func _on_SaveSlots_tab_changed(tab: int) -> void:
	var loadButton := get_node("SaveSlots/Save " + str(tab + 1) +"/Load") as Button
	if (loadButton.disabled):
		get_node("SaveSlots/Save " + str(tab + 1) +"/New").grab_focus()
	else:
		loadButton.grab_focus()
	WorldController.saveSlot = tab

func startNewGame() -> void:
	WorldController.gameStarted = true
	WorldController.startNewGame = true
	get_tree().change_scene(startScene)

func _on_Save_NewGamePressed() -> void:
	startNewGame()

func _on_Save_LoadGamePressed():
	WorldController.gameStarted = true
	WorldController.loadGame(true)
