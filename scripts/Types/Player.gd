class_name Player extends Pilot

@export var playerID: int = 0

@export var isReady: bool = false
var password: int = -1

var mousePos_old: Vector2 = Vector2.ZERO

func _ready_pilot():
	GameData.playerDict.set(playerID, self)
	if multiplayer.multiplayer_peer.get_unique_id() != playerID: return
	ClientData.thisPlayer = self

func _physics_process_pilot(_delta: float) -> void:
	if multiplayer.multiplayer_peer.get_unique_id() != playerID: return
	

func _exit_tree():
	GameData.playerDict.erase(playerID)
	GameData.pilotDict.erase(pilotID)
