class_name LeiHeng extends Unit

func _ready() -> void:
	super()
	if GameData.isServer:
		Server_AddSkillToList(&"og_tanglecleaver")

func SelectSkill(skill: SkillBase) -> void:
	super(skill)

func Incantate(incantation: Incantation, delta: float) -> void:
	Vis_Node.Incantate(incantation, delta)
