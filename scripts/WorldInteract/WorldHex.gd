class_name WorldHex extends Node3D

var hex_ref: Hex = null

var timer: float = 0

func _process(delta: float) -> void:
	timer -= delta
	if timer > 0: visible = false
	else:
		visible = true
		timer = 0
