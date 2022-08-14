extends Node2D

signal transition_finished

enum STATE {
	FROM,
	TO
}

export(float, 0.001, 1.0) var trans_speed := 0.02
export(float, 0.0, 1.0) var ramp := 0.05
export(Color) var halo_color := Color8(0, 0, 0)
export(Color) var trans_color := Color8(255, 255, 255)
export(String, FILE, "*.png") var mask

var _t := 0.0
var _state = STATE.FROM

func _ready() -> void:
	$CanvasLayer/ColorRect.material = preload("res://Shaders/Transition.tres")
	print(material)
	$CanvasLayer/ColorRect.material.set_shader_param("after", trans_color)
	$CanvasLayer/ColorRect.material.set_shader_param("t", _t)
	$CanvasLayer/ColorRect.material.set_shader_param("halo_color", halo_color)
	$CanvasLayer/ColorRect.material.set_shader_param("ramp", ramp)
	$CanvasLayer/ColorRect.material.set_shader_param("mask", load(mask))
	$Timer.start()


func _exit_tree():
	WorldController.free_transition()


func set_state(new_state) -> void:
	_state = new_state

func set_time(new_time: float) -> void:
	_t = new_time

func _on_Timer_timeout():
	match _state:
		STATE.FROM:
			_t += trans_speed
			if _t >= 1.0:
				emit_signal("transition_finished")
				_state = STATE.TO
		STATE.TO:
			_t -= trans_speed
			if _t <= 0.0:
				queue_free()
	print(_t)
	$CanvasLayer/ColorRect.material.set_shader_param("t", _t)
