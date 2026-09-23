class_name Map extends Node3D

## Override this
func GenerateSpecialHexList() -> Array[Hex]: return []

static func NormalizeHexDict() -> void:
	GameData.hex_dict.clear()
	
	const rings: int = 8
	const diameter: int = rings*2+1
	for x in diameter:
		var xcoord: int = x-rings
		for y in diameter-abs(xcoord):
			var ycoord: int = y-mini(x,rings)
			var coord: Vector2i = Vector2i(xcoord,ycoord)
			
			var hex: Hex = Hex.new()
			hex.coord = coord
			GameData.hex_dict[coord] = hex


static func ModifyHexMapWithSpecialHex(special_hex_list: Array[Hex]) -> void:
	for hex in special_hex_list:
		GameData.hex_dict[hex.coord] = hex
