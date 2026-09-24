extends SkillBase

func IsHexSelectable(hex_from: Hex, hex_to: Hex) -> bool:
	var dist: int = _CheckPathDist(hex_from, hex_to)
	return dist >= 1 and dist <= 4

var _last_hex_from: Hex = null
var _distance_map: Dictionary[Vector2i, PathHex]

func _CheckPathDist(hex_from: Hex, hex_to: Hex) -> int:
	var coord_from: Vector2i = hex_from.coord
	var coord_to: Vector2i = hex_to.coord
	
	if _last_hex_from != hex_from:
		_last_hex_from = hex_from
		_distance_map = Map.BuildDistanceMap(coord_from)
	
	var path_hex: PathHex = _distance_map.get(coord_to, null)
	var dist: int = -1
	if path_hex != null: dist = path_hex.dist
	if dist < 1: dist = 999999
	return dist

func FabricateSkillstructions(hex_from: Hex, hex_to: Hex) -> Array[SkillInstruction]:
	var dist: int = _CheckPathDist(hex_from, hex_to)
	var delay: int = 3000 * dist
	
	var ins_delay: SkillInstruction = SkillInstruction.new()
	ins_delay.timer = delay
	
	var ins_ability: SkillInstruction = SkillInstruction.new()
	ins_ability.ins_type = SkillInstruction.INS_TYPE.walk
	#ins_ability.coord_chosen_list.push_back()
	
	var ins_cool: SkillInstruction = SkillInstruction.new()
	ins_cool.timer = 2000
	
	return [ins_delay, ins_ability, ins_cool]



#class Pathing extends RefCounted:
