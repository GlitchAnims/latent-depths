extends Skill

func ProcessVisCharge(delta: float) -> void:
	var unit: BugAntlers = unit_ref as BugAntlers
	var standin: BugAntlersStandin = standin_ref as BugAntlersStandin


func ProcessPhys(delta: float) -> void:
	var unit: BugAntlers = unit_ref as BugAntlers
	pass

func Complete() -> void:
	unit_ref.skill_acting = false
	unit_ref.skill_charge = 0

func OnCancel() -> void:
	act_progress = 0
	act_step = 0

func HandleCharge(m1: bool, delta: float) -> void:
	if not unit_ref.skill_acting:
		#something else
		super(m1, delta)
	
	HandleCharge_After(m1, delta)
