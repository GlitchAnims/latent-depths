class_name WorldHex extends Node3D

@onready var HexModel_Node: MeshInstance3D = $"HexModel"
@onready var RingModel_Node: MeshInstance3D = $"HexRing"
@onready var WalkArrow_Node: Node3D = $"WalkArrow"

var hex_ref: Hex = null

func _ready() -> void:
	ClearHexWidgets()

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

func AimWalkArrow(aim_pos: Vector3 = Vector3.ZERO) -> void:
	WalkArrow_Node.visible = true
	WalkArrow_Node.look_at(aim_pos)

func ClearHexWidgets() -> void:
	SetHexColor()
	SetRingColor()
	WalkArrow_Node.visible = false
