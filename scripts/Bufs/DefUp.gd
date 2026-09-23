extends Buf


func FullSecond() -> void:
	stack = floori(stack * 0.9)

func ModifyUnitStats() -> void:
	unit_ref.stat_def_plus += stack
