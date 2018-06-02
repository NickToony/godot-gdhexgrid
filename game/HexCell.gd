# A hexagonal grid cell
#
# Ref: https://www.redblobgames.com/grids/hexagons/
#
# The hexes use a flat-topped orientation,
# the axial coordinates use +y => N, +x => NE,
# and offset coords have odd rows shifted up half a step.
#
# Using y instead of z makes following the reference more tricky,
# but is more consistent with Godot's Vector2 objects (which have x and y).

extends Node

# We use unit-size flat-topped hexes
const size = Vector2(1, sqrt(3)/2)
const DIR_N = Vector3(0, 1, -1)
const DIR_NE = Vector3(1, 0, -1)
const DIR_SE = Vector3(1, -1, 0)
const DIR_S = Vector3(0, -1, 1)
const DIR_SW = Vector3(-1, 0, 1)
const DIR_NW = Vector3(-1, 1, 0)


# Cube coords are definitive
# We use an array of ints because vectors are all floats,
# which can result in precision errors over time.
var cube_coords = [0, 0, 0] setget set_cube_coords, get_cube_coords
# other coord systems can be used
var axial_coords setget set_axial_coords, get_axial_coords
var offset_coords setget set_offset_coords, get_offset_coords


"""
	Handle coordinate access and conversion
"""
func axial_to_cube(val):
	# Returns the Vector3 cube coordinates for an axial Vector2
	var x = int(val.x)
	var y = int(val.y)
	return Vector3(x, y, -x - y)
	
func get_cube_coords():
	# Returns a Vector3 of the cube coordinates
	return Vector3(cube_coords[0], cube_coords[1], cube_coords[2])
	
func set_cube_coords(val):
	# Sets the position from a Vector3 or a 3-array of cube coordinates
	if typeof(val) == TYPE_VECTOR3:
		val = [int(val.x), int(val.y), int(val.z)]
	if val[0] + val[1] + val[2] != 0:
		print("WARNING: Invalid cube coordinates for hex (x+y+z!=0): ", val)
		return
	cube_coords = val
	
func get_axial_coords():
	# Returns a Vector2 of the axial coordinates
	return Vector2(cube_coords[0], cube_coords[1])
	
func set_axial_coords(val):
	# Sets position from a Vector2 of axial coordinates
	set_cube_coords(axial_to_cube(val))
	
func get_offset_coords():
	# Returns a Vector2 of the offset coordinates
	var x = cube_coords[0]
	var y = cube_coords[1]
	var off_y = y + (x - (x & 1)) / 2
	return Vector2(x, off_y)
	
func set_offset_coords(val):
	# Sets position from a Vector2 of offset coordinates
	var x = int(val.x)
	var y = int(val.y)
	var cube_y = y - (x - (x & 1)) / 2
	self.set_axial_coords(Vector2(x, cube_y))
	

"""
	Finding our neighbours
"""
func get_adjacent(dir):
	# Returns a HexCell instance for the given direction from this.
	# Intended for one of the DIR_* consts, but really any Vector2 or x+y+z==0 Vector3 will do.
	if typeof(dir) == TYPE_VECTOR2:
		dir = axial_to_cube(dir)
	var cell = get_script().new()
	cell.cube_coords = self.cube_coords + dir
	return cell
	
func get_all_adjacent():
	# Returns an array of HexCell instances representing adjacent locations
	var cells = Array()
	for coord in [DIR_N, DIR_NE, DIR_SE, DIR_S, DIR_SW, DIR_NW]:
		var cell = get_script().new()
		cell.cube_coords = self.cube_coords + coord
		cells.append(cell)
	return cells
	
func distance_to(target):
	# Returns the number of hops from this hex to another
	if typeof(target) == TYPE_VECTOR2:
		target = axial_to_cube(target)
	return (
			abs(cube_coords[0] - target.x)
			+ abs(cube_coords[1] - target.y)
			+ abs(cube_coords[2] - target.z)
			) / 2
	
