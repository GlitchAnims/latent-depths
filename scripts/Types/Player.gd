class_name Player extends Pilot

@export var playerID: int = 0

@export_storage var isReady: bool = false
@export_storage var done_anims: bool = true

func Client_SetDoneAnims(b: bool) -> void:
	#done_anims = b
	if GameData.isServer: done_anims = b
	else: _Rem_ToServer_SetDoneAnims.rpc_id(1, b)
@rpc("any_peer", "call_remote", "reliable")
func _Rem_ToServer_SetDoneAnims(b: bool) -> void:
	if not GameData.isServer: return
	if multiplayer.get_remote_sender_id() != playerID: return
	done_anims = b

@rpc("authority", "call_remote", "reliable")
func Auth_Rem_ToClient_AreYouDoneAnims() -> void:
	if GameData.isServer: return
	# if I am done animations
	Client_SetDoneAnims(done_anims)

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
