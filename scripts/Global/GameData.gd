extends Node

var Stronghold_Node: Stronghold = null
var Gamespace_Node: Gamespace = null
var HandHUD_Node: HandHUD = null
var ConnectMenuNode: ConnectMenu = null

const connectmenuScene: PackedScene = preload("res://scenes/Menus/connectmenu_scene.tscn")
const unit_scene: PackedScene = preload("res://scenes/unit.tscn")

var started: bool = false
var isServer: bool = false
var isDedicated: bool = false

var rayquery_wall: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(Vector3.ZERO, Vector3.ZERO, 0b1111)

var hex_dict: Dictionary[Vector2i, Hex] = {}

var configlist_cards: Array[CardConfig] = []
var tibialist_cards: Array[CardTibia] = []
var tibiadict_cards: Dictionary[StringName, CardTibia] = {}

var configlist_bufs: Array[BufConfig] = []
var tibialist_bufs: Array[BufTibia] = []
var tibiadict_bufs: Dictionary[StringName, BufTibia] = {}

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

signal sig_updatehandvisual

var bufDict: Dictionary[int, Buf] = {}

var unitDict: Dictionary[int, Unit] = {}
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
