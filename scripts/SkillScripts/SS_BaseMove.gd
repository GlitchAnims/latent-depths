extends SkillBase

func IsHexSelectable(hex_from: Hex, hex_to: Hex) -> bool:
	var from_coord: Vector2i = hex_from.coord
	var to_coord: Vector2i = hex_to.coord
	var coord_vec: Vector2i = to_coord-from_coord
	
	var dist: int = HexMath.CoordVecLength(coord_vec)
	return dist <= 4
