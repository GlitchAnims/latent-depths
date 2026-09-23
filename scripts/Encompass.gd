class_name Encompass extends PanelContainer

@export var SkillRack_Node: SkillRack = null

func _ready() -> void:
	ClientData.viewportSize_changed.connect(UpdateSize)
	GameData.sig_actor_changed.connect(UpdateForActor)
	UpdateSize()

func UpdateSize() -> void:
	set_begin(Vector2.ZERO)
	set_end(ClientData.viewportSize)
	
	var itemscale: Vector2 = Vector2(1,1) * minf(ClientData.viewportScale, 1.0)
	SkillRack_Node.scale = itemscale * 0.4

func UpdateForActor() -> void:
	var current_actor: Unit = GameData.current_actor
	SkillRack_Node.UpdateSkillRack(current_actor)

func _ProcessHudBar(value: int, lerpspeed: float, hudbar: HudBar, mode: int) -> void:
	if value != hudbar.goal:
		hudbar.goal = value
		hudbar.last = hudbar.cur
		hudbar.travel = 0
	
	if hudbar.cur != value:
		var diff: int = hudbar.goal - hudbar.last
		var lerp_value: float = 1 - pow(1 - hudbar.travel, 3)
		hudbar.travel = minf(hudbar.travel + lerpspeed, 1.0)
		hudbar.cur = hudbar.last + floori(float(diff) * lerp_value)
	
	var final_value: int = hudbar.cur
	var label_string: String = str(final_value)
	var label_string_first: String = label_string.left(-1)
	var label_string_last: String = label_string.right(1)
	
	match mode:
		0:
			pass
			#_HealthBar_Node.set_value(final_value)
			#_HP_Node.set_text("[font size=22]" + label_string_first + "[/font].[font size=16]" + label_string_last + "[/font]")
		1:
			pass
			#_SanityBar_Node.set_value(final_value)
			#_SP_Node.set_text("[color=bbe2e4][font size=20]" + label_string_first + "[/font].[font size=15]" + label_string_last + "[/font]")

class HudBar extends RefCounted:
	var travel: float = 0.0
	var cur: int = 0
	var last: int = 0
	var goal: int = 0
