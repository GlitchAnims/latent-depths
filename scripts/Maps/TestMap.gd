class_name TestMap extends Map

@rpc("any_peer", "call_remote", "reliable")
func Rem_ToServer_AskForSpecialHexes() -> void:
	pass

func _ready() -> void:
	if not GameData.isServer:
		NormalizeHexDict()
		
		
		return
	
	var spawn_list: Array[Unit] = []
	
	for i in 5:
		var unit_new: Unit = GameData.unit_scene.instantiate()
		unit_new.Server_SetupForSpawn(GameData.GetUniqueUnitID())
		unit_new.team = 1
		unit_new.pos_hex = Vector2i(-4,i)
		unit_new.SnapPositionToHexPos()
		spawn_list.push_back(unit_new)
	
	for i in 5:
		var unit_new: Unit = GameData.unit_scene.instantiate()
		unit_new.Server_SetupForSpawn(GameData.GetUniqueUnitID())
		unit_new.team = 2
		unit_new.pos_hex = Vector2i(4,i-2)
		unit_new.SnapPositionToHexPos()
		spawn_list.push_back(unit_new)
	
	spawn_list.shuffle()
	var spawn_count: int = spawn_list.size()
	@warning_ignore("integer_division")
	var time_per_step: int = BattleTimeline.time_per_second * 3 / spawn_count
	for i in spawn_count:
		var unit: Unit = spawn_list[i]
		unit.overhead_downtime = time_per_step * (i+1)
		GameData.Gamespace_Node.Unitry_Node.add_child(unit, true)
	
	#unit.overhead_downtime = randi_range(10,30000)


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
