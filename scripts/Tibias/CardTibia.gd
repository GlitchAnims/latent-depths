class_name CardTibia extends Tibia

var config_ref: CardConfig = null

func _init(config: CardConfig, idx: int):
	config_ref = config
	tibia_id = idx
