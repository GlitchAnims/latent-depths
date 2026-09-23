class_name SkillButton extends Control

@onready var icon_node: TextureRect = $Icon

var skillRack_ref: SkillRack = null
var skill_ref: SkillBase = null

func SetIcon(newImage:Texture) -> void:
	icon_node.texture = newImage
	


func _MouseEnter_Button() -> void:
	skillRack_ref.MouseCheckSkillButton(self, true)


func _MouseExit_Button() -> void:
	skillRack_ref.MouseCheckSkillButton(self, false)


func _ButtonSelectSkill() -> void:
	ClientData.temp_skill = skill_ref
