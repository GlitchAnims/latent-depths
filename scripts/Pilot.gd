class_name Pilot extends Node

@export var pilotID: int = -1
var unit_ref: Unit = null

@export var mouse_worldPos: Vector3 = Vector3.ZERO
@export var intent: int = 0

var interval: float = 0
var fulltime: bool = false

func _ready() -> void:
	interval -= ClientData.rng.randf()
	GameData.pilotDict.set(pilotID, self)
	_ready_pilot()
func _ready_pilot() -> void: pass

var synctick: bool = false
var synced_this_tick: bool = false

func _physics_process(delta: float) -> void:
	interval += delta
	if interval >= 0.5:
		interval -= 0.5
		fulltime = not fulltime
		SlowTick(delta)
	
	_physics_process_pilot(delta)
func _physics_process_pilot(_delta: float) -> void: pass

func SlowTick(_delta: float) -> void:
	synctick = true
	ControlCheck()

func ControlCheck() -> void:
	pass
