class_name Standin extends Node3D

var unit_ref: Unit = null
@onready var GUI_Node: = $"GUI"
@export var UnitStatus_Node: UnitStatus = null

var instant_move: bool = true

func _ready() -> void:
	if not is_instance_valid(unit_ref): return
	UnitStatus_Node.Setup(unit_ref)
	position = unit_ref.position
	for skill in unit_ref.skill_list: skill.standin_ref = self
	_ready_standin()
func _ready_standin() -> void: pass

func _process(delta: float) -> void:
	if not is_instance_valid(unit_ref):
		queue_free()
		return
	
	#var unit_vel: Vector3 = unit_ref.velocity
	#var unit_speed: float = unit_vel.length()
	#var unit_speed_delta: float = unit_speed * delta
	
	var unit_vec: Vector3 = unit_ref.position - position
	#var unit_norm: Vector3 = unit_vec.normalized()
	#var unit_dist: float = unit_vec.length()
	
	var stepmove: Vector3 = unit_vec * 0.5
	var stepmove_dist: float = stepmove.length()
	
	var speed_min: float = 0.5 * delta
	if instant_move or stepmove_dist < speed_min:
		position = unit_ref.position
		instant_move = false
	else:
		position += stepmove
	
	_process_standin(delta)
func _process_standin(_delta: float) -> void: pass
