class_name SkillstructionMarker extends Control

@onready var GraphHolder_Node: Control = $"GraphHolder"
@onready var UnitIDLabel_Node: Label = $"GraphHolder/UnitID"
@onready var Icon_Node: TextureRect = $"GraphHolder/InstructionIcon"
@onready var Panel_Node: Panel = $"GraphHolder/Panel"

const icon_walk: AtlasTexture = preload("res://sprites/Icons/Atlas/walk.tres")
const icon_attack: AtlasTexture = preload("res://sprites/Icons/Atlas/attack.tres")
const icon_special: AtlasTexture = preload("res://sprites/Icons/Atlas/special.tres")
const icon_default: Texture = preload("res://sprites/UnitSprites/Firefist/dmg.png")

func SetHeightLevel(level: int) -> void:
	
	var graph_height: float = level * 20.0
	GraphHolder_Node.position.y = -graph_height

func SetFocus(is_actor: bool, is_infomercial: bool) -> void:
	if is_actor: Panel_Node.self_modulate = Color.PURPLE*0.7
	elif is_infomercial: Panel_Node.self_modulate = Color.RED*0.7
	else: Panel_Node.self_modulate = Color(0.012,0.012,0.012)

func SetUnitID(unit_ID: int) -> void:
	UnitIDLabel_Node.text = str(unit_ID)

func SetInstructionType(ins_type: SkillInstruction.INS_TYPE) -> void:
	var set_color: Color = Color.RED
	var set_texture: Texture = icon_default
	
	match ins_type:
		SkillInstruction.INS_TYPE.down:
			set_texture = icon_special
			set_color = Color.GREEN
		SkillInstruction.INS_TYPE.walk:
			set_texture = icon_walk
			set_color = Color.WHITE
		SkillInstruction.INS_TYPE.attack:
			set_texture = icon_attack
			set_color = Color.RED * 0.4 + Color.WHITE * 0.4
		SkillInstruction.INS_TYPE.special:
			set_texture = icon_special
			set_color = Color.WHITE
	
	Icon_Node.texture = set_texture
	Icon_Node.modulate = set_color
