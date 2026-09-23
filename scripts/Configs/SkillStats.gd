class_name SkillStats extends Resource

@export var enactment_type: ENACTMENT = ENACTMENT.normal
@export var cancellable: bool = true

## Seconds for 100% activation.[br]0.0 = instant.
@export_range(0.0, 30.0, 0.1) var charge_rate: float = 1.0
## Seconds for deactivation. Skill remains "in use" until Skill Charge reaches 0%.[br]0.0 = instant.
@export_range(0.0, 5.0, 0.1) var cancel_rate: float = 1.0

enum ENACTMENT{
	## Charge, release to activate.
	normal,
	## Like normal, but auto-activates when full.
	looping,
	## Instant activation (always uncancellable).
	scripted,
	## Hold for continued activation.
	continued,
	## Same as continued, but increases in intensity.
	rampup,
	## Hold until full, continued activation once full.
	windup
}
