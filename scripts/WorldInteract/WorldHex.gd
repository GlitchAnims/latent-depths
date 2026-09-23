class_name WorldHex extends Node3D

@onready var HexModel_Node: MeshInstance3D = $"HexModel"

var hex_ref: Hex = null

func SetHovered(b: bool) -> void:
	if b:
		var mat: ShaderMaterial = HexModel_Node.material_override
		mat.set_shader_parameter(&"alpha_mult", 1.0)
	else:
		var mat: ShaderMaterial = HexModel_Node.material_override
		mat.set_shader_parameter(&"alpha_mult", 0.4)
	
