extends SkillBase

func IsHexSelectable(hex_from: Hex, hex_to: Hex) -> bool:
	var dist: int = _CheckPathDist(hex_from, hex_to)
	return dist >= 1 and dist <= 4

var _last_hex_from: Hex = null
var _last_hex_to: Hex = null
var _distance_map: Dictionary[Vector2i, PathHex]

func _CheckPathDist(hex_from: Hex, hex_to: Hex) -> int:
	var coord_from: Vector2i = hex_from.coord
	var coord_to: Vector2i = hex_to.coord
	
	if _last_hex_from != hex_from:
		_last_hex_from = hex_from
		_distance_map = Map.BuildDistanceMap(coord_from)
	
	if _last_hex_to != hex_to: _last_hex_to = hex_to
	
	var path_hex: PathHex = _distance_map.get(coord_to, null)
	var dist: int = -1
	if path_hex != null: dist = path_hex.dist
	if dist < 1: dist = 999999
	return dist

func FabricateSkillstructions(hex_from: Hex, hex_to: Hex) -> Array[SkillInstruction]:
	var dist: int = _CheckPathDist(hex_from, hex_to)
	var delay: int = 3000 * dist
	
	var ins_ability: SkillInstruction = SkillInstruction.new()
	ins_ability.timer = delay
	ins_ability.ins_type = SkillInstruction.INS_TYPE.walk
	
	var hex_walk_list: Array[Hex] = GetHexWalkList(hex_to)
	var coord_old: Vector2i = hex_from.coord
	for hex_walk: Hex in hex_walk_list:
		var coord_new: Vector2i = hex_walk.coord
		var coord_vec: Vector2i = coord_new - coord_old
		coord_old = coord_new
		ins_ability.coord_chosen_list.push_back(coord_vec)
	
	var ins_cool: SkillInstruction = SkillInstruction.new()
	ins_cool.timer = 2000
	
	return [ins_ability, ins_cool]


func GetHexWalkList(hex_to: Hex) -> Array[Hex]:
	var coord_to: Vector2i = hex_to.coord
	var pathHex: PathHex = _distance_map[coord_to]
	var hex_list: Array[Hex] = [hex_to]
	
	while pathHex != null and pathHex.dist > 1:
		var coord_backwalk: Vector2i = pathHex.coord_from
		var hex: Hex = GameData.hex_dict.get(coord_backwalk, null)
		if hex != null: hex_list.push_front(hex)
		pathHex = _distance_map.get(coord_backwalk, null)
	
	return hex_list

func DoWorldHexWidgets(worldHex_dict: Dictionary[Vector2i, WorldHex]) -> void:
	if _last_hex_to == null: return
	#GetPath(_last_hex_to)
	var coord_to: Vector2i = _last_hex_to.coord
	var pathHex: PathHex = _distance_map[coord_to]
	
	while pathHex != null and pathHex.dist > 0:
		var coord_backwalk: Vector2i = pathHex.coord_from
		var worldHex: WorldHex = worldHex_dict.get(coord_backwalk, null)
		if worldHex != null:
			worldHex.SetHexColor(Color.PURPLE)
			var coord_forwards: Vector2 = HexMath.hex_to_pixel(coord_to)
			worldHex.AimWalkArrow(Vector3(coord_forwards.x,0,coord_forwards.y))
		pathHex = _distance_map.get(coord_backwalk, null)
		coord_to = coord_backwalk

func OnSelectAndUse() -> void:
	pass

func Server_PerformInstruction(ins: SkillInstruction) -> void:
	if ins.ins_type != SkillInstruction.INS_TYPE.walk: return
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
	Auth_Rem_ToClient_BaseWalkAbility(coord_dest, visual_walk_pos_list, cut_short)
	Auth_Rem_ToClient_BaseWalkAbility.rpc(coord_dest, visual_walk_pos_list, cut_short)

@rpc("authority", "call_remote", "reliable")
func Auth_Rem_ToClient_BaseWalkAbility(coord: Vector2i, visual_walk_pos_list: PackedVector2Array, cut_short: bool) -> void:
	unit_ref.pos_hex = coord
	var incantation_new: Incantation_Custom = Incantation_Custom.new(self)
	incantation_new.visual_walk_pos_list = visual_walk_pos_list
	incantation_new.cut_short = cut_short
	ClientData.incantation_list.push_back(incantation_new)
	
#class Pathing extends RefCounted:

func Incantate(incantation: Incantation, delta: float) -> void:
	var end: bool = false
	var inc: Incantation_Custom = incantation as Incantation_Custom
	
	if inc.visual_walk_pos_list.is_empty():
		end = true
	else:
		var pos3_cur: Vector3 = unit_ref.position
		#var pos2_cur: Vector2 = Vector2(pos3_cur.x,pos3_cur.z)
		var pos2_next: Vector2 = inc.visual_walk_pos_list[0]
		var pos3_next: Vector3 = Vector3(pos2_next.x, 0, pos2_next.y)
		
		var pos3_vec: Vector3 = pos3_next - pos3_cur
		var pos3_norm: Vector3 = pos3_vec.normalized()
		
		
		if inc.cut_short and inc.visual_walk_pos_list.size() == 1:
			inc.visual_walk_pos_list.remove_at(0)
			# TODO Blocked path
		else:
			var dist: float = pos3_vec.length()
			if dist <= 0.01:
				unit_ref.position = pos3_next
				inc.visual_walk_pos_list.remove_at(0)
			else:
				unit_ref.position += pos3_norm * minf(delta*2.5, dist)
	
	#var prog: float = inc.anim_progress
	#prog += delta
	#inc.anim_progress = prog
	
	if end:
		ClientData.incantation_list.erase(incantation)

class Incantation_Custom extends Incantation:
	var visual_walk_pos_list: PackedVector2Array = []
	var cut_short: bool = false
