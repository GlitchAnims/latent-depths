class_name Buf extends Node
# Do not add a class_name if you extend this script unless absolutely necessary.[br]
# If you do, write it like this: class_name Buf_MyNewBuf

## Sync Var. Unique Buf ID for quickfind.
@export_storage var buf_ID: int = -1
## Sync Var. Tibia_list quickfind.
@export_storage var tibia_ref_ID: int = -1

## Sync Var.
@export_storage var stack: int = -1
## Sync Var.
@export_storage var count: int = -1

var unit_ref: Unit = null
var config_ref: BufConfig = null
var tibia_ref: BufTibia = null

func _ready() -> void:
	GameData.bufDict[buf_ID] = self
	tibia_ref = GameData.tibialist_bufs[tibia_ref_ID]
	config_ref = tibia_ref.config_ref
func _exit_tree() -> void:
	GameData.bufDict.erase(buf_ID)

func Server_ChangeStack(isSlowTick: bool, s: int = 0, c: int = 0) -> void:
	
	if isSlowTick:
		pass
		# do not delete. Use Expire.

## Called on unit status update. Override this.
func FullSecond() -> void: pass
## Called on unit status update. Override this.
func HalfSecond() -> void: pass

## Called on unit status update. Override this.
func ModifyUnitStats() -> void: pass
