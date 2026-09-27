class_name Vis extends Node3D

const visual_factor_limit: float = TAU*100
var visual_factor: float = 0

func _process(delta: float) -> void:
	visual_factor += delta
	if visual_factor >= visual_factor_limit: visual_factor -= visual_factor_limit
	
	if shake_timer > 0:
		position = Vector3(sin(visual_factor*65), 0, cos(visual_factor*80)) * shake_timer * 0.2
		shake_timer = maxf(shake_timer-delta*2,0)
	else:
		position = Vector3.ZERO

var shake_timer: float = 0
func GainShake() -> void:
	shake_timer = 1.0
