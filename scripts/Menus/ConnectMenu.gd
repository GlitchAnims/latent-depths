class_name ConnectMenu extends Control
const PORT = 4433

@onready var ConnectPanelNode: PanelContainer = $"ConnectPanel"
@onready var IPInputNode: LineEdit = $"ConnectPanel/vBox1/IPInput"
@onready var ConnectButtonNode: Button = $"ConnectPanel/vBox1/ConnectButton"
@onready var HostButtonNode: Button = $"ConnectPanel/vBox1/HostButton"

func _ready() -> void:
	# You can save bandwidth by disabling server relay and peer notifications.
	multiplayer.server_relay = false
	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		OnChooseHost().call_deferred()
	
	GameData.ConnectMenuNode = self
	ClientData.viewportSize_changed.connect(UpdateVisibility)
	UpdateVisibility()

func UpdateVisibility(_playerList: Array[Player] = []) -> void:
	var viewportSize = ClientData.viewportSize
	
	ConnectPanelNode.set_begin(viewportSize * 0.3)
	ConnectPanelNode.set_end(viewportSize * 0.7)

func OnChooseConnect():
	var inputString: String = IPInputNode.get_text()
	if inputString.is_empty() or inputString == "localhost": inputString = "127.0.0.1"
	if not inputString.is_valid_ip_address(): return
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(inputString, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()

func OnChooseHost():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, 2)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()

func start_game():
	set_visible(false)
	GameData.Stronghold_Node.InitMultiplayer()

#func _on_main_2d_ready():
	#for config_name in GameData.GamespaceNode.unitConfigDict:
		#DropdownNode.add_item(GameData.GamespaceNode.unitConfigDict[config_name].displayName)
		#configNameList.push_back(config_name)
	#ClientGuiParams.selectedConfigNameForSpawn = configNameList[0]
#var configNameList: Array[StringName] = []
#
#func _on_dropdown_item_selected(index):
	#ClientGuiParams.selectedConfigNameForSpawn = configNameList[index]
