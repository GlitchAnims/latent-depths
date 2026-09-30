extends Vis

@export var Showcase_Node: AnimatedSprite3D = null

func _ready() -> void:
	pass

func Incantate(incantation: Incantation, _delta: float) -> void:
	var inc: Incantation.Standard_Walk = incantation as Incantation.Standard_Walk
	Vis_Anim_Node.play(&"tanglecleaver_prep")
	cur_inc = incantation
	ClientData.stealcamera_timer = 0.7
	var globpos: Vector3 = global_position
	ClientData.stealcamera_aim = globpos
	ClientData.stealcamera_pos = globpos + Vector3(0,2,3)

var cur_inc: Incantation = null

func _on_anim_animation_finished(anim_name: StringName) -> void:
	if cur_inc != null:
		ClientData.incantation_list.erase(cur_inc)
		cur_inc = null
	
	if anim_name == &"tanglecleaver_prep":
		Vis_Anim_Node.play(&"tanglecleaver_prep_continuous")

func StealCamera() -> void:
	pass
