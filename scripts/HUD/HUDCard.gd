class_name HUDCard extends PanelContainer

var tibia_ref: CardTibia = null
#@onready var _DecoPanel_Node: Panel = $"DecoPanel"
@onready var _CrossoutBG_Node: Line2D = $"DecoPanel/LightCost/CrossoutBG"
@onready var _Crossout_Node: Line2D = $"DecoPanel/LightCost/Crossout"
@onready var _CardName_Node: RichTextLabel = $"DecoPanel/CardName"
@onready var _LightCost_Node: RichTextLabel = $"DecoPanel/LightCost"
@onready var _CountInHand_Node: RichTextLabel = $"DecoPanel/CountInHand"
@onready var _CountInDiscard_Node: RichTextLabel = $"DecoPanel/CountInDiscard"

var cardcolor: Color = Color.WHITE

func _ready() -> void:
	if not is_instance_valid(tibia_ref): return
	_LightCost_Node.set_text(str(tibia_ref.config_ref.light_cost))
	_CardName_Node.set_text(tr(tibia_ref.config_ref.card_name)) # NO_TRANSLATE
	cardcolor = tibia_ref.config_ref.color
	self_modulate = cardcolor

var inhand_count: int = -1
var indiscard_count: int = -1

func SetCounts(inhand: int, indiscard: int) -> void:
	if inhand != inhand_count:
		if inhand > inhand_count and inhand > 0: PlayIncreaseAnim(inhand_count, inhand)
		elif inhand < inhand_count: PlayDecreaseAnim(inhand_count, inhand)
		inhand_count = inhand
		if inhand_count < 1: self_modulate = cardcolor * 0.6
		else: self_modulate = cardcolor
		_CountInHand_Node.set_text(str(inhand))
	if indiscard != indiscard_count:
		indiscard_count = indiscard
		_CountInDiscard_Node.set_text(str(indiscard))

func SetVisual_EnoughLight(has_enough: bool) -> void:
	_CrossoutBG_Node.visible = !has_enough
	_Crossout_Node.visible = !has_enough

const shinesweep_scene: PackedScene = preload("res://scenes/HUD/card_shine_sweep.tscn")
func PlayIncreaseAnim(_count_prev: int, _count_now: int) -> void:
	var newnode: CardShineSweep = shinesweep_scene.instantiate()
	newnode.mode = 0
	add_child(newnode)
func PlayDecreaseAnim(_count_prev: int, _count_now: int) -> void:
	var newnode: CardShineSweep = shinesweep_scene.instantiate()
	newnode.mode = 1
	add_child(newnode)
