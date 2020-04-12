extends VBoxContainer

func _ready():
	var deaths = WorldController.globalData.deaths
	var timeStr = WorldController.getTimeStringFormatted(WorldController.globalData.time)
	$Death.text = "Deaths: " + str(deaths)
	$Time.text = "Time: " + timeStr
