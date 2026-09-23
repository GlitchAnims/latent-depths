class_name SkillButton extends Control

@onready var icon_node: TextureRect = $Icon

func SetIcon(newImage:Texture) -> void:
	icon_node.texture = newImage
	
