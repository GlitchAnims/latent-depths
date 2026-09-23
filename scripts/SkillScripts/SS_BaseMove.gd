extends SkillBase

func IsHexSelectable(hex_from: Hex, hex_to: Hex) -> bool:
	var from_coord: Vector2i = hex_from.coord
	var to_coord: Vector2i = hex_to.coord
	var coord_vec: Vector2i = to_coord-from_coord
	
	var dist: int = HexMath.CoordVecLength(coord_vec)
	return dist >= 1 and dist <= 4


func FabricateSkillstructions(hex_from: Hex, hex_to: Hex) -> Array[SkillInstruction]:
	var from_coord: Vector2i = hex_from.coord
	var to_coord: Vector2i = hex_to.coord
	var coord_vec: Vector2i = to_coord-from_coord
	
	var dist: int = HexMath.CoordVecLength(coord_vec)
	var delay: int = 3000 * dist
	
	var ins_delay: SkillInstruction = SkillInstruction.new()
	ins_delay.timer = delay
	
	var ins_ability: SkillInstruction = SkillInstruction.new()
	ins_ability.ins_type = SkillInstruction.INS_TYPE.ability
	
	var ins_cool: SkillInstruction = SkillInstruction.new()
	ins_cool.timer = 1000
	
	return [ins_delay, ins_ability, ins_cool]
