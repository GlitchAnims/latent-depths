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
	ins_ability.coord_chosen_list.push_back(hex_to.coord)
	
	var ins_cool: SkillInstruction = SkillInstruction.new()
	ins_cool.timer = 2000
	
	return [ins_ability, ins_cool]

func DoWorldHexWidgets(worldHex_dict: Dictionary[Vector2i, WorldHex]) -> void:
	if _last_hex_to == null: return
	
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

func Server_PerformInstruction(ins: SkillInstruction) -> void:
	if ins.ins_type != SkillInstruction.INS_TYPE.walk: return
	var coord: Vector2i = ins.coord_chosen_list[0]
	Auth_Rem_ToClient_BaseWalkAbility(coord)
	Auth_Rem_ToClient_BaseWalkAbility.rpc(coord)

@rpc("authority", "call_remote", "reliable")
func Auth_Rem_ToClient_BaseWalkAbility(coord: Vector2i) -> void:
	unit_ref.pos_hex = coord
	unit_ref.SnapPositionToHexPos()
#class Pathing extends RefCounted:
