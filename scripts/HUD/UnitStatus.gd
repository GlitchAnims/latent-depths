class_name UnitStatus extends PanelContainer

var unit_ref: Unit = null

@onready var HealthBar_Node: ProgressBar = $"VBox1/HealthPanel/HealthBar"
@onready var SanityBar_Node: ProgressBar = $"VBox1/SanityBar"
@onready var Energy1Bar_Node: ProgressBar = $"VBox1/Energy1Bar"
@onready var Energy2Bar_Node: ProgressBar = $"VBox1/Energy2Bar"

func Setup(unit: Unit) -> void:
	unit_ref = unit
	
	HealthBar_Node.set_max(unit_ref.hp_max)
	HealthBar_Node.set_value(unit_ref.hp)
	
	
	if unit_ref.sanity_enabled:
		SanityBar_Node.set_visible(true)
		SanityBar_Node.set_value(unit_ref.sanity)
	
	if unit_ref.energy1_enabled:
		Energy1Bar_Node.set_visible(true)
		Energy1Bar_Node.set_value(unit_ref.energy1)
	
	if unit_ref.energy2_enabled:
		Energy2Bar_Node.set_visible(true)
		Energy2Bar_Node.set_value(unit_ref.energy2)
	
