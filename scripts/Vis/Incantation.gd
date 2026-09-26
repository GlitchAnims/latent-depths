class_name Incantation extends RefCounted

var _call_mode: int = 0
var incantation_ID: int = 0
var node_ref: Node = null
var anim_progress: float = 0

func _init(set_node_ref: Node) -> void:
	node_ref = set_node_ref
	if node_ref is Unit: _call_mode = 0
	elif node_ref is SkillBase: _call_mode = 1

func CallAnim(delta: float) -> void:
	if not is_instance_valid(node_ref):
		node_ref = null
		ClientData.incantation_list.pop_front()
	
	match _call_mode:
		0:
			var unit: Unit = node_ref as Unit
			unit.Incantate(self, delta)
		1:
			var skill: SkillBase = node_ref as SkillBase
			skill.Incantate(self, delta)
