extends SkillBase

func IsHexSelectable(hex_from: Hex, hex_to: Hex) -> bool:
	var coord_from: Vector2i = hex_from.coord
	var coord_to: Vector2i = hex_to.coord
	var coord_vec: Vector2i = coord_to - coord_from
	
	var coord_vec_x: int = coord_vec.x
	var coord_vec_y: int = coord_vec.y
	var coord_vec_x_abs: int = abs(coord_vec_x)
	var coord_vec_y_abs: int = abs(coord_vec_y)
	
	var selectable: bool = false
	if coord_vec_x_abs == coord_vec_y_abs and coord_vec_x != coord_vec_y: selectable = true
	elif coord_vec_x_abs == 0 and coord_vec_y_abs != 0: selectable = true
	elif coord_vec_x_abs != 0 and coord_vec_y_abs == 0: selectable = true
	if not selectable: return false
	
	var dist: int = HexMath.CoordVecLength(coord_vec)
	if dist > 2 and dist < 6:
		_attack_vec = coord_vec
		_attack_dir = HexMath.CoordNormalize(coord_vec)
		_attack_rot = HexMath.GetRotationFromCoordNorm(_attack_dir)
		_attack_steps = dist
		reserved_heard_range = 3
		return true
	return false

var _attack_vec: Vector2i = Vector2i.ZERO
var _attack_dir: Vector2i = Vector2i.ZERO
var _attack_rot: int = 0
var _attack_steps: int = 0

func FabricateSkillstructions(hex_from: Hex, hex_to: Hex) -> Array[SkillInstruction]:
	var ins_cool: SkillInstruction = SkillInstruction.new()
	var ins_walk: SkillInstruction = SkillInstruction.new()
	var ins_ability: SkillInstruction = SkillInstruction.new()
	ins_walk.ins_type = SkillInstruction.INS_TYPE.walk
	ins_ability.ins_type = SkillInstruction.INS_TYPE.attack
	ins_ability.timer = 1000
	
	var coord_from: Vector2i = hex_from.coord
	var coord_to: Vector2i = hex_to.coord
	var coord_vec: Vector2i = coord_to - coord_from
	
	var max_steps: int = maxi(abs(coord_vec.x),abs(coord_vec.y))
	var coord_dir: Vector2i = HexMath.CoordNormalize(coord_vec)
	#var coord_rot: int = HexMath.GetRotationFromCoordNorm(coord_dir)
	
	for i in max_steps:
		ins_walk.coord_chosen_list.push_back(coord_dir)
	
	var rings: int = 3
	var diameter: int = rings*2+1
	for x in diameter:
		var xcoord: int = x-rings
		for y in diameter-abs(xcoord):
			var ycoord: int = y-mini(x,rings)
			var coord: Vector2i = Vector2i(xcoord,ycoord)
			ins_ability.coord_chosen_list.push_back(coord)
	
	var dist: int = HexMath.CoordVecLength(coord_vec)
	ins_walk.timer = 0 # 1500 * dist
	ins_cool.timer = 1500 * dist
	
	return [ins_walk, ins_ability, ins_cool]

func DoWorldHexWidgets(worldHex_dict: Dictionary[Vector2i, WorldHex]) -> void:
	var coord_from: Vector2i = unit_ref.pos_hex
	var coord_to: Vector2i = coord_from + _attack_vec
	var worldHex: WorldHex = null
	
	var walk_coord_from: Vector2i = coord_from
	for i in _attack_steps:
		worldHex = worldHex_dict.get(walk_coord_from, null)
		if worldHex != null:
			walk_coord_from += _attack_dir
			var pos_forwards: Vector2 = HexMath.hex_to_pixel(walk_coord_from)
			worldHex.AimWalkArrow(Vector3(pos_forwards.x,0,pos_forwards.y))
			worldHex.SetHexColor(Color.PURPLE)
	
	var rings: int = 3
	var diameter: int = rings*2+1
	for x in diameter:
		var xcoord: int = x-rings
		for y in diameter-abs(xcoord):
			var ycoord: int = y-mini(x,rings)
			var coord: Vector2i = Vector2i(xcoord,ycoord) + coord_to
			if coord == coord_to: continue
			worldHex = worldHex_dict.get(coord, null)
			if worldHex != null: worldHex.SetHexColor(Color.BLUE)
	
	var loud_coord_source: Vector2i = coord_from
	rings = reserved_heard_range
	diameter = rings*2+1
	for x in diameter:
		var xcoord: int = x-rings
		for y in diameter-abs(xcoord):
			var ycoord: int = y-mini(x,rings)
			var coord: Vector2i = Vector2i(xcoord,ycoord) + loud_coord_source
			worldHex = worldHex_dict.get(coord, null)
			if worldHex != null: worldHex.SetLoud()

