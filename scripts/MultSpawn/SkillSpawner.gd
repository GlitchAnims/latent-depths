class_name SkillSpawner extends MultiplayerSpawner

func _init() -> void:
	for config: SkillConfig in GameData.skillConfig_dict.values():
		add_spawnable_scene(config.skill_scene.resource_path)
