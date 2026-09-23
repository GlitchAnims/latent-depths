class_name WorldHex extends Node3D

@onready var HexModel_Node: MeshInstance3D = $"HexModel"
@onready var RingModel_Node: MeshInstance3D = $"HexRing"

var hex_ref: Hex = null

func SetHovered(b: bool) -> void:
	if b:
		var mat: ShaderMaterial = HexModel_Node.material_override
		mat.set_shader_parameter(&"alpha_mult", 1.0)
	else:
		var mat: ShaderMaterial = HexModel_Node.material_override
		mat.set_shader_parameter(&"alpha_mult", 0.4)
	

func SetHexColor(color: Color = Color.RED) -> void:
	var mat: ShaderMaterial = HexModel_Node.material_override
	mat.set_shader_parameter(&"custom_color", color)

func SetRingColor(color: Color = Color.RED) -> void:
	var mat: ShaderMaterial = RingModel_Node.material_override
	mat.set_shader_parameter(&"custom_color", color)
