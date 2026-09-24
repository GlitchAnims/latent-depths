class_name SkillBase extends Node

@export var skill_ID: int = -1
@export var skillConfig_id: StringName = &""
var skillConfig_ref: SkillConfig = null
var unit_ref: Unit = null

func _ready() -> void:
	skillConfig_ref = GameData.skillConfig_dict[skillConfig_id]
	unit_ref = $"../.."
	
	if not GameData.isServer:
		if unit_ref.skill_list.size() <= skill_ID: unit_ref.skill_list.resize(skill_ID+1)
		unit_ref.skill_list[skill_ID] = self

var loudness_value: int = 0
var instruction_list: Array[SkillInstruction] = []
var resource_cost: int = 0

func IsHexSelectable(_hex_from: Hex, _hex_to: Hex) -> bool: return true
func CanBeUsed() -> bool: return true
## Do not send nulls, please.
func FabricateSkillstructions(_hex_from: Hex, _hex_to: Hex) -> Array[SkillInstruction]: return []
func Server_PerformInstruction(_ins: SkillInstruction) -> void: pass

func DoWorldHexWidgets(_worldHex_dict: Dictionary[Vector2i, WorldHex]) -> void: pass

func GetSumDelay() -> int:
	return 0
func GetSumCooloff() -> int:
	return 0
func GetSumDowntime() -> int:
	var total: int = 0
	for ins: SkillInstruction in instruction_list:
		total += ins.timer
	return total
