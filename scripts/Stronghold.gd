class_name Stronghold extends Node

@onready var Encompass_Node: Encompass = $"Encompass"
@onready var Gamespace_Node: Gamespace = $"Gamespace"
@onready var PlayerSpawner_Node: PlayerSpawner = $"PlayerSpawner"

@export var og_extracards: Array[CardConfig] = []
@export var og_bufs: Array[BufConfig] = []
@export var og_skillconfigs: Array[SkillConfig] = []

func _ready() -> void:
	GameData.Stronghold_Node = self
	GameData.Gamespace_Node = Gamespace_Node
	GameData.Encompass_Node = Encompass_Node
	
	#var configsDir: DirAccess = DirAccess.open("res://configs/")
	#if configsDir: VanillaUtil.LoadConfigFiles(configsDir)
	
	GameData.configlist_bufs.append_array(og_bufs)
	
	GameData.ActualizeConfigLists(og_extracards)
	GameData.ActualizeTibiaList()
	
	for config: SkillConfig in og_skillconfigs:
		GameData.skillConfig_dict[config.identifier] = config
	
	for config in GameData.configlist_bufs:
		Gamespace_Node.AddBufSceneAutoSpawn(config.unit_scene.resource_path)
	
	var conmenu: ConnectMenu = GameData.connectmenuScene.instantiate()
	Encompass_Node.add_child(conmenu)

func InitMultiplayer() -> void:
	GameData.started = true
	PlayerSpawner_Node.InitMultiplayer()
	Gamespace_Node.InitMultiplayer()
