extends SkillBase

func IsHexSelectable(fromHex: Hex, toHex: Hex) -> bool:
	var from_coord: Vector2i = fromHex.coord
	var to_coord: Vector2i = toHex.coord
	
	return true
