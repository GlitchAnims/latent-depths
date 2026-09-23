class_name Card extends Node

var tibia_ref: CardTibia = null
var cardscript_ref: CardScript = null

func _ready() -> void:
	if is_instance_valid(tibia_ref.config_ref.optional_card_script):
		var class_cardscript = load(tibia_ref.config_ref.optional_card_script.resource_path)
		var cardscript = class_cardscript.new()
		print("is? ", cardscript is CardScript)
		if cardscript is CardScript:
			cardscript_ref = cardscript

func CanPlayThis() -> bool:
	return true
