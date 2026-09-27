class_name PopupsManager extends Node3D

var popup_dmg_curidx: int = 0
var popup_dmg_list: Array[PopupDmg] = []
const popup_dmg_scene: PackedScene = preload("res://scenes/Vis/popup_dmg.tscn")

func _ready() -> void:
	
	for i in 10:
		var new_popup_dmg: PopupDmg = popup_dmg_scene.instantiate()
		popup_dmg_list.push_back(new_popup_dmg)
		add_child(new_popup_dmg)

func CreateDmgPopup(victim: Unit, dmg: int) -> void:
	var popup_dmg: PopupDmg = popup_dmg_list[popup_dmg_curidx]
	popup_dmg_curidx = (popup_dmg_curidx + 1) % popup_dmg_list.size()
	
	var pos: Vector3 = victim.position + Vector3(0,2,0)
	pos += Vector3.ONE * (0.5-randf())
	popup_dmg.BeginFloaty(pos, dmg)
