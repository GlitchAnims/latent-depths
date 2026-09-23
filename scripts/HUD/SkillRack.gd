class_name SkillRack extends VBoxContainer

const skillbutton_scene: PackedScene = preload("res://scenes/HUD/skill_button.tscn")

func RefreshSkillButtonList() -> void:
	for child in get_children():
		child.queue_free()
	for skill in GameData.currentActionableUnit.skill_list:
		var config: SkillConfig = skill.skillConfig_ref
		var skillButton: SkillButton = skillbutton_scene.instantiate()
		add_child(skillButton)
		skillButton.SetIcon(config.icon)
		
		
		
func _ready() -> void:
	#GameData.currentActionableUnit
	#RefreshSkillButtonList()

	
	
	
	return
