class_name UnitOverheadStatus extends Control

@export var HealthBar_Node: ProgressBar = null
@export var ActionBar_Node: ProgressBar = null
@export var InstructionPanel_Node: Panel = null
@export var SkillPanel_Node: Panel = null
@export var InstructionIcon_Node: TextureRect = null
@export var SkillIcon_Node: TextureRect = null
@export var Crossout_Node: Line2D = null

var unit_ref: Unit = null
var skill_ref: SkillBase = null

const loud_icon: Texture = preload("res://sprites/Icons/Atlas/loud.tres")

func _ready() -> void:
	unit_ref = $"../.."
	SkillPanel_Node.visible = false
	InstructionPanel_Node.visible = false
	ActionBar_Node.max_value = 10
	ActionBar_Node.value = 10
	SetHealth(unit_ref.hp)
	

func _physics_process(_delta: float) -> void:
	if is_instance_valid(skill_ref):
		if not skill_ref.instruction_list.is_empty():
			SetActionProgress(skill_ref.instruction_list[0].timer)
		else:
			SetActionProgress(unit_ref.overhead_downtime)
	else: SetActionProgress(unit_ref.overhead_downtime)

func SetHealth(hp: int) -> void:
	var hp_max: int = unit_ref.hp_max
	HealthBar_Node.max_value = hp_max
	HealthBar_Node.value = hp

func SetSkill(skill: SkillBase) -> void:
	skill_ref = skill
	
	var heard: bool = unit_ref.Client_CanIHearYou()
	var skill_is_valid: bool = is_instance_valid(skill)
	
	ActionBar_Node.indeterminate = !heard and skill_is_valid
	
	if skill_is_valid:
		SkillPanel_Node.visible = true
		if heard: SkillIcon_Node.texture = skill.skillConfig_ref.icon
		else: SkillIcon_Node.texture = loud_icon
		Crossout_Node.visible = !heard
		
		ActionBar_Node.max_value = skill.instruction_list[0].timer
		ActionBar_Node.value = skill.instruction_list[0].timer
	else:
		SkillPanel_Node.visible = false
		SkillIcon_Node.texture = null
		ActionBar_Node.max_value = 10
		ActionBar_Node.value = 10

## Currently unused
func SetInstruction(ins: SkillInstruction) -> void:
	#var fold: float = ActionBar_Node.max_value
	#var progress: float = minf(float(ins.timer) / fold, 1.0)
	#progress = 1.0 - progress
	SetActionProgress(ins.timer)

func SetActionProgress(timer: int) -> void:
	var fold: float = ActionBar_Node.max_value
	if timer > fold:
		ActionBar_Node.max_value = timer
		fold = timer
	ActionBar_Node.value = fold - timer
