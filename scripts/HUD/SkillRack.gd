class_name SkillRack extends VBoxContainer

const skillbutton_scene: PackedScene = preload("res://scenes/HUD/skill_button.tscn")

func _ClearSkillButtons() -> void:
	for child in get_children():
		child.queue_free()

func _PopulateSkillButtons(unit: Unit) -> void:
	for skill in unit.skill_list:
		var config: SkillConfig = skill.skillConfig_ref
		var skillButton: SkillButton = skillbutton_scene.instantiate()
		skillButton.skillRack_ref = self
		add_child(skillButton)
		skillButton.SetIcon(config.icon)
		

func MouseCheckSkillButton(skillButton: SkillButton, entered: bool) -> void:
	if entered: GameData.Encompass_Node.MakeTooltip()
	else: GameData.Encompass_Node.ClearTooltip()


func UpdateSkillRack(unit: Unit) -> void:
	_ClearSkillButtons()
	if is_instance_valid(unit):
		_PopulateSkillButtons(unit)
