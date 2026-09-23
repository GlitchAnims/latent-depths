class_name SkillRack extends VBoxContainer

const skillbutton_scene: PackedScene = preload("res://scenes/HUD/skill_button.tscn")

func _ClearSkillButtons() -> void:
	for child in get_children():
		child.queue_free()

func _PopulateSkillButtons(unit: Unit) -> void:
	for skill in unit.skill_list:
		var config: SkillConfig = skill.skillConfig_ref
		var skillButton: SkillButton = skillbutton_scene.instantiate()
		add_child(skillButton)
		skillButton.SetIcon(config.icon)

func UpdateSkillRack(unit: Unit) -> void:
	_ClearSkillButtons()
	if is_instance_valid(unit):
		_PopulateSkillButtons(unit)
