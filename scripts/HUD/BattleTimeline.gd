class_name BattleTimeline extends HBoxContainer

@onready var Ruler_Node: Control = $"Ruler"
@onready var RulerLine_Node: Line2D = $"Ruler/RulerLine"

const time_per_second: int = 10000
const timeline_limit: int = time_per_second * 5

const timeline_marker_scene: PackedScene = preload("res://scenes/HUD/timeline_marker.tscn")

var myturn_list: Array[TimelineMarker] = []

func _physics_process(delta: float) -> void:
	var time_pass: int = time_per_second * delta
	
	var ruler_end: Vector2 = Ruler_Node.get_end()
	var ruler_middle: Vector2 = ruler_end / 2
	
	var line_start: Vector2 = Vector2(ruler_end.x*0.04,ruler_middle.y)
	var line_end: Vector2 = Vector2(ruler_end.x*0.96,ruler_middle.y)
	
	RulerLine_Node.set_point_position(0,line_start)
	RulerLine_Node.set_point_position(1,line_end)
	
	var unit_list: Array[Unit] = GameData.unitDict.values() as Array[Unit]
	var unit_count: int = unit_list.size()
	var marker_count: int = myturn_list.size()
	
	if unit_count != marker_count:
		RefreshAllMarkers(unit_list)
	
	#for unit: Unit in unit_list:
	for marker: TimelineMarker in myturn_list:
		var unit: Unit = marker.unit_ref
		var downtime: int = unit.GetSumDowntime()
		var timeline_mult: float = float(downtime) / timeline_limit
		var timeline_pos: float = timeline_mult * (line_end.x-line_start.x)
		marker.position = line_end - Vector2(timeline_pos,0)

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
			Ruler_Node.add_child(marker)
			unit.overhead_downtime = randi_range(10,30000)
			marker.IDLabel.text = str(unit.unitID)
