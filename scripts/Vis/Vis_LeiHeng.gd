extends Vis

@export var Showcase_Node: AnimatedSprite3D = null

@export var FiringParticles_Node: GPUParticles3D = null
@export var BoomParticles_Node: GPUParticles3D = null

func Incantate(incantation: Incantation, delta: float) -> void:
	if incantation.incantation_ID == 1:
		#var inc: Incantation.Standard_Walk = incantation as Incantation.Standard_Walk
		Vis_Anim_Node.play(&"tanglecleaver_prep")
		cur_inc = incantation
		ClientData.stealcamera_timer = 0.7
		var globpos: Vector3 = global_position
		ClientData.stealcamera_pos = globpos + Vector3(0,1.5,3)
		ClientData.stealcamera_aim = globpos + Vector3(0,0.5,0)
	
	
	if incantation is Incantation.Standard_MultiTarget:
		var inc: Incantation.Standard_MultiTarget = incantation as Incantation.Standard_MultiTarget
		cur_inc = incantation
		var unit_count: int = inc.unit_list.size()
		
		var prog: float = inc.anim_progress
		prog += delta
		inc.anim_progress = prog
		
		if unit_count > 0:
			var inc_step: int = inc.step
			match inc_step:
				0:
					Vis_Anim_Node.play(&"tanglecleaver_firing")
					inc.step += 1
				2:
					for i in unit_count:
						var unit: Unit = inc.unit_list[i]
						ClientData.stealcamera_shake = 1.0
						unit.Vis_InflictShake()
						unit.Vis_TakeDamage(inc.dmg_list[i])
						unit.Vis_RefreshHP()
					inc.step += 1
		
		var globpos: Vector3 = unit_ref.global_position
		ClientData.stealcamera_timer = 0.7
		ClientData.stealcamera_pos = globpos + steal_vec
		ClientData.stealcamera_aim = globpos + Vector3(0,0.5,0)
		
		#if prog >= 4.0:
			#ClientData.incantation_list.erase(incantation)
			#for unit: Unit in inc.unit_list:
				#unit.Vis_RefreshHP()

var steal_vec: Vector3 = Vector3(0,1.5,3)

var cur_inc: Incantation = null

func ShakeCam(strength: float) -> void:
	ClientData.stealcamera_shake = strength
func StealCamVec(vec3: Vector3) -> void:
	steal_vec = vec3

func CurIncStep() -> void:
	if cur_inc != null: cur_inc.step += 1


func _on_anim_animation_finished(anim_name: StringName) -> void:
	if cur_inc != null:
		ClientData.incantation_list.erase(cur_inc)
		cur_inc = null
	
	if anim_name == &"tanglecleaver_prep":
		Vis_Anim_Node.play(&"tanglecleaver_prep_continuous")
	elif anim_name == &"tanglecleaver_firing":
		Vis_Anim_Node.play(&"RESET")
