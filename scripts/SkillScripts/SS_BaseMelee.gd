extends SkillBase

func IsHexSelectable(hex_from: Hex, hex_to: Hex) -> bool:
	var coord_from: Vector2i = hex_from.coord
	var coord_to: Vector2i = hex_to.coord
	var coord_vec: Vector2i = coord_to - coord_from
	var dist: int = HexMath.CoordVecLength(coord_vec)
	if skillConfig_ref.is_alt_skill: return dist >= 2 and dist <= 5
	else:
		if dist == 1:
			_attack_vec = coord_vec
			reserved_heard_range = 1
			return true
	return false

var _attack_vec: Vector2i = Vector2i.ZERO

func FabricateSkillstructions(hex_from: Hex, hex_to: Hex) -> Array[SkillInstruction]:
	var ins_cool: SkillInstruction = SkillInstruction.new()
	var ins_ability: SkillInstruction = SkillInstruction.new()
	ins_ability.ins_type = SkillInstruction.INS_TYPE.attack
	
	var coord_from: Vector2i = hex_from.coord
	var coord_to: Vector2i = hex_to.coord
	var coord_vec: Vector2i = coord_to - coord_from
	var dist: int = HexMath.CoordVecLength(coord_vec)
	if skillConfig_ref.is_alt_skill: pass
	else:
		if dist == 1:
			_attack_vec = coord_vec
			ins_ability.coord_chosen_list.push_back(_attack_vec)
			ins_ability.timer = 1000
			ins_cool.timer = 1000
	
	return [ins_ability, ins_cool]

func DoWorldHexWidgets(worldHex_dict: Dictionary[Vector2i, WorldHex]) -> void:
	var coord_from: Vector2i = unit_ref.pos_hex
	var coord_to: Vector2i = coord_from + _attack_vec
	
	var worldHex: WorldHex = worldHex_dict.get(coord_from, null)
	if worldHex != null:
		var coord_forwards: Vector2 = HexMath.hex_to_pixel(coord_to)
		worldHex.AimWalkArrow(Vector3(coord_forwards.x,0,coord_forwards.y))
	
	worldHex = worldHex_dict.get(coord_to, null)
	if worldHex != null:
		worldHex.SetHexColor(Color.PURPLE)
	
	var loud_coord_source: Vector2i = coord_from
	var rings: int = reserved_heard_range
	var diameter: int = rings*2+1
	for x in diameter:
		var xcoord: int = x-rings
		for y in diameter-abs(xcoord):
			var ycoord: int = y-mini(x,rings)
			var coord: Vector2i = Vector2i(xcoord,ycoord) + loud_coord_source
			worldHex = worldHex_dict.get(coord, null)
			if worldHex != null: worldHex.SetLoud()

func OnSelectAndUse() -> void:
	pass

func Server_PerformInstruction(ins: SkillInstruction) -> void:
	if ins.ins_type != SkillInstruction.INS_TYPE.attack: return
	var coord_strike: Vector2i = unit_ref.pos_hex + ins.coord_chosen_list[0]
	
	GameData.Server_SetDoneAnimsAllPlayers(false)
	
	var unit_struck: Unit = null
	var unit_struck_ID: int = unit_struck.unitID if is_instance_valid(unit_struck) else -1
	
	var strike_solid: bool = false
	var dmg: int = 0
	
	Auth_Rem_ToClient_BaseMelee(coord_strike, strike_solid, dmg, unit_struck_ID)
	Auth_Rem_ToClient_BaseMelee.rpc(coord_strike, strike_solid, dmg, unit_struck_ID)

@rpc("authority", "call_remote", "reliable")
func Auth_Rem_ToClient_BaseMelee(coord_strike: Vector2i, strike_solid: bool, dmg: int, unit_struck_ID: int) -> void:
	var incantation_new: Incantation_Custom = Incantation_Custom.new(self)
	incantation_new.coord_strike = coord_strike
	incantation_new.strike_solid = strike_solid
	incantation_new.dmg = dmg
	if unit_struck_ID > -1: incantation_new.unit_struck = GameData.unit_dict[unit_struck_ID]
	ClientData.incantation_list.push_back(incantation_new)

func Incantate(incantation: Incantation, delta: float) -> void:
	var inc: Incantation_Custom = incantation as Incantation_Custom
	#var coord_strike: Vector2i = inc.coord_strike
	
	var prog: float = inc.anim_progress
	prog += delta * 1.3
	inc.anim_progress = prog
	#unit_ref.rotate(Vector3.FORWARD, TAU*3*delta)
	
	
	if prog >= 1.0:
		ClientData.incantation_list.erase(incantation)
		unit_ref.Vis_InflictShake()
		#unit_ref.rotation = Vector3.ZERO

class Incantation_Custom extends Incantation:
	var strike_solid: bool = false
	var coord_strike: Vector2i = Vector2i.ZERO
	var dmg: int = 0
	var unit_struck: Unit = null
