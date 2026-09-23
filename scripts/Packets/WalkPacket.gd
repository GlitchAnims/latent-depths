class_name WalkPacket extends Object

var vec: Vector3 = Vector3.ZERO
var vec_norm: Vector3 = Vector3.ZERO

func Reset() -> void:
	vec = Vector3.ZERO
	vec_norm = Vector3.ZERO

func _init(vec_set: Vector3 = Vector3.ZERO, vec_norm_set: Vector3 = Vector3.ZERO) -> void:
	vec = vec_set
	vec_norm = vec_norm_set
