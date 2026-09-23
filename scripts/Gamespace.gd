class_name Gamespace extends Node3D

@onready var UnitSpawner_Node: MultiplayerSpawner = $"UnitSpawner"
@onready var Unitry_Node: Node3D = $"Unitry"

@onready var THECamera_Node: Camera3D = $"THECamera"

const basemap_scene: PackedScene = preload("res://scenes/Maps/testmap.tscn")
func InitMultiplayer() -> void:
	Map.NormalizeHexDict()
	if not GameData.isServer: return
	
	# Init Map Server Side.
	var map: Map = basemap_scene.instantiate()
	var special_hex_list: Array[Hex] = map.GenerateSpecialHexList()
	Map.ModifyHexMapWithSpecialHex(special_hex_list)
	
	# Clickable hexes map
	var hex_list: Array[Hex] = GameData.hex_dict.values() as Array[Hex]
	for hex in hex_list:
		if hex.tile_flags & Hex.TILE_FLAGS.WALL: continue
		var newnode: WorldHex = ClientData.worldhex_scene.instantiate()
		var pos: Vector2 = HexMath.hex_to_pixel(hex.coord)
		newnode.position = Vector3(pos.x,0,pos.y)
		add_child(newnode)
	
	# Serialization Send to Client
	var hexpack: PackedByteArray = var_to_bytes_with_objects(special_hex_list)
	# Can do serialization on dictionary, too... Hmmmmmm
	#var hexpack: PackedByteArray = var_to_bytes_with_objects(GameData.hex_dict)
	print(hexpack.size())
	Auth_Rem_SendSpecialHexData.rpc(hexpack)
	# Multiplayer Synchronizer syncs when this happens. Do everything else before it.
	add_child(map, true)

@rpc("authority", "call_remote", "reliable")
func Auth_Rem_SendSpecialHexData(hexpack: PackedByteArray) -> void:
	var special_hex_list: Array[Hex] = bytes_to_var_with_objects(hexpack)
	Map.ModifyHexMapWithSpecialHex(special_hex_list)

func _physics_process(_delta: float) -> void:
	if not GameData.started: return
	
	var mousePos: Vector2 = ClientData.mousePos
	var space_state = get_world_3d().direct_space_state
	var from: Vector3 = THECamera_Node.project_ray_origin(mousePos)
	var to: Vector3 = THECamera_Node.global_position + THECamera_Node.project_ray_normal(mousePos) * 200.0
	GameData.rayquery_wall.from = from
	GameData.rayquery_wall.to = to
	var result: Dictionary = space_state.intersect_ray(GameData.rayquery_wall)
	if result and result.collider is WorldPickable:
		var worldPick: WorldPickable = result.collider as WorldPickable
		var worldhex: WorldHex = worldPick.LogicNode as WorldHex
		worldhex.timer = 0.2
		#var worldPick.LogicNode

func _process(delta: float) -> void:
	
	var cam_movespeed: float = delta * 4.0
	
	if ClientData.hold_north: THECamera_Node.position.z -= cam_movespeed
	elif ClientData.hold_south: THECamera_Node.position.z += cam_movespeed
	if ClientData.hold_west: THECamera_Node.position.x -= cam_movespeed
	elif ClientData.hold_east: THECamera_Node.position.x += cam_movespeed

func AddUnitSceneAutoSpawn(path: String) -> void:
	UnitSpawner_Node.add_spawnable_scene(path)
#func AddBufSceneAutoSpawn(path: String) -> void:
	#BufSpawner_Node.add_spawnable_scene(path)
