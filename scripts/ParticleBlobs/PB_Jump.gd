extends ParticleBlob

@onready var Woosh_Node: MeshInstance3D = $"Woosh"
var _time_elapsed: float = 0.0
var _xdisp: float = 0.0

func _process(delta: float) -> void:
	_time_elapsed += delta * 2.8
	if _time_elapsed >= 1.0:
		queue_free()
		return
	
	var value_ease: float = 1 - pow(1 - _time_elapsed, 3)
	
	Woosh_Node.set_instance_shader_parameter("fragment_xdisplace", _xdisp)
	Woosh_Node.set_instance_shader_parameter("fragment_progress", value_ease)
	Woosh_Node.set_instance_shader_parameter("vertex_progress", value_ease)
	
	var speed_mult: float = 1.3 - _time_elapsed
	_xdisp += delta * 2.5 * speed_mult
