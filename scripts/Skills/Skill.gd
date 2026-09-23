class_name Skill extends Node

@export var stats: SkillStats = null
@export var act_progress: float = 0
@export var act_step: int = 0

var unit_ref: Unit = null
var standin_ref: Standin = null

## Visual Process
func ProcessVisCharge(delta: float) -> void: pass
## Physics Process
func ProcessPhys(delta: float) -> void: pass

## Triggered when skill charge reaches 0.
func OnCancel() -> void: pass

## Override, then use super() as needed
func HandleCharge(m1: bool, delta: float) -> void:
	var cancellable: bool = stats.cancellable \
	and not stats.enactment_type == SkillStats.ENACTMENT.scripted
	unit_ref.skill_backwards = not m1 and cancellable
	
	if true: # TODO skill charge blockers
		var rate: float = stats.charge_rate if not unit_ref.skill_backwards else stats.cancel_rate
		rate = delta / rate
		if unit_ref.skill_backwards: rate *= -1
		unit_ref.skill_charge = clampf(unit_ref.skill_charge + rate, 0.0, 1.0)

## Trigger on individual skills
func HandleCharge_After(m1: bool, delta: float) -> void:
	if unit_ref.skill_acting: return
	if unit_ref.skill_backwards and unit_ref.skill_charge == 0:
		OnCancel()
		unit_ref.skill_using = false
