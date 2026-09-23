class_name TestMap extends Map

func _ready() -> void:
	if not GameData.isServer: return
	
	for i in 5:
		var unit_new: Unit = GameData.unit_scene.instantiate()
		unit_new.Server_SetupForSpawn(GameData.GetUniqueUnitID())
		unit_new.team = 1
		unit_new.pos_hex = Vector2i(-4,i)
		unit_new.SnapPositionToHexPos()
		GameData.Gamespace_Node.Unitry_Node.add_child(unit_new, true)
	
	for i in 5:
		var unit_new: Unit = GameData.unit_scene.instantiate()
		unit_new.Server_SetupForSpawn(GameData.GetUniqueUnitID())
		unit_new.team = 2
		unit_new.pos_hex = Vector2i(4,i-2)
		unit_new.SnapPositionToHexPos()
		GameData.Gamespace_Node.Unitry_Node.add_child(unit_new, true)


func GenerateSpecialHexList() -> Array[Hex]:
	var ary: Array[Hex] = []
	
	var hex: Hex = Hex.new()
	hex.coord = Vector2i(0,1)
	hex.tile_flags |= Hex.TILE_FLAGS.WALL
	ary.push_back(hex)
	hex = Hex.new()
	hex.coord = Vector2i(1,1)
	hex.tile_flags |= Hex.TILE_FLAGS.WALL
	ary.push_back(hex)
	hex = Hex.new()
	hex.coord = Vector2i(2,1)
	hex.tile_flags |= Hex.TILE_FLAGS.WALL
	ary.push_back(hex)
	hex = Hex.new()
	hex.coord = Vector2i(3,1)
	hex.tile_flags |= Hex.TILE_FLAGS.WALL
	ary.push_back(hex)
	
	
	return ary
