class_name Gamespace extends Node3D

@onready var UnitSpawner_Node: MultiplayerSpawner = $"UnitSpawner"
@onready var Unitry_Node: Node3D = $"Unitry"

@onready var THECamera_Node: Camera3D = $"THECamera"

@onready var AudioManager_Node: AudioManager = $"AudioManager"

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
	var hexpack: PackedByteArray = GameData.Stronghold_Node.pickler.pickle(Map.specialhex_list)
	Auth_Rem_ToClient_SendSpecialHexData.rpc_id(sender_id,hexpack)
@rpc("authority", "call_remote", "reliable")
func Auth_Rem_ToClient_SendSpecialHexData(hexpack: PackedByteArray) -> void:
	if GameData.isServer: return
	var unpickled: Array = GameData.Stronghold_Node.pickler.unpickle(hexpack)
	var special_hex_list: Array[Hex] = []
	for obj in unpickled:
		if obj is Hex: special_hex_list.push_back(obj as Hex)
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
		newnode.hex_ref = hex
		newnode.position = Vector3(pos.x,0,pos.y)
		add_child(newnode)
		worldhex_list.push_back(newnode)
		worldhex_dict[hex.coord] = newnode

var worldhex_list: Array[WorldHex] = []
var worldhex_dict: Dictionary[Vector2i, WorldHex] = {}
var worldhex_hovered: WorldHex = null
var worldhex_lock: WorldHex = null

var unit_hovered: Unit = null
var unit_lock: Unit = null

func Server_SetActorForAll(unit: Unit) -> void:
	GameData.current_actor = unit
	if is_instance_valid(unit):
		unit.heard_teams_flags = 0
		Auth_Rem_ToClient_SetActor.rpc(unit.unitID)
	else:
		Auth_Rem_ToClient_SetActor.rpc(-1)

@rpc("authority", "call_remote", "reliable")
func Auth_Rem_ToClient_SetActor(unit_id: int) -> void:
	if GameData.isServer: return
	var unit: Unit = GameData.unit_dict.get(unit_id,null)
	GameData.current_actor = unit
	if unit != null:
		unit.heard_teams_flags = 0

func DoWorldHexRay(space_state: PhysicsDirectSpaceState3D, from: Vector3, to: Vector3) -> WorldHex:
	GameData.rayquery_worldHex.from = from
	GameData.rayquery_worldHex.to = to
	var result: Dictionary = space_state.intersect_ray(GameData.rayquery_worldHex)
	if result and result.collider is WorldPickable:
		var worldPick: WorldPickable = result.collider as WorldPickable
		if worldPick.LogicNode is WorldHex: return worldPick.LogicNode as WorldHex
	return null

func DoUnitRay(space_state: PhysicsDirectSpaceState3D, from: Vector3, to: Vector3) -> Unit:
	GameData.rayquery_unit.from = from
	GameData.rayquery_unit.to = to
	if is_instance_valid(GameData.current_actor):
		GameData.rayquery_unit.set_exclude([GameData.current_actor.MouseSelector_Node.get_rid()])
	else: GameData.rayquery_unit.set_exclude([])
	var result: Dictionary = space_state.intersect_ray(GameData.rayquery_unit)
	if result and result.collider is WorldPickable:
		var worldPick: WorldPickable = result.collider as WorldPickable
		if worldPick.LogicNode is Unit: return worldPick.LogicNode as Unit
	return null

