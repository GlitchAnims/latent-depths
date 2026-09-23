class_name CardConfig extends Resource

## Format this as follows:[br]"mod_unit_card" = "og_firefist_fuel"[br]
##Utilizing the same identifier as another card will overwrite it.
@export var identifier: StringName = &""
## Card Name
@export var card_name: StringName = &""
## Description
@export var card_desc: StringName = &""
## If Generic, it's intended to be added to other units' decks mid-combat via special effects.
@export var is_generic: bool = false
## Optional Card Script
@export var optional_card_script: GDScript
## Light Cost
@export_range(0, 15) var light_cost: int = 0
## Color
@export_color_no_alpha var color: Color = Color.BLUE_VIOLET
