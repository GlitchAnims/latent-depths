class_name SkillstructionMarker extends Control

@onready var GraphHolder_Node: Control = $"GraphHolder"
@onready var Label_Node: Label = $"GraphHolder/Label"

func SetHeightLevel(level: int) -> void:
	
	var graph_height: float = level * 20.0
	GraphHolder_Node.position.y = -graph_height

func SetInstructionType(ins_type: SkillInstruction.INS_TYPE) -> void:
	Label_Node.text = str(ins_type)
