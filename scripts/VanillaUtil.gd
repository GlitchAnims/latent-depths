class_name VanillaUtil 


static func LoadConfigFiles(dir: DirAccess) -> void:
	var currentDir: String = dir.get_current_dir() + "/"
	var filenameList: PackedStringArray = dir.get_files()
	
	for filename in filenameList:
		if filename.ends_with(".remap"): filename = filename.replace(".remap", "")
		var config: Resource = ResourceLoader.load(currentDir + filename)
		if config is UnitConfig:
			var unitConfig: UnitConfig = config as UnitConfig
			if unitConfig.identifier.is_empty(): continue
			GameData.tibiadict_unitry[unitConfig.identifier].config_ref = unitConfig
	
	var dirnameList: PackedStringArray = dir.get_directories()
	for dirname in dirnameList:
		var subDir: DirAccess = DirAccess.open(currentDir + dirname)
		LoadConfigFiles(subDir)

const diminishing_constant: int = 25

static func GetDmgMult(attacker: Unit, victim: Unit) -> float:
	
	var atk_total_plus: int = attacker.stat_atk_plus
	var atk_total_minus: int = attacker.stat_atk_minus
	var def_total_plus: int = victim.stat_def_plus
	var def_total_minus: int = victim.stat_def_minus
	
	var atk_mult_plus: float = atk_total_plus / (abs(atk_total_plus) + diminishing_constant)
	var atk_mult_minus: float = atk_total_minus / (abs(atk_total_minus) + diminishing_constant)
	var atk_mult: float = atk_mult_plus - atk_mult_minus
	
	var def_mult_plus: float = def_total_plus / (abs(def_total_plus) + diminishing_constant)
	var def_mult_minus: float = def_total_minus / (abs(def_total_minus) + diminishing_constant)
	var def_mult: float = def_mult_plus - def_mult_minus
	
	var dmg_mult: float = atk_mult - def_mult
	
	return dmg_mult
