class_name LeiHeng extends Unit

func SelectSkill(skill: SkillBase) -> void:
	super(skill)
	
	var incantation_new: Incantation.Standard_Walk = Incantation.Standard_Walk.new(self)
	incantation_new.incantation_ID = 1
	incantation_new.visual_walk_pos_list = [Vector2i.ZERO]
	ClientData.incantation_list.push_back(incantation_new)

func Incantate(incantation: Incantation, delta: float) -> void:
	var inc: Incantation.Standard_Walk = incantation as Incantation.Standard_Walk
	Vis_Node.Incantate(inc, delta)
