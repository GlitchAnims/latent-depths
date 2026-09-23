class_name WorldHex extends Node3D

@onready var HexModel_Node: MeshInstance3D = $"HexModel"

var hex_ref: Hex = null

var timer: float = 0

func _process(delta: float) -> void:
	timer -= delta
	if timer > 0: visible = false
	else:
		visible = true
		timer = 0
