extends VBoxContainer

func _ready():
	var deaths = WorldController.cur_save_data.deaths
	var time_str = WorldController.get_time_string_formatted(WorldController.cur_save_data.time)
	$Death.text = "Deaths: " + str(deaths)
	$Time.text = "Time: " + time_str
