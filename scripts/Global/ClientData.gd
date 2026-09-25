extends Node

const worldhex_scene: PackedScene = preload("res://scenes/WorldInteract/world_hex.tscn")

var thisPlayer: Player = null

var press_m1: bool = false
var hold_m1: bool = false
var press_m2: bool = false
var hold_m2: bool = false

var press_north: bool = false
var hold_north: bool = false
var press_east: bool = false
var hold_east: bool = false
var press_south: bool = false
var hold_south: bool = false
var press_west: bool = false
var hold_west: bool = false

var hold_shift: bool = false
var press_space: bool = false
var hold_space: bool = false

var mousePos: Vector2 = Vector2.ZERO
var mousePos_old: Vector2 = Vector2.ZERO
var mouseVec: Vector2 = Vector2.ZERO

signal viewportSize_changed

var viewportSize: Vector2 = Vector2(100, 100)
var viewportCenter: Vector2 = viewportSize*0.5
var viewportSizeX: float = 100.0
var viewportSizeY: float = 100.0
var viewportScale: float = 1.0
var viewportShortest: float = 1.0
var viewportLongest: float = 1.0

var pauseMenu: bool = false
var mouseInWorld: Vector2 = Vector2.ZERO

enum P_FLAG {
	nothing,
	north, west, south, east,
	actQ, actE, jump, crouch,
	m1, m2, shift, dunno
}

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
func _ready():
	rng.randomize()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(_delta: float) -> void:
	press_m1 = Input.is_action_just_pressed("M1") && mouse_IsOnScreen
	hold_m1 = Input.is_action_pressed("M1")
	press_m2 = Input.is_action_just_pressed("M2") && mouse_IsOnScreen
	hold_m2 = Input.is_action_pressed("M2")
	
	press_north = Input.is_action_just_pressed(&"ACT_North")
	hold_north = Input.is_action_pressed(&"ACT_North")
	press_west = Input.is_action_just_pressed(&"ACT_West")
	hold_west = Input.is_action_pressed(&"ACT_West")
	press_south = Input.is_action_just_pressed(&"ACT_South")
	hold_south = Input.is_action_pressed(&"ACT_South")
	press_east = Input.is_action_just_pressed(&"ACT_East")
	hold_east = Input.is_action_pressed(&"ACT_East")
	
	hold_shift = Input.is_action_pressed(&"ACT_Shift")
	
	press_space = Input.is_action_just_pressed(&"ACT_Space")
	hold_space = Input.is_action_pressed(&"ACT_Shift")

func _process(_delta):
	var viewportSize_new: Vector2 = Vector2(get_viewport().size)
	if not viewportSize_new.is_equal_approx(viewportSize):
		viewportSize = viewportSize_new
		viewportCenter = (viewportSize*0.5).floor()
		viewportSizeX = viewportSize.x
		viewportSizeY = viewportSize.y
		viewportShortest = minf(viewportSizeX, viewportSizeY)
		viewportLongest = maxf(viewportSizeX, viewportSizeY)
		viewportScale = viewportShortest/720.0
		viewportSize_changed.emit()
	
	mousePos_old = mousePos
	mousePos = get_viewport().get_mouse_position()
	if mouse_IsOnScreen: mouseVec = mousePos - mousePos_old
	else: mouseVec = Vector2.ZERO
	
	var thiefControl: Control = get_viewport().gui_get_hovered_control()
	mouse_IsOnGUI = is_instance_valid(thiefControl)

var mouse_IsOnGUI: bool = false
var mouse_IsOnScreen: bool = false
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_MOUSE_EXIT:
			mouse_IsOnScreen = false
		NOTIFICATION_WM_MOUSE_ENTER:
			mouse_IsOnScreen = true

var mouseEvent_relVec: Vector2 = Vector2.ZERO
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouseEvent_relVec = event.relative

var temp_skill: SkillBase = null
var temp_skillstruction_list: Array[SkillInstruction] = []

var infomercial_unit_list: Array[Unit] = []
