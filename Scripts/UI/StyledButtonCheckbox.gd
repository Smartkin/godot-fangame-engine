class_name StyledButtonCheckbox
extends Button

export(String) var right_lbl = "right"
export(bool) var toggled = false

var toggle_lbl := Label.new()
var prev_right_lbl := ""

func _ready() -> void:
	add_child(toggle_lbl)
	toggle_lbl.name = "toggle_lbl"
	toggle_lbl.theme = theme
	toggle_lbl.add_font_override("font", get_font("font"))
	toggle_lbl.size_flags_horizontal = SIZE_EXPAND_FILL
	toggle_lbl.size_flags_vertical = SIZE_EXPAND_FILL
	toggle_lbl.align = toggle_lbl.ALIGN_RIGHT
	toggle_lbl.valign = toggle_lbl.VALIGN_CENTER
	toggle_lbl.text = right_lbl
	prev_right_lbl = right_lbl
	toggle_lbl.margin_left = margin_left
	toggle_lbl.margin_right = margin_right

func _process(delta: float) -> void:
	if (prev_right_lbl != right_lbl):
		toggle_lbl.text = right_lbl
		prev_right_lbl = right_lbl

func _pressed() -> void:
	toggled = !toggled

func _exit_tree() -> void:
	toggle_lbl.queue_free()
