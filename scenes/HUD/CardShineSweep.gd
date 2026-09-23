class_name CardShineSweep extends Panel

@onready var _Anim_Node: AnimationPlayer = $"Anim"
var mode: int = 0

func _ready() -> void:
	match mode:
		0:
			pass
		1:
			self_modulate = Color(0.8,0.8,0.8,1.0)
			offset_transform_rotation = PI
			offset_transform_position_ratio.y = -1.0
	
	_Anim_Node.play(&"LIB_CardShineSweep/Sweep")
