class_name SkillInstruction extends RefCounted

var timer: int = 0
var ins_type: INS_TYPE = INS_TYPE.down
var coord_chosen_list: Array[Vector2i] = []


enum INS_TYPE{
	down,
	ability,
	walk
}
