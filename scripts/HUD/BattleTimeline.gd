class_name BattleTimeline extends HBoxContainer

@onready var Ruler_Node: Control = $"Ruler"
@onready var RulerLine_Node: Line2D = $"Ruler/RulerLine"

const time_per_second: int = 10000
static var timeline_limit: int = time_per_second * 3

const timeline_marker_scene: PackedScene = preload("res://scenes/HUD/timeline_marker.tscn")
const timeline_seconds_scene: PackedScene = preload("res://scenes/HUD/timeline_marker_seconds.tscn")
const si_marker_scene: PackedScene = preload("res://scenes/HUD/skillstruction_marker.tscn")
const si_marker_big_scene: PackedScene = preload("res://scenes/HUD/skillstruction_marker_big.tscn")


const const_si_marker_big_size: Vector2 = Vector2(72,146)
var si_marker_big_size: Vector2 = const_si_marker_big_size
var si_marker_big_scale: Vector2 = const_si_marker_big_size

var myturn_list: Array[TimelineMarker] = []
var secondmarker_list: Array[TimelineMarker_Seconds] = []
var skillstruction_line_list: Array[Line2D] = []
var si_marker_list: Array[SkillstructionMarker] = []
var si_marker_big_list: Array[SkillstructionMarkerBig] = []

var client_scale: float = 1.0

func UpdateSize(set_client_scale: float, item_scale: Vector2) -> void:
	client_scale = set_client_scale
	si_marker_big_scale = item_scale * 0.8
	si_marker_big_size = const_si_marker_big_size * si_marker_big_scale
	
	custom_minimum_size = si_marker_big_size
	
	for marker: SkillstructionMarker in si_marker_list:
		marker.scale = item_scale * 1.2
	for marker: SkillstructionMarkerBig in si_marker_big_list:
		marker.scale = si_marker_big_scale
	
	RulerLine_Node.width = 3.0 * client_scale

static func SetTimelineLimit() -> void:
	var longest: int = time_per_second * 4
	for unit: Unit in GameData.unit_list_temp:
		var downtime: int = unit.GetSumDowntime()
		if downtime > longest: longest = downtime
	
	@warning_ignore("narrowing_conversion")
	timeline_limit = longest

