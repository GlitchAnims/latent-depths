class_name BufTibia extends Tibia

var config_ref: BufConfig = null

func _init(config: BufConfig, idx: int):
	config_ref = config
	tibia_id = idx
