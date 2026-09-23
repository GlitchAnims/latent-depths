class_name Unit extends Node3D

@export_storage var unitID: int = -1
@export_storage var team: int = 0
@export_storage var pos_hex: Vector2i = Vector2i.ZERO

@onready var ID_Label: Label3D = $"ID"
@onready var TurnMarker_Node: Node3D = $"Tringl"

const BaseMove = preload("res://scripts/SkillScripts/SS_BaseMove.gd")

## Called by Server when spawned, before adding as child to tree.
func Server_SetupForSpawn(uniqueunitid: int) -> void:
	var basemove: BaseMove = BaseMove.new()
	basemove.skillConfig_ref = GameData.skillConfig_dict[&"og_basemove"]
	skill_list.push_back(basemove)
	
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

func Server_ActivateCardByTibiaID(_id: int) -> void:
	pass
