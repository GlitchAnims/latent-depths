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
	var specialhex_list: Array[Hex] = map.GenerateSpecialHexList()
	Map.ModifyHexMapWithSpecialHex(specialhex_list)
	Map.specialhex_list = specialhex_list
	
	# Serialization Send to Client
	var hexpack: PackedByteArray = var_to_bytes_with_objects(specialhex_list)
	# Can do serialization on dictionary, too... Hmmmmmm
	#var hexpack: PackedByteArray = var_to_bytes_with_objects(GameData.hex_dict)
	print(hexpack.size())
	Auth_Rem_ToClient_SendSpecialHexData.rpc(hexpack)
	# Multiplayer Synchronizer syncs when this happens. Do everything else before it.
	add_child(map, true)

@rpc("any_peer", "call_remote", "reliable")
func Rem_ToServer_AskForSpecialHexes() -> void:
	if not GameData.isServer: return
	var sender_id: int = multiplayer.get_remote_sender_id()
	var hexpack: PackedByteArray = var_to_bytes_with_objects(Map.specialhex_list)
	Auth_Rem_ToClient_SendSpecialHexData.rpc_id(sender_id,hexpack)
@rpc("authority", "call_remote", "reliable")
func Auth_Rem_ToClient_SendSpecialHexData(hexpack: PackedByteArray) -> void:
	if GameData.isServer: return
	var special_hex_list: Array[Hex] = bytes_to_var_with_objects(hexpack)
	Map.ModifyHexMapWithSpecialHex(special_hex_list)
	if worldhex_list.is_empty():
		PopulateWorldHexes()

## Clickable hexes map
func PopulateWorldHexes() -> void:
	var hex_list: Array[Hex] = GameData.hex_dict.values() as Array[Hex]
	for hex in hex_list:
		if hex.tile_flags & Hex.TILE_FLAGS.WALL: continue
		var newnode: WorldHex = ClientData.worldhex_scene.instantiate()
		var pos: Vector2 = HexMath.hex_to_pixel(hex.coord)
		newnode.position = Vector3(pos.x,0,pos.y)
		add_child(newnode)
		worldhex_list.push_back(newnode)

var worldhex_list: Array[WorldHex] = []
var worldhex_hovered: WorldHex = null

func _physics_process(delta: float) -> void:
	if not GameData.started: return
	
	var mousePos: Vector2 = ClientData.mousePos
	var space_state = get_world_3d().direct_space_state
	var from: Vector3 = THECamera_Node.project_ray_origin(mousePos)
	var to: Vector3 = THECamera_Node.global_position + THECamera_Node.project_ray_normal(mousePos) * 200.0
	GameData.rayquery_wall.from = from
	GameData.rayquery_wall.to = to
	
	var worldhex: WorldHex = null
	
	var result: Dictionary = space_state.intersect_ray(GameData.rayquery_wall)
	if result and result.collider is WorldPickable:
		var worldPick: WorldPickable = result.collider as WorldPickable
		if worldPick.LogicNode is WorldHex:
			worldhex = worldPick.LogicNode as WorldHex
	
	if worldhex_hovered != worldhex:
		if worldhex_hovered != null:
			worldhex_hovered.SetHovered(false)
		worldhex_hovered = worldhex
		if worldhex != null: worldhex.SetHovered(true)
	
	var unit_list: Array[Unit] = GameData.unit_list_temp
	
	var has_actor: bool = is_instance_valid(GameData.current_actor)
	var time_pass: int = 0
	if not has_actor:
		time_pass = floori(BattleTimeline.time_per_second * delta)
		time_pass = maxi(time_pass, 10)
		time_pass = GetShortestActTime(time_pass)
	
	if time_pass > 0:
		for unit: Unit in unit_list:
			var skill: SkillBase = unit.skill_selected
			if is_instance_valid(skill):
				TickDownSkill(skill, time_pass)
			else:
				unit.overhead_downtime -= time_pass
	else:
		if not has_actor:
			var actors: Array[Unit] = []
			for unit: Unit in unit_list:
				var downtime: int = unit.GetSumDowntime()
				if downtime < 1: actors.push_back(unit)
			
			actors.sort_custom(func(a: Unit, b: Unit) -> bool:
				var a_speed: int = a.GetSumSpeed()
				var b_speed: int = b.GetSumSpeed()
				if a_speed == b_speed:
					return a.unitID < b.unitID # Tiebreaker
				return a_speed < b_speed
			)
			
			var selected_actor: Unit = actors[0]
			GameData.current_actor = selected_actor
			has_actor = true
		
		if Input.is_action_just_pressed(&"ACT_Space"):
			GameData.current_actor.overhead_downtime += randi_range(5000,60000)
			GameData.current_actor = null
			BattleTimeline.SetTimelineLimit()

func ProcessTurn() -> void:
	pass

func GetShortestActTime(lowest: int) -> int:
	for unit: Unit in GameData.unit_list_temp:
		var skill: SkillBase = unit.skill_selected
		if is_instance_valid(skill):
			var instruction: SkillInstruction = skill.instruction_list[0]
			if instruction.timer < lowest: lowest = instruction.timer
		else:
			var downtime: int = unit.GetSumDowntime()
			if downtime < lowest: lowest = downtime
	
	return lowest

func TickDownSkill(skill: SkillBase, time_pass: int) -> void:
	var instruction: SkillInstruction = skill.instruction_list[0]
	instruction.timer -= time_pass

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
