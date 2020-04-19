extends VBoxContainer

func _ready() -> void:
	var cur_conf := WorldController.cur_config
	$MusicCheckbox.music_value = cur_conf.music
	$MasterVolumeSlider.value = cur_conf.volume_master
	$MasterVolume.text = "Master Volume " + str($MasterVolumeSlider.value * 100) + "%"
	$MusicVolumeSlider.value = cur_conf.volume_music
	$MusicVolume.text = "Music Volume " + str($MusicVolumeSlider.value * 100) + "%"
	$SfxVolumeSlider.value = cur_conf.volume_sfx
	$SfxVolume.text = "Sound Effects Volume " + str($SfxVolumeSlider.value * 100) + "%"
	$FullscreenCheckbox.fullscreen = cur_conf.fullscreen
	$BorderlessCheckbox.borderless = cur_conf.borderless
	$VsyncCheckbox.vsync = cur_conf.vsync
	$ButtonPrompts.selected = cur_conf.button_prompts
	if ($FullscreenCheckbox.fullscreen):
		$BorderlessCheckbox.disabled = true
	else:
		$BorderlessCheckbox.disabled = false
	$MusicCheckbox.grab_focus()


func _on_MusicCheckbox_pressed() -> void:
	$MusicCheckbox.music_value = !$MusicCheckbox.music_value
	WorldController.cur_config.music = $MusicCheckbox.music_value
	if ($MusicCheckbox.music_value):
		WorldController.play_music($"../../MusicPlayer".music)
	else:
		WorldController.stop_music()


func _on_FullscreenCheckbox_pressed() -> void:
	$FullscreenCheckbox.fullscreen = !$FullscreenCheckbox.fullscreen
	WorldController.cur_config.fullscreen = $FullscreenCheckbox.fullscreen
	if ($FullscreenCheckbox.fullscreen):
		$BorderlessCheckbox.disabled = true
	else:
		$BorderlessCheckbox.disabled = false
	OS.window_fullscreen = $FullscreenCheckbox.fullscreen


func _on_BorderlessCheckbox_pressed() -> void:
	$BorderlessCheckbox.borderless = !$BorderlessCheckbox.borderless
	WorldController.cur_config.borderless = $BorderlessCheckbox.borderless
	OS.window_borderless = $BorderlessCheckbox.borderless


func _on_VsyncCheckbox_pressed() -> void:
	$VsyncCheckbox.vsync = !$VsyncCheckbox.vsync
	WorldController.cur_config.vsync = $VsyncCheckbox.vsync
	OS.vsync_enabled = $VsyncCheckbox.vsync



func _on_MasterVolumeSlider_entered() -> void:
	$MasterVolume.add_color_override("font_color", $VsyncCheckbox.get_color("font_color_hover"))


func _on_MasterVolumeSlider_exited() -> void:
	$MasterVolume.add_color_override("font_color", $VsyncCheckbox.get_color("font_color"))


func _on_MusicVolumeSlider_entered() -> void:
	$MusicVolume.add_color_override("font_color", $VsyncCheckbox.get_color("font_color_hover"))


func _on_MusicVolumeSlider_exited() -> void:
	$MusicVolume.add_color_override("font_color", $VsyncCheckbox.get_color("font_color"))


func _on_SfxVolumeSlider_entered() -> void:
	$SfxVolume.add_color_override("font_color", $VsyncCheckbox.get_color("font_color_hover"))


func _on_SfxVolumeSlider_exited() -> void:
	$SfxVolume.add_color_override("font_color", $VsyncCheckbox.get_color("font_color"))


func _on_MasterVolumeSlider_value_changed(value: float) -> void:
	$MasterVolume.text = "Master Volume " + str(value * 100) + "%"
	WorldController.cur_config.volume_master = value
	Util.set_volume("Master", value)


func _on_MusicVolumeSlider_value_changed(value: float) -> void:
	$MusicVolume.text = "Music Volume " + str(value * 100) + "%"
	WorldController.cur_config.volume_music = value
	Util.set_volume("Music", value)


func _on_SfxVolumeSlider_value_changed(value: float) -> void:
	$SfxVolume.text = "Sound Effects Volume " + str(value * 100) + "%"
	WorldController.cur_config.volume_sfx = value
	Util.set_volume("Sfx", value)


func _on_BackKeyboard_pressed() -> void:
	$MusicCheckbox.grab_focus()
	get_parent().current_tab = 0

func _on_ButtonPrompts_item_selected(id):
	WorldController.cur_config.button_prompts = id