func OnSelectAndUse() -> void:
	var incantation_new: Incantation.Standard_Walk = Incantation.Standard_Walk.new(unit_ref)
	incantation_new.incantation_ID = 1
	incantation_new.visual_walk_pos_list = [Vector2i.ZERO]
	ClientData.incantation_list.push_back(incantation_new)

func Server_PerformInstruction(ins: SkillInstruction) -> void:
	if ins.ins_type == SkillInstruction.INS_TYPE.walk:
		var coord_dest: Vector2i = unit_ref.pos_hex
		var coord_next: Vector2i = coord_dest
		var visual_walk_pos_list: PackedVector2Array = []
		for coord_dir: Vector2i in ins.coord_chosen_list:
			coord_next = coord_dest + coord_dir
			visual_walk_pos_list.push_back(HexMath.hex_to_pixel(coord_next))
			var hex_next_temp: Hex = GameData.hex_dict.get(coord_next, null)
			if hex_next_temp == null: break
			if hex_next_temp.tile_flags & Hex.TILE_FLAGS.WALL: break
			# Don't know why no work, check later
			#if not hex_next_temp.tile_flags & Hex.TILE_FLAGS.FREE: break
			var occupied: bool = false
			for unit: Unit in GameData.unit_list_temp:
				occupied = unit.pos_hex == coord_next
				if occupied: break
			if occupied: break
			coord_dest = coord_next
		
		GameData.Server_SetDoneAnimsAllPlayers(false)
		var cut_short: bool = coord_dest != coord_next
		Auth_Rem_ToClient_BaseWalk(coord_dest, visual_walk_pos_list, cut_short)
		Auth_Rem_ToClient_BaseWalk.rpc(coord_dest, visual_walk_pos_list, cut_short)
	
	if ins.ins_type != SkillInstruction.INS_TYPE.attack: return
	
	var packed_list: PackedInt64Array = []
	
	for coord_strike: Vector2i in ins.coord_chosen_list:
		coord_strike += unit_ref.pos_hex
		
		var dmg: int = 0
		var unit_struck: Unit = null
		var unit_struck_ID: int = -1
		for unit: Unit in GameData.unit_list_temp:
			var same_tile: bool = unit.pos_hex == coord_strike
			
			if same_tile:
				unit_struck = unit
				unit_struck_ID = unit.unitID
				break
		
		if is_instance_valid(unit_struck):
			dmg = 300
			unit_struck.SetHP(unit_struck.hp - dmg)
			packed_list.push_back(HexMath.Pack_Int32_to_Int64(unit_struck_ID, dmg))
	
	GameData.Server_SetDoneAnimsAllPlayers(false)
	Auth_Rem_ToClient_BaseSwipe(unit_ref.pos_hex, packed_list)
	Auth_Rem_ToClient_BaseSwipe.rpc(unit_ref.pos_hex, packed_list)

@rpc("authority", "call_remote", "reliable")
func Auth_Rem_ToClient_BaseWalk(coord: Vector2i, visual_walk_pos_list: PackedVector2Array, cut_short: bool) -> void:
	unit_ref.pos_hex = coord
	var incantation_new: Incantation.Standard_Walk = Incantation.Standard_Walk.new(self)
	incantation_new.visual_walk_pos_list = visual_walk_pos_list
	incantation_new.cut_short = cut_short
	ClientData.incantation_list.push_back(incantation_new)

@rpc("authority", "call_remote", "reliable")
func Auth_Rem_ToClient_BaseSwipe(coord_strike: Vector2i, packed_list: PackedInt64Array) -> void:
	var incantation_new: Incantation.Standard_MultiTarget = Incantation.Standard_MultiTarget.new(unit_ref)
	incantation_new.coord_strike = coord_strike
	
	for packed: int in packed_list:
		var unit_ID: int = HexMath.Unpack_Int64_Low(packed)
		var unit: Unit = GameData.unit_dict.get(unit_ID,null)
		if unit != null:
			incantation_new.unit_list.push_back(unit)
			incantation_new.dmg_list.push_back(HexMath.Unpack_Int64_High(packed))
	
	ClientData.incantation_list.push_back(incantation_new)

func Incantate(incantation: Incantation, delta: float) -> void:
	if incantation is Incantation.Standard_Walk:
		ClientData.incantation_list.erase(incantation)
