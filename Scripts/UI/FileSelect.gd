extends Control

export(String, FILE, "*.tscn") var startScene

func _ready() -> void:
	$"SaveSlots/Save 1/Load".grab_focus()

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("pl_left")):
		$SaveSlots.current_tab = clamp($SaveSlots.current_tab - 1, 0,$SaveSlots.get_tab_count() - 1)
	if (event.is_action_pressed("pl_right")):
		$SaveSlots.current_tab = clamp($SaveSlots.current_tab + 1, 0,$SaveSlots.get_tab_count() - 1)

func _on_SaveSlots_tab_changed(tab: int) -> void:
	get_node("SaveSlots/Save " + String(tab + 1) +"/Load").grab_focus()
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
