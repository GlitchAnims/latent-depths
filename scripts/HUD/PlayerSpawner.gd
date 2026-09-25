class_name PlayerSpawner extends MultiplayerSpawner


func InitMultiplayer() -> void:
	GameData.isServer = multiplayer.is_server()
	GameData.isDedicated = OS.has_feature("dedicated_server")
	if not GameData.isServer: return
	
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	
	# Spawn already connected players.
	for id in multiplayer.get_peers():
		add_player(id)
	
	# Spawn the local player unless this is a dedicated server export.
	if not GameData.isDedicated: add_player(1)

func _exit_tree():
	if not multiplayer.is_server(): return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)

var last_team: int = 1

const playerScene: PackedScene = preload("res://scenes/player.tscn")
func add_player(id: int):
	var player: Player = playerScene.instantiate()
	
	player.playerID = id # Set player id.
	player.name = str(id) # ID but string
	player.team = last_team
	last_team += 1
	var secretPass: int = ClientData.rng.randi_range(-999999999, 999999999)
	player.password = secretPass
	player.pilotID = GameData.GetUniquePilotID()
	add_child(player, true)
	#Authority_GivePassword.rpc_id(id, secretPass)
	
	#var spawnPos: Vector3 = Vector3(ClientData.rng.randf_range(-5.0,5.0), 0.0, ClientData.rng.randf_range(-5.0,5.0))
	
	if is_instance_valid(GameData.cur_actor):
		GameData.Gamespace_Node.Auth_Rem_ToClient_SetActor.rpc_id(id, GameData.cur_actor.unitID)

#@rpc("authority", "call_remote", "reliable")
#func Auth_Rem_ToClient_SendMissingJoinData(skill_ID: int, ins_list_packed: PackedByteArray) -> void:
	#if GameData.isServer: return

@rpc("authority", "call_local", "reliable")
func Authority_GivePassword(password: int) -> void:
	var playerList: Array[Player] = []
	playerList.assign(get_tree().get_nodes_in_group(&"Players"))
	for player in playerList: player.password = password

func del_player(id: int):
	if not has_node(str(id)): return
	get_node(str(id)).queue_free()
