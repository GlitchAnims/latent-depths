class_name HandHUD extends Control

const hudcard_scene: PackedScene = preload("res://scenes/HUD/hud_card.tscn")


#@onready var _DrawBox_Node: Panel = $"HBox1/Drawhud/DrawBox"
@onready var _DrawMeter_Node: ProgressBar = $"HBox1/Drawhud/DrawBox/DrawMeter"
@onready var _DrawText_Label: RichTextLabel = $"HBox1/Drawhud/DrawBox/DrawText"

@onready var _MaxHand_Label: RichTextLabel = $"HBox1/Drawhud/HandsizePanel/MaxHand"
@onready var _SpaceRemaining_Label: RichTextLabel = $"HBox1/Drawhud/HandsizePanel/SpaceRemaining"

@onready var CardHolder_Node: HBoxContainer = $"HBox1/Minicards"
var hudcard_dict: Dictionary[int, HUDCard] = {}

func _ready() -> void:
	GameData.HandHUD_Node = self
	for child in CardHolder_Node.get_children():
		child.queue_free()

func _process_handhud(unit: Unit) -> void:
	_DrawMeter_Node.set_value(unit.timer_draw)

func Update_EnoughLight(light: int) -> void:
	for card: HUDCard in hudcard_dict.values():
		var cost: int = card.tibia_ref.config_ref.light_cost
		card.SetVisual_EnoughLight(light >= cost)

func UpdateHandVisual(unit: Unit) -> void:
	var cardset: Dictionary[int, Vector2i] = {}
	
	for id in unit.pile_hand:
		var dualcount: Vector2i = Vector2i.ZERO
		if cardset.has(id): dualcount = cardset[id]
		dualcount.x += 1
		cardset[id] = dualcount
	
	for id in unit.pile_discard:
		var dualcount: Vector2i = Vector2i.ZERO
		if cardset.has(id): dualcount = cardset[id]
		dualcount.y += 1
		cardset[id] = dualcount
	
	var destroy_list: Array[int] = []
	for id in cardset:
		var dualcount: Vector2i = cardset[id]
		var inhand: int = dualcount.x
		var indiscard: int = dualcount.y
		
		var hudcard: HUDCard = hudcard_dict.get(id, null)
		if is_instance_valid(hudcard):
			if inhand < 1 and indiscard < 1: destroy_list.push_back(id)
			else: hudcard.SetCounts(inhand, indiscard)
		else:
			hudcard = hudcard_scene.instantiate()
			hudcard.tibia_ref = GameData.tibialist_cards[id]
			CardHolder_Node.add_child(hudcard)
			hudcard_dict[id] = hudcard
			hudcard.SetCounts(inhand, indiscard)
	
	for id in destroy_list:
		hudcard_dict[id].queue_free()
		hudcard_dict.erase(id)
	
	var cardcount: int = unit.pile_hand.size()
	var maxhand: int = unit.config_ref.default_hand_max
	_MaxHand_Label.set_text(str(maxhand))
	_SpaceRemaining_Label.set_text(str(maxhand-cardcount))
	
	if cardcount >= maxhand: _DrawText_Label.set_text(tr("HAND_FULL"))
	else: _DrawText_Label.set_text(tr("HAND_NOT_FULL_DRAWING"))

## Returns -1 if invalid.
func TryGetCardTibiaIDByVisualHandIndex(hand_index: int) -> int:
	var hand_size: int = CardHolder_Node.get_child_count()
	if hand_index >= hand_size: return -1
	var hudcard: HUDCard = CardHolder_Node.get_child(hand_index) as HUDCard
	var tib_ID: int = hudcard.tibia_ref.tibia_id
	return tib_ID
