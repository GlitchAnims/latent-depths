extends Node

var Stronghold_Node: Stronghold = null
var Gamespace_Node: Gamespace = null
var Encompass_Node: Encompass = null
var HandHUD_Node: HandHUD = null
var ConnectMenuNode: ConnectMenu = null

const connectmenuScene: PackedScene = preload("res://scenes/Menus/connectmenu_scene.tscn")
const unit_scene: PackedScene = preload("res://scenes/unit.tscn")

var started: bool = false
var isServer: bool = false
var isDedicated: bool = false

var rayquery_worldHex: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(Vector3.ZERO, Vector3.ZERO, 0b1000)
var rayquery_unit: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(Vector3.ZERO, Vector3.ZERO, 0b0001)

var hex_dict: Dictionary[Vector2i, Hex] = {}

var configlist_cards: Array[CardConfig] = []
var tibialist_cards: Array[CardTibia] = []
var tibiadict_cards: Dictionary[StringName, CardTibia] = {}

var configlist_bufs: Array[BufConfig] = []
var tibialist_bufs: Array[BufTibia] = []
var tibiadict_bufs: Dictionary[StringName, BufTibia] = {}

var skillConfig_dict: Dictionary[StringName, SkillConfig] = {}

func ActualizeConfigLists(extracards: Array[CardConfig]) -> void:
	configlist_cards.clear()
	for card_config in extracards:
		configlist_cards.push_back(card_config)


func ActualizeTibiaList() -> void:
	tibialist_cards.clear()
	tibiadict_cards.clear()
	tibialist_bufs.clear()
	tibiadict_bufs.clear()
	
	
	var cardcount: int = configlist_cards.size()
	for i in cardcount:
		var config: CardConfig = configlist_cards[i]
		var new_cardtibia: CardTibia = CardTibia.new(config, i)
		tibialist_cards.push_back(new_cardtibia)
		tibiadict_cards[config.identifier] = new_cardtibia
	
	var bufcount: int = configlist_bufs.size()
	for i in bufcount:
		var config: BufConfig = configlist_bufs[i]
		var new_buftibia: BufTibia = BufTibia.new(config, i)
		tibialist_bufs.push_back(new_buftibia)
		tibiadict_bufs[config.identifier] = new_buftibia

#var bufDict: Dictionary[int, Buf] = {}

var unit_dict: Dictionary[int, Unit] = {}
## This is set every tick automatically. Do not set this manually.[br]
## It is merely a shorthand so you don't have to do Dictionary.values() every time.
## Automatically sorted by Speed and unitID
var unit_list_temp: Array[Unit] = []

func _physics_process(_delta: float) -> void:
	unit_list_temp = unit_dict.values()
	
	unit_list_temp.sort_custom(func(a: Unit, b: Unit) -> bool:
		var a_speed: int = a.GetSumSpeed()
		var b_speed: int = b.GetSumSpeed()
		if a_speed == b_speed:
			return a.unitID < b.unitID # Tiebreaker
		return a_speed < b_speed
	)

@warning_ignore("unused_signal")
signal sig_actor_changed
var current_actor_is_valid: bool = false
var current_actor: Unit = null

var pilotDict: Dictionary[int, Pilot] = {}
var playerDict: Dictionary[int, Player] = {}

var pilotID_counter: int = 0
func GetUniquePilotID() -> int:
	pilotID_counter += 1
	return pilotID_counter

var unitID_counter: int = 0
func GetUniqueUnitID() -> int:
	unitID_counter += 1
	return unitID_counter
