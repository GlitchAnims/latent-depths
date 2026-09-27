class_name UnitOverheadStatus extends Control

@export var HealthBar_Node: ProgressBar = null
@export var ActionBar_Node: ProgressBar = null
@export var InstructionIcon_Node: TextureRect = null
@export var SkillIcon_Node: TextureRect = null

var unit_ref: Unit = null

func _ready() -> void:
	unit_ref = $"../.."

func SetHealth(hp: int) -> void:
	var hp_max: int = unit_ref.hp_max
	HealthBar_Node.max_value = hp_max
	HealthBar_Node.value = hp

func SetSkill(skill: SkillBase) -> void:
	if is_instance_valid(skill):
		SkillIcon_Node.texture = skill.skillConfig_ref.icon
		ActionBar_Node.max_value = skill.instruction_list[0].timer
	else:
		SkillIcon_Node.texture = null
		ActionBar_Node.max_value = 1000
		ActionBar_Node.value = 1000

func SetInstruction(ins: SkillInstruction) -> void:
	var fold: float = ActionBar_Node.max_value
	#var progress: float = minf(float(ins.timer) / fold, 1.0)
	#progress = 1.0 - progress
	ActionBar_Node.value = fold - ins.timer
