class_name SkillstructionMarkerBig extends Control

@onready var Encompass_Node: Panel = $"Encompass"
@onready var TimerLabel_Node: Label = $"Timer"
@onready var TeamLabel_Node: Label = $"Team"
@onready var UnitIcon_Node: TextureRect = $"UnitIcon"
@onready var InstructionIcon_Node: TextureRect = $"InstructionIcon"
@onready var FocusColor_Node: ColorRect = $"FocusColor"

const icon_walk: AtlasTexture = preload("res://sprites/Icons/Atlas/walk.tres")
const icon_special: AtlasTexture = preload("res://sprites/Icons/Atlas/special.tres")
const icon_default: Texture = preload("res://sprites/UnitSprites/Firefist/dmg.png")
var unit_ref: Unit = null


func SetTimer(timer: int) -> void:
	TimerLabel_Node.text = String.num(float(timer) / BattleTimeline.time_per_second, 2) + "s"

func SetTeam(team: int) -> void:
	FocusColor_Node.color = Color.BLACK
	TeamLabel_Node.text = "Team " + str(team)

func SetIsActor(b: bool) -> void:
	if b: FocusColor_Node.color = Color.PURPLE * 0.6

func SetIsInfomercial(b: bool) -> void:
	if b: FocusColor_Node.color = Color.RED * 0.6

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
		SkillInstruction.INS_TYPE.special:
			set_texture = icon_special
			set_color = Color.WHITE
	
	InstructionIcon_Node.texture = set_texture
	InstructionIcon_Node.modulate = set_color
	Encompass_Node.modulate = Color.BLUE
