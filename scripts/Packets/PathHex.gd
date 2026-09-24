class_name PathHex extends RefCounted

func _init(set_dist: int, set_coord_from: Vector2i = Vector2i.ZERO) -> void:
	dist = set_dist
	coord_from = set_coord_from

var dist: int = -1
var coord_from: Vector2i = Vector2i.ZERO