func _physics_process(delta: float) -> void:
	if not GameData.started: return
	
	var mousePos: Vector2 = ClientData.mousePos
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var from: Vector3 = THECamera_Node.project_ray_origin(mousePos)
	var to: Vector3 = THECamera_Node.global_position + THECamera_Node.project_ray_normal(mousePos) * 200.0
	
	var worldhex_current: WorldHex = worldhex_lock
	var worldHex_pick: WorldHex = DoWorldHexRay(space_state, from, to)
	if worldHex_pick != null: worldhex_current = worldHex_pick
	
	var unit_current: Unit = unit_lock
	var unit_pick: Unit = DoUnitRay(space_state, from, to)
	if unit_pick != null: unit_current = unit_pick
	
	if ClientData.press_m2:
		unit_lock = unit_current
	ClientData.infomercial_unit = unit_current
	
	if unit_hovered != unit_current:
		if unit_hovered != null: unit_hovered.SetHovered(false)
		unit_hovered = unit_current
		if unit_hovered != null: unit_hovered.SetHovered(true)
	
	var worldhex_do_update: bool = false
	
	if ClientData.press_m1:
		worldhex_lock = worldhex_current
		worldhex_do_update = true
	
	if worldhex_hovered != worldhex_current:
		worldhex_do_update = true
		if worldhex_hovered != null:
			worldhex_hovered.SetHovered(false)
		worldhex_hovered = worldhex_current
		if worldhex_current != null: worldhex_current.SetHovered(true)
	
	if worldhex_do_update:
		for worldhex: WorldHex in worldhex_list:
			worldhex.ClearHexWidgets()
	
	var unit_list: Array[Unit] = GameData.unit_list_temp
	
	var has_actor: bool = is_instance_valid(GameData.current_actor)
	var time_mult: float = delta
	var time_pass: int = 0
	if not has_actor:
		@warning_ignore("narrowing_conversion")
		var slowdown_thres: int = BattleTimeline.time_per_second * 0.5
		var shortest_act_time: int = GetShortestActTime(slowdown_thres)
		if shortest_act_time < slowdown_thres:
			time_mult *= (float(shortest_act_time) / slowdown_thres) * 0.8 + 0.2
		time_pass = floori(BattleTimeline.time_per_second * time_mult)
		time_pass = maxi(time_pass, 10)
		
		time_pass = clamp(time_pass, 0, shortest_act_time)
	
	if time_pass > 0:
		AudioManager_Node.RunTimelineClick(time_mult*30)
		for unit: Unit in unit_list:
			var skill: SkillBase = unit.skill_selected
			if is_instance_valid(skill):
				TickDownSkill(skill, time_pass)
			else:
				unit.overhead_downtime -= time_pass
	elif GameData.isServer:
		if not has_actor:
			var actors: Array[Unit] = []
			for unit: Unit in unit_list:
				var downtime: int = unit.GetSumDowntime()
				if downtime < 1: actors.push_back(unit)
			
			if actors.is_empty(): # Means a Skill somewhere is now at 0 instruction timer
				
				var bad_actor: Unit = null
				var bad_skill: SkillBase = null
				var bad_skillstruction: SkillInstruction = null
				for unit: Unit in unit_list:
					bad_skill = unit.skill_selected
					if not is_instance_valid(bad_skill): continue
					var skillstruction_list: Array[SkillInstruction] = bad_skill.instruction_list
					if not skillstruction_list.is_empty():
						bad_skillstruction = skillstruction_list[0]
						var timer: int = bad_skillstruction.timer
						if timer < 1:
							bad_actor = unit
							break
				
				if bad_actor != null:
					bad_skill.instruction_list.pop_front()
					var packed_ins_list: PackedByteArray = GameData.Stronghold_Node.pickler.pickle(bad_skill.instruction_list)
					bad_actor.Auth_Rem_ToClient_SendSkillstructionArray(bad_skill.skill_ID, packed_ins_list)
					bad_skill.Server_PerformInstruction(bad_skillstruction)
				
			else: # No Possible Actors, find New Turn
				var selected_actor: Unit = actors[0]
				GameData.current_actor = selected_actor
				Server_SetActorForAll(selected_actor)
				has_actor = true
	
	if has_actor:
		var actor: Unit = GameData.current_actor
		var skill: SkillBase = ClientData.temp_skill
		if is_instance_valid(skill):
			var hex_from: Hex = GameData.hex_dict[actor.pos_hex]
			
			if worldhex_do_update:
				for obj: WorldHex in worldhex_list:
					if skill.IsHexSelectable(hex_from, obj.hex_ref): obj.SetHexColor(Color.GREEN)
					else: obj.SetHexColor(Color.RED)
			
			if is_instance_valid(worldhex_lock):
				var hex_to: Hex = worldhex_lock.hex_ref
				var canchoose: bool = skill.IsHexSelectable(hex_from, hex_to)
				
				if canchoose:
					ClientData.temp_skillstruction_list = skill.FabricateSkillstructions(hex_from,hex_to)
					if worldhex_do_update: skill.DoWorldHexWidgets(worldhex_dict)
				else: ClientData.temp_skillstruction_list = []
				
				if ClientData.press_space and canchoose:
					if GameData.isServer:
						GameData.current_actor = null
						Server_SetActorForAll(null)
						actor.Server_UseSkill(skill, ClientData.temp_skillstruction_list)
						ClientData.temp_skillstruction_list = []
						ClientData.temp_skill = null
					else:
						actor.Rem_ToServer_TryUseSkill.rpc_id(1, skill.skill_ID, hex_to.coord)
					#actor.pos_hex = hex_to.coord
					#actor.SnapPositionToHexPos()



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
