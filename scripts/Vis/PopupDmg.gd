class_name PopupDmg extends Node3D

@onready var DmgNumber_Node: Label3D = $"DmgNumber"

var progress: float = 1

func _ready() -> void:
	visible = false

func BeginFloaty(pos: Vector3, dmg: int) -> void:
	visible = true
	position = pos
	DmgNumber_Node.text = str(dmg)
	progress = 0
	set_process_mode(Node.PROCESS_MODE_INHERIT)

func _process(delta: float) -> void:
	position.y += delta * 0.6
	progress += delta
	if progress >= 1:
		set_process_mode(Node.PROCESS_MODE_DISABLED)
		visible = false
