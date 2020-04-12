extends Button

class_name StyledButtonCheckbox

export(String) var rightLbl = "right"
export(bool) var toggled = false

var ToggleLbl := Label.new()
var prevLbl := ""

func _ready() -> void:
	add_child(ToggleLbl)
	ToggleLbl.name = "ToggleLbl"
	ToggleLbl.theme = theme
	ToggleLbl.add_font_override("font", get_font("font"))
	ToggleLbl.size_flags_horizontal = SIZE_EXPAND_FILL
	ToggleLbl.size_flags_vertical = SIZE_EXPAND_FILL
	ToggleLbl.align = ToggleLbl.ALIGN_RIGHT
	ToggleLbl.valign = ToggleLbl.VALIGN_CENTER
	ToggleLbl.text = rightLbl
	prevLbl = rightLbl
	ToggleLbl.margin_left = margin_left
	ToggleLbl.margin_right = margin_right

func _process(delta: float) -> void:
	if (prevLbl != rightLbl):
		ToggleLbl.text = rightLbl
		prevLbl = rightLbl

func _pressed() -> void:
	toggled = !toggled

func _exit_tree() -> void:
	ToggleLbl.queue_free()
