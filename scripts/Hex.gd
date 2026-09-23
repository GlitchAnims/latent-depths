class_name Hex extends RefCounted

@export_storage var coord: Vector2i = Vector2i.ZERO
@export_storage var tile_flags: int = TILE_FLAGS.FREE

## Useful for... Line of sight, maybe. Also terrain movement penalty.
@export_storage var elevation: int = 0

enum TILE_FLAGS{
	FREE,
	WALL,
	OBJECTIVE,
	ENVIRONMENT,
}
