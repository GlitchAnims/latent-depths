class_name HexMath

static func cube_to_axial(cube) -> Vector2i:
	var q = cube.q
	var r = cube.r
	return Vector2i(q, r)

static func axial_to_cube(hex) -> Vector3i:
	var q = hex.q
	var r = hex.r
	var s = -q-r
	return Vector3i(q, r, s)

static func hex_to_pixel(hex: Vector2i) -> Vector2:
	var x = (     3./2 * hex.x                    )
	var y = (sqrt(3)/2 * hex.x  +  sqrt(3) * hex.y)
	# scale cartesian coordinates
	x = x * hex_size
	y = y * hex_size
	return Vector2(x, y)

static func CoordVecLength(coord_vec: Vector2i) -> int:
	var dist: int = (abs(coord_vec.x)
	+ abs(coord_vec.x + coord_vec.y)
	+ abs(coord_vec.y)) / 2
	return dist

const axial_direction_vectors = [
	Vector2i(+1, 0), Vector2i(+1, -1), Vector2i(0, -1), 
	Vector2i(-1, 0), Vector2i(-1, +1), Vector2i(0, +1), 
]

enum AXIAL_DIR{
	X_PLUS, Z_PLUS, Y_MINUS,
	X_MINUS, Z_MINUS, Y_PLUS
}

const MASK32: int = 0xFFFFFFFF
const SIGN32: int = 0x80000000
const TWO_POW_32: int = 0x100000000

static func Pack_Vector2i_to_Int64(vec: Vector2i) -> int:
	return Pack_Int32_to_Int64(vec.x,vec.y)

static func Unpack_Int64_to_Vector2i(packed: int) -> Vector2i:
	return Vector2i(Unpack_Int64_Low(packed),Unpack_Int64_High(packed))

static func Pack_Int32_to_Int64(low: int, high: int) -> int:
	return ((high & MASK32) << 32) | (low & MASK32)

static func Unpack_Int64_Low(packed: int) -> int:
	var v := packed & MASK32
	return v - TWO_POW_32 if (v & SIGN32) else v

static func Unpack_Int64_High(packed: int) -> int:
	var v := (packed >> 32) & MASK32
	return v - TWO_POW_32 if (v & SIGN32) else v

const hex_angle_rot: float = PI / 3

const hex_size: float = 0.5

const hex_width: float = hex_size * 2
const hex_height: float = sqrt(3) * hex_size

const hex_dist_hor: float = hex_width * 0.75
const hex_dist_ver: float = hex_height


static func MakeHexMesh() -> ArrayMesh:
	var verts: PackedVector3Array = []
	var uvs: PackedVector2Array = []
	var normals: PackedVector3Array = []
	var indices: PackedInt32Array = []
	
	for i in 6:
		var cur_rot: float = hex_angle_rot * i
		var corner_vec: Vector3 = Vector3(hex_size,0,0)
		corner_vec = corner_vec.rotated(Vector3.UP,cur_rot)
		
		verts.push_back(corner_vec)
		# TODO Funny triangel
		uvs.push_back(Vector2(corner_vec.x / 2 + 0.5,corner_vec.z / 2 + 0.5))
		normals.push_back(Vector3.BACK)
	
	indices.push_back(0)
	indices.push_back(2)
	indices.push_back(1)
	indices.push_back(0)
	indices.push_back(3)
	indices.push_back(2)
	
	indices.push_back(3)
	indices.push_back(5)
	indices.push_back(4)
	indices.push_back(3)
	indices.push_back(0)
	indices.push_back(5)
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	var hexmesh: ArrayMesh = ArrayMesh.new()
	hexmesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	ResourceSaver.save(hexmesh, "res://meshes/Hexagonal/hexmesh.tres", ResourceSaver.FLAG_COMPRESS)
	return hexmesh

static func MakeHexRingMesh() -> ArrayMesh:
	var verts: PackedVector3Array = []
	var uvs: PackedVector2Array = []
	var normals: PackedVector3Array = []
	var indices: PackedInt32Array = []
	
	for i in 6:
		var cur_rot: float = hex_angle_rot * i
		var corner_vec: Vector3 = Vector3(hex_size,0,0)
		corner_vec = corner_vec.rotated(Vector3.DOWN,cur_rot)
		
		var corner_small_vec: Vector3 = corner_vec*0.95
		verts.push_back(corner_vec)
		verts.push_back(corner_small_vec)
		# TODO Funny triangel
		uvs.push_back(Vector2(corner_vec.x / 2 + 0.5,corner_vec.z / 2 + 0.5))
		uvs.push_back(Vector2(corner_small_vec.x / 2 + 0.5,corner_small_vec.z / 2 + 0.5))
		normals.push_back(Vector3.BACK)
		normals.push_back(Vector3.BACK)
		
		if i >= 1:
			var tring_idx: int = (i-1) * 2
			indices.push_back(tring_idx)
			indices.push_back(tring_idx+3)
			indices.push_back(tring_idx+1)
			indices.push_back(tring_idx)
			indices.push_back(tring_idx+2)
			indices.push_back(tring_idx+3)
	
	indices.push_back(0)
	indices.push_back(11)
	indices.push_back(10)
	indices.push_back(0)
	indices.push_back(1)
	indices.push_back(11)
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices
	
	var hexmesh: ArrayMesh = ArrayMesh.new()
	hexmesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	ResourceSaver.save(hexmesh, "res://meshes/Hexagonal/hexmesh_ring.tres", ResourceSaver.FLAG_COMPRESS)
	return hexmesh
