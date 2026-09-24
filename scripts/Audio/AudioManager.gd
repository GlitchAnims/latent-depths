class_name AudioManager extends Node3D

@onready var TimelineClicker_Node: AudioStreamPlayer = $"TimelineClicker"
@onready var TimelineNewActor_Node: AudioStreamPlayer = $"TimelineNewActor"

func _ready() -> void:
	GameData.sig_actor_changed.connect(DoNewActorSound)

var clicker_timer: float = 0
func RunTimelineClick(frequency: float = 0.0) -> void:
	clicker_timer += frequency
	if clicker_timer >= 1.0:
		clicker_timer -= 1.0
		TimelineClicker_Node.play()

func DoNewActorSound() -> void:
	if is_instance_valid(GameData.current_actor):
		TimelineNewActor_Node.play()