func _ready() -> void:
	for i in 6:
		var newnode: Line2D = Line2D.new()
		newnode.visible = false
		newnode.width = 5.0
		newnode.add_point(Vector2.ZERO)
		newnode.add_point(Vector2(1,0))
		RulerLine_Node.add_child(newnode)
		skillstruction_line_list.push_back(newnode)
	
	for i in 30:
		var newnode: SkillstructionMarker = si_marker_scene.instantiate()
		newnode.visible = false
		RulerLine_Node.add_child(newnode)
		si_marker_list.push_back(newnode)
	
	for i in 30:
		var newnode: SkillstructionMarkerBig = si_marker_big_scene.instantiate()
		newnode.visible = false
		RulerLine_Node.add_child(newnode)
		si_marker_big_list.push_back(newnode)

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	SetTimelineLimit()
	#TimeLabel.text = String.num(float(timeline_limit) / time_per_second, 1) + "s"
	
	var sec_mark_count: int = secondmarker_list.size()
	@warning_ignore("integer_division")
	var sec_sect_count: int = timeline_limit*2/time_per_second
	
	if sec_mark_count < sec_sect_count:
		for i in sec_sect_count-sec_mark_count:
			var new_node: TimelineMarker_Seconds = timeline_seconds_scene.instantiate()
			RulerLine_Node.add_child(new_node)
			secondmarker_list.push_back(new_node)
		sec_mark_count = secondmarker_list.size()
	
	var ruler_begin: Vector2 = Ruler_Node.get_begin()
	var ruler_end: Vector2 = Ruler_Node.get_end()
	var ruler_vec: Vector2 = ruler_end - ruler_begin
	#var ruler_middle: Vector2 = ruler_vec / 2
	
	var line_start: Vector2 = Vector2(ruler_vec.x*0.04,-20)
	var line_end: Vector2 = Vector2(ruler_vec.x*0.96,-20)
	
	RulerLine_Node.set_point_position(0,line_start)
	RulerLine_Node.set_point_position(1,line_end)
	
	for i in sec_mark_count:
		var marker: TimelineMarker_Seconds = secondmarker_list[i]
		@warning_ignore("narrowing_conversion")
		var marker_time: int = time_per_second*i*0.5
		var marker_visible: bool = marker_time < timeline_limit - (time_per_second*0.1)
		marker.visible = marker_visible
		if marker_visible:
			marker.IDLabel.text = String.num(0.5 * i, 1) + "s"
			var timeline_mult: float = float(marker_time) / timeline_limit
			var timeline_pos: float = timeline_mult * (line_end.x-line_start.x)
			marker.position = line_end - Vector2(timeline_pos,0)
	
	var unit_list: Array[Unit] = GameData.unit_list_temp
	#var unit_count: int = unit_list.size()
	#var marker_count: int = myturn_list.size()
	#if unit_count != marker_count:
		#RefreshAllMarkers(unit_list)
	#for unit: Unit in unit_list:
	#for marker: TimelineMarker in myturn_list:
		#var unit: Unit = marker.unit_ref
		#var downtime: int = unit.GetSumDowntime()
		#var timeline_mult: float = float(downtime) / timeline_limit
		#var timeline_pos: float = timeline_mult * (line_end.x-line_start.x)
		#marker.position = line_end - Vector2(timeline_pos,0)
	
	var ins_list: Array[SkillInstruction] = ClientData.temp_skillstruction_list
	var ins_count: int = ins_list.size()
	for i in skillstruction_line_list.size():
		var line: Line2D = skillstruction_line_list[i]
		line.visible = i < ins_count
	
	var last_ins_time: int = 0
	for i in ins_count:
		var line: Line2D = skillstruction_line_list[i]
		var ins: SkillInstruction = ins_list[i]
		var ins_time: int = last_ins_time + ins.timer
		var ins_color: Color = Color.CHOCOLATE
		
		var ins_start_mult: float = float(last_ins_time) / timeline_limit
		var ins_start_pos: float = ins_start_mult * (line_end.x-line_start.x)
		
		var ins_end_mult: float = float(ins_time) / timeline_limit
		var ins_end_pos: float = ins_end_mult * (line_end.x-line_start.x)
		
		if ins.ins_type == SkillInstruction.INS_TYPE.ability:
			ins_color = Color.BLUE
			line.set_point_position(0,line_end - Vector2(ins_start_pos,10))
			line.set_point_position(1,line_end - Vector2(ins_start_pos,-10))
		else:
			if ins.ins_type == SkillInstruction.INS_TYPE.down: ins_color = Color.RED
			line.set_point_position(0,line_end - Vector2(ins_start_pos,0))
			line.set_point_position(1,line_end - Vector2(ins_end_pos,0))
		
		line.default_color = ins_color
		last_ins_time = ins_time
	
	var order_list: Array[SkillInsOrder] = []
	var time_cumulative: int = 0
	
	var cur_actor: Unit = GameData.cur_actor
	var cur_actor_is_valid: bool = GameData.cur_actor_is_valid
	
	for unit: Unit in unit_list:
		time_cumulative = 0
		if unit == cur_actor:
			for ins: SkillInstruction in ins_list:
				time_cumulative += ins.timer
				var order: SkillInsOrder = SkillInsOrder.new()
				order.ins = ins
				order.time = time_cumulative
				order.unit = unit
				order_list.push_back(order)
		
		if is_instance_valid(unit.skill_selected):
			var skill: SkillBase = unit.skill_selected
			for ins: SkillInstruction in skill.instruction_list:
				time_cumulative += ins.timer
				var order: SkillInsOrder = SkillInsOrder.new()
				order.ins = ins
				order.time = time_cumulative
				order.unit = unit
				order_list.push_back(order)
		
		if unit.overhead_downtime > 0:
			time_cumulative += unit.overhead_downtime
			var order: SkillInsOrder = SkillInsOrder.new()
			order.is_turn_recovery = true
			order.time = time_cumulative
			order.unit = unit
			order_list.push_back(order)
	
	#if is_instance_valid(GameData.cur_actor):
		#var unit: Unit = GameData.cur_actor
		#for ins: SkillInstruction in ins_list:
			#time_cumulative += ins.timer
			#var order: SkillInsOrder = SkillInsOrder.new()
			#order.ins = ins
			#order.time = time_cumulative
			#order.unit = unit
			#order_list.push_back(order)
	#
	#if is_instance_valid(ClientData.infomercial_unit):
		#var unit: Unit = ClientData.infomercial_unit
		#if is_instance_valid(unit.skill_selected):
			#var skill: SkillBase = unit.skill_selected
			#time_cumulative = 0
			#for ins: SkillInstruction in skill.instruction_list:
				#time_cumulative += ins.timer
				#var order: SkillInsOrder = SkillInsOrder.new()
				#order.ins = ins
				#order.time = time_cumulative
				#order.unit = unit
				#order_list.push_back(order)
	
	order_list.sort_custom(func(a: SkillInsOrder, b: SkillInsOrder) -> bool:
		var a_speed: int = a.time
		var b_speed: int = b.time
		if a_speed == b_speed:
			a_speed = a.unit.GetSumSpeed()
			b_speed = b.unit.GetSumSpeed()
			if a_speed == b_speed:
				return a.unit.unitID < b.unit.unitID
		return a_speed < b_speed
	)
	
	var order_count: int = order_list.size()
	var actor_ID: int = cur_actor.unitID if cur_actor_is_valid else -1
	var infomercial_ID: int = ClientData.infomercial_unit.unitID if is_instance_valid(ClientData.infomercial_unit) else -1
	
	var si_marker_count: int = si_marker_list.size()
	var too_close_value: float = -1.0
	var order_height_level: int = 0
	for i in si_marker_count:
		var marker: SkillstructionMarker = si_marker_list[i]
		var marker_visible: bool = i < order_count
		marker.visible = marker_visible
		if not marker_visible: continue
		
		var order: SkillInsOrder = order_list[i]
		var marker_mult: float = float(order.time) / timeline_limit
		
		var overlap: bool = marker_mult-too_close_value < 0.03
		if overlap:
			order_height_level += 1
		else:
			too_close_value = marker_mult
			order_height_level = 0
		var marker_dist: float = marker_mult * (line_end.x-line_start.x)
		marker.position = line_end - Vector2(marker_dist,0)
		
		var unit: Unit = order.unit
		marker.SetFocus(unit.unitID == actor_ID, unit.unitID == infomercial_ID)
		marker.SetHeightLevel(order_height_level)
		marker.SetUnitID(order.unit.unitID)
		if order.is_turn_recovery:
			marker.SetInstructionType(SkillInstruction.INS_TYPE.special)
		else:
			var ins_type: SkillInstruction.INS_TYPE = order.ins.ins_type
			marker.SetInstructionType(ins_type)
	
	
	var si_marker_big_offset: float = 0
	var si_marker_big_count: int = si_marker_list.size()
	for i in si_marker_big_count:
		var marker: SkillstructionMarkerBig = si_marker_big_list[i]
		var marker_visible: bool = i < order_count
		marker.visible = marker_visible
		if not marker_visible: continue
		
		var order: SkillInsOrder = order_list[i]
		marker.position = ruler_vec - Vector2(si_marker_big_offset,0)
		si_marker_big_offset += si_marker_big_size.x
		
		var unit: Unit = order.unit
		marker.SetTeam(unit.team)
		marker.SetIsActor(unit.unitID == actor_ID)
		marker.SetIsInfomercial(unit.unitID == infomercial_ID)
		marker.SetTimer(order.time)
		marker.unit_ref = unit
		if order.is_turn_recovery: marker.SetInstructionType(SkillInstruction.INS_TYPE.special)
		else: marker.SetInstructionType(order.ins.ins_type)
	

class SkillInsOrder extends RefCounted:
	var ins: SkillInstruction
	var unit: Unit
	var time: int
	var is_turn_recovery: bool = false

func RefreshAllMarkers(unit_list: Array[Unit]) -> void:
	var marker_count: int = myturn_list.size()
	for i in marker_count:
		var idx: int = marker_count - 1 - i
		var ref: Unit = myturn_list[idx].unit_ref
		if not is_instance_valid(ref) or ref.hp <= 0:
			myturn_list[idx].queue_free()
			myturn_list.remove_at(idx)
	
	for unit: Unit in unit_list:
		var has_marker: bool = false
		for marker: TimelineMarker in myturn_list:
			if marker.unit_ref == unit:
				has_marker = true
				break
		
		if not has_marker:
			var marker: TimelineMarker = timeline_marker_scene.instantiate()
			marker.unit_ref = unit
			myturn_list.push_back(marker)
			RulerLine_Node.add_child(marker)
			marker.IDLabel.text = str(unit.unitID)
