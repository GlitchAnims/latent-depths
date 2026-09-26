class_name SkillConfig extends Resource

@export var identifier: StringName = &"modname_skillname"

@export var icon: Texture = null
@export var name: StringName = &"hi"
@export var desc: StringName = &"this is a skill"

@export var has_alt_skill: bool = false
@export var is_alt_skill: bool = false

@export var skill_scene: PackedScene = null

func FabricateSkillstructions() -> Array[SkillInstruction]: return []
