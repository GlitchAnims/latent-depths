class_name Map extends Node3D

## Override this
func GenerateSpecialHexList() -> Array[Hex]: return []

static var specialhex_list: Array[Hex] = []

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


static func ModifyHexMapWithSpecialHex(h_list: Array[Hex]) -> void:
	for hex in h_list:
		GameData.hex_dict[hex.coord] = hex

static func BuildDistanceMap(coord_start: Vector2i) -> Dictionary[Vector2i, PathHex]:
	var distance_map: Dictionary[Vector2i, PathHex] = {}
	for coord: Vector2i in GameData.hex_dict.keys():
		distance_map[coord] = PathHex.new(-1)
	
	var queue: Array[Vector2i] = [coord_start]
	distance_map[coord_start].dist = 0
	
	while not queue.is_empty():
		var current: Vector2i = queue.pop_front()
		var current_dist: int = distance_map[current].dist
		
		for offset: Vector2i in HexMath.axial_direction_vectors:
			var neighbor: Vector2i = current + offset
			var hex: Hex = GameData.hex_dict.get(neighbor)
			if hex == null: continue
			if hex.tile_flags & Hex.TILE_FLAGS.WALL: continue
			if distance_map[neighbor].dist != -1: continue
			distance_map[neighbor].dist = current_dist + 1
			distance_map[neighbor].coord_from = current
			queue.push_back(neighbor)
	
	return distance_map
