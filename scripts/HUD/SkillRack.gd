class_name SkillRack extends VBoxContainer

const skillbutton_scene: PackedScene = preload("res://scenes/HUD/skill_button.tscn")

func _ready() -> void:
	_ClearSkillButtons()

func _ClearSkillButtons() -> void:
	for child in get_children():
		child.queue_free()

func _PopulateSkillButtons(unit: Unit) -> void:
	for skill in unit.skill_list:
		var config: SkillConfig = skill.skillConfig_ref
		if config.has_alt_skill and config.is_alt_skill != alt_skills_enabled: continue
		var skillButton: SkillButton = skillbutton_scene.instantiate()
		skillButton.skillRack_ref = self
		skillButton.skill_ref = skill
		add_child(skillButton)
		skillButton.SetIcon(config.icon)
		

func MouseCheckSkillButton(skillButton: SkillButton, entered: bool) -> void:
	if entered: GameData.Encompass_Node.MakeTooltip()
	else: GameData.Encompass_Node.ClearTooltip()

func _physics_process(_delta: float) -> void:
	if not GameData.cur_actor_is_valid: return
	if ClientData.press_shift:
		UpdateSkillRack(GameData.cur_actor, not alt_skills_enabled)

var alt_skills_enabled: bool = false

func UpdateSkillRack(unit: Unit, alt_skills: bool) -> void:
	alt_skills_enabled = alt_skills
	_ClearSkillButtons()
	if is_instance_valid(unit):
		_PopulateSkillButtons(unit)
