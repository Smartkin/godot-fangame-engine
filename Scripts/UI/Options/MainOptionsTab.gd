extends VBoxContainer

func _ready() -> void:
	var curConf := WorldController.currentConfig
	$MusicCheckbox.musicValue = curConf.music
	$MasterVolumeSlider.value = curConf.volume_master
	$MasterVolume.text = "Master Volume " + str($MasterVolumeSlider.value * 100) + "%"
	$MusicVolumeSlider.value = curConf.volume_music
	$MusicVolume.text = "Music Volume " + str($MusicVolumeSlider.value * 100) + "%"
	$SfxVolumeSlider.value = curConf.volume_sfx
	$SfxVolume.text = "Sound Effects Volume " + str($SfxVolumeSlider.value * 100) + "%"
	$FullscreenCheckbox.fullscreen = curConf.fullscreen
	$BorderlessCheckbox.borderless = curConf.borderless
	$VsyncCheckbox.vsync = curConf.vsync
	if ($FullscreenCheckbox.fullscreen):
		$BorderlessCheckbox.disabled = true
	else:
		$BorderlessCheckbox.disabled = false
	$MusicCheckbox.grab_focus()


func _on_MusicCheckbox_pressed() -> void:
	$MusicCheckbox.musicValue = !$MusicCheckbox.musicValue
	WorldController.currentConfig.music = $MusicCheckbox.musicValue
	if ($MusicCheckbox.musicValue):
		WorldController.playMusic($"../../MusicPlayer".music)
	else:
		WorldController.stopMusic()


func _on_FullscreenCheckbox_pressed() -> void:
	$FullscreenCheckbox.fullscreen = !$FullscreenCheckbox.fullscreen
	WorldController.currentConfig.fullscreen = $FullscreenCheckbox.fullscreen
	if ($FullscreenCheckbox.fullscreen):
		$BorderlessCheckbox.disabled = true
	else:
		$BorderlessCheckbox.disabled = false
	OS.window_fullscreen = $FullscreenCheckbox.fullscreen


func _on_BorderlessCheckbox_pressed() -> void:
	$BorderlessCheckbox.borderless = !$BorderlessCheckbox.borderless
	WorldController.currentConfig.borderless = $BorderlessCheckbox.borderless
	OS.window_borderless = $BorderlessCheckbox.borderless


func _on_VsyncCheckbox_pressed() -> void:
	$VsyncCheckbox.vsync = !$VsyncCheckbox.vsync
	WorldController.currentConfig.vsync = $VsyncCheckbox.vsync
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
	WorldController.currentConfig.volume_master = value
	WorldController.setVolume("Master", value)


func _on_MusicVolumeSlider_value_changed(value: float) -> void:
	$MusicVolume.text = "Music Volume " + str(value * 100) + "%"
	WorldController.currentConfig.volume_music = value
	WorldController.setVolume("Music", value)


func _on_SfxVolumeSlider_value_changed(value: float) -> void:
	$SfxVolume.text = "Sound Effects Volume " + str(value * 100) + "%"
	WorldController.currentConfig.volume_sfx = value
	WorldController.setVolume("Sfx", value)


func _on_BackKeyboard_pressed() -> void:
	$MusicCheckbox.grab_focus()
	get_parent().current_tab = 0
