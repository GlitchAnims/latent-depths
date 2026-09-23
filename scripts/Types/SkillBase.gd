class_name SkillBase extends RefCounted

var skillConfig_ref: SkillConfig = null
var unit_ref: Unit = null

var loudness_value: int = 0
var instruction_list: Array[SkillInstruction] = []
var resource_cost: int = 0

func IsHexSelectable(_hex_from: Hex, _hex_to: Hex) -> bool: return true
func CanBeUsed() -> bool: return true

func GetSumDelay() -> int:
	return 0
func GetSumCooloff() -> int:
	return 0
func GetSumDowntime() -> int:
	return 0
