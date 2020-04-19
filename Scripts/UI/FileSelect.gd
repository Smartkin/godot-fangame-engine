extends Control

# Save slot object
const SaveSlotUI := preload("res://Objects/UI/FileSelect/SaveTabTemplate.tscn")

export(String, FILE, "*.tscn") var start_scene # Scene from which the game starts

func _ready() -> void:
	for i in range(WorldController.SAVE_FILES):
		# Fill the tab container with save slots
		var slot_ui := SaveSlotUI.instance()
		slot_ui.name = "Save " + str(i + 1)
		# Connect to new/load game button presses
		slot_ui.connect("load_game_pressed", self, "_on_Save_LoadGamePressed")
		slot_ui.connect("new_game_pressed", self, "_on_Save_NewGamePressed")
		$SaveSlots.add_child(slot_ui)
		# Get save data from all the slots
		var save_data := WorldController.get_game_data(i)
		var label := get_node("SaveSlots/Save " + str(i + 1) +"/SaveData") as Label
		if (save_data.message != "No data"):
			label.text = "Death: " + str(save_data.deaths)
			label.text += "\nTime: " + WorldController.get_time_string_formatted(save_data.time)
			label.text += "\nScene: " + str(save_data.sceneName)
		else:
			var load_button := get_node("SaveSlots/Save " + str(i + 1) +"/Load") as Button
			load_button.disabled = true
			label.text = save_data.message
	# Disable load button if no save data is present
	var load_button := $"SaveSlots/Save 1/Load" as Button
	if (load_button.disabled):
		$"SaveSlots/Save 1/New".grab_focus()
	else:
		load_button.grab_focus()


func _input(event: InputEvent) -> void:
	# Switch save tabs with keyboard/controller input
	if (event.is_action_pressed("left")):
		$SaveSlots.current_tab = clamp($SaveSlots.current_tab - 1, 0, $SaveSlots.get_tab_count() - 1)
	if (event.is_action_pressed("right")):
		$SaveSlots.current_tab = clamp($SaveSlots.current_tab + 1, 0, $SaveSlots.get_tab_count() - 1)


func _start_new_game() -> void:
	WorldController.game_started = true
	WorldController.new_game_started = true
	get_tree().change_scene(start_scene)


func _on_SaveSlots_tab_changed(tab: int) -> void:
	var load_button := get_node("SaveSlots/Save " + str(tab + 1) +"/Load") as Button
	if (load_button.disabled):
		get_node("SaveSlots/Save " + str(tab + 1) +"/New").grab_focus()
	else:
		load_button.grab_focus()
	WorldController.save_slot = tab


func _on_Save_NewGamePressed() -> void:
	_start_new_game()


func _on_Save_LoadGamePressed() -> void:
	WorldController.game_started = true
	WorldController.load_game(true)
