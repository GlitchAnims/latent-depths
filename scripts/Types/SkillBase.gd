class_name SkillBase extends Node

var skillConfig_ref: SkillConfig = null
var loudness_value: int = 0
var instruction_list: Array[SkillInstruction] = []
var resource_cost: int = 0

func IsHexSelectable(newHex:Hex) -> bool:
	return true
