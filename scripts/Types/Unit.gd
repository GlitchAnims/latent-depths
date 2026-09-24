class_name Unit extends Node3D

@export_storage var unitID: int = -1
@export_storage var team: int = 0
@export_storage var pos_hex: Vector2i = Vector2i.ZERO

@onready var ID_Label: Label3D = $"ID"
@onready var TurnMarker_Node: Node3D = $"Tringl"
@onready var SkillSpawner_Node: SkillSpawner = $"SkillSpawner"

## Called by Server when spawned, before adding as child to tree.
func Server_SetupForSpawn(uniqueunitid: int) -> void:
	unitID = uniqueunitid
	SetupHP(1000)
	## TODO Stress setup
	SetupLight(10)

@export_storage var hp_max: int = 1000
@export_storage var hp: int = 1000
## Auto-called by [method Unit.Server_SetupForSpawn]
func SetupHP(hp_max_new: int = 1000) -> void:
	hp_max = hp_max_new
	hp = hp_max_new

@export_storage var stress_enabled: bool = true
@export_storage var stress: int = 1000


@export_storage var overhead_downtime: int = 0

var skill_list: Array[SkillBase] = []
var skill_selected: SkillBase = null
@export_storage var skill_selected_i: int = 0

func GetSumDelay() -> int:
	return 0
func GetSumCooloff() -> int:
	return 0
func GetSumDowntime() -> int:
	var total: int = overhead_downtime
	var delay: int = GetSumDelay()
	var downtime: int = GetSumCooloff()
	if is_instance_valid(skill_selected): total += skill_selected.GetSumDowntime()
	return total+delay+downtime

func GetSumSpeed() -> int:
	return 0

@export_storage var light_max: int = 10
@export_storage var light: int = 5
## Auto-called by [method Unit.Server_SetupForSpawn]
func SetupLight(max_new: int = 10) -> void:
	light_max = max_new
	light = floor(float(max_new) / 2)

func UpdateForActor() -> void:
	var is_actor: bool = GameData.current_actor == self
	TurnMarker_Node.visible = is_actor

func _exit_tree() -> void:
	GameData.unit_dict.erase(unitID)
	GameData.sig_actor_changed.disconnect(UpdateForActor)
func free() -> void:
	pass
	super()

func _ready() -> void:
	GameData.unit_dict[unitID] = self
	GameData.sig_actor_changed.connect(UpdateForActor)
	
	if GameData.isServer:
		var skillConfig: SkillConfig = GameData.skillConfig_dict[&"og_basemove"]
		var basemove: SkillBase = skillConfig.skill_scene.instantiate()
		basemove.skillConfig_ref = skillConfig
		basemove.skillConfig_id = &"og_basemove"
		var skillsize: int = skill_list.size()
		skill_list.push_back(basemove)
		basemove.skill_ID = skillsize
		SkillSpawner_Node.add_child(basemove,true)
	
	ID_Label.text = str(unitID)
	_ready_unit()
	var pos2: Vector2 = HexMath.hex_to_pixel(pos_hex)
	position.x = pos2.x
	position.z = pos2.y
func _ready_unit() -> void: pass

func _physics_process(delta: float) -> void:
	# You do stuff here
	_physics_process_unit(delta)
func _physics_process_unit(_delta: float) -> void: pass

func SnapPositionToHexPos() -> void:
	var pos2: Vector2 = HexMath.hex_to_pixel(pos_hex)
	position = Vector3(pos2.x,0,pos2.y)

## Request from Client to Server only.[br]
## Checks if Client Player ID is same as this unit's Pilot Player, 
## then calls [method Unit.Server_ActivateCardByTibiaID].
@rpc("any_peer", "call_remote", "reliable")
func Request_ActivateCardByTibiaID(id: int = -1) -> void:
	if not GameData.isServer: return
	var player: Player = null # TODO player?
	var senderID: int = multiplayer.get_remote_sender_id()
	if player.playerID != senderID: return # LOUD INCORRECT BUZZER
	Server_ActivateCardByTibiaID(id)

@rpc("authority", "call_remote", "reliable")
func Auth_Rem_ToClient_SelectSkill(skill_ID: int) -> void:
	if GameData.isServer: return
	if skill_ID == -1:
		skill_selected = null
		return
	if skill_list.size() <= skill_ID: return
	var skill: SkillBase = skill_list[skill_ID]
	if not is_instance_valid(skill): return
	skill_selected = skill

@rpc("authority", "call_remote", "reliable")
func Auth_Rem_ToClient_SendSkillstructionArray(skill_ID: int, ins_list_packed: PackedByteArray) -> void:
	if GameData.isServer: return
	if skill_list.size() <= skill_ID: return
	var skill: SkillBase = skill_list[skill_ID]
	if not is_instance_valid(skill): return
	var unpickled: Array = GameData.Stronghold_Node.pickler.unpickle(ins_list_packed)
	var ins_list: Array[SkillInstruction] = []
	for obj in unpickled:
		if obj is SkillInstruction: ins_list.push_back(obj)
	skill.instruction_list = ins_list

@rpc("any_peer", "call_remote", "reliable")
func Rem_ToServer_TryUseSkill(skill_ID: int, coord_target: Vector2i) -> void:
	if not GameData.isServer: return
	
	var actor: Unit = GameData.current_actor
	if not is_instance_valid(actor) or actor != self: return
	
	var sender_id: int = multiplayer.get_remote_sender_id()
	var player: Player = GameData.playerDict.get(sender_id, null)
	if player == null or player.team != team: return
	
	if skill_list.size() <= skill_ID || skill_list[skill_ID] == null: return
	var skill: SkillBase = skill_list[skill_ID]
	
	var hex_target: Hex = GameData.hex_dict.get(coord_target, null)
	if hex_target == null: return
	
	var hex_from: Hex = GameData.hex_dict[pos_hex]
	var valid: bool = skill.IsHexSelectable(hex_from, hex_target)
	if not valid: return
	
	var skillstruction_list: Array[SkillInstruction] = skill.FabricateSkillstructions(hex_from, hex_target)
	GameData.current_actor = null
	GameData.Gamespace_Node.Auth_Rem_ToClient_ItsThisGuysTurn.rpc(-1)
	Server_UseSkill(skill, skillstruction_list)

func Server_UseSkill(skill: SkillBase, skillstruction_list: Array[SkillInstruction]) -> void:
	skill.instruction_list = skillstruction_list
	skill_selected = skill
	var packed_ins_list: PackedByteArray = GameData.Stronghold_Node.pickler.pickle(skillstruction_list)
	var skill_ID: int = skill.skill_ID
	Auth_Rem_ToClient_SendSkillstructionArray.rpc(skill_ID, packed_ins_list)
	Auth_Rem_ToClient_SelectSkill.rpc(skill_ID)

func Server_ActivateCardByTibiaID(_id: int) -> void:
	pass
