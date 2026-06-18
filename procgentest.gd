extends Node3D

@export var energy := 16
@export var voxel_size := 1


func _ready() -> void:
	if energy >= 1:
		pass



#we will need to check 6 directions for the origin voxel, storing the non-intersecting ones
#in an array. Each voxel must reference it's neighbours.
func _generate(position: Vector3, energy: int)-> void:
	var check_left : bool
	var check_right : bool
	var check_forward : bool
	var check_back : bool
	var check_up : bool
	var check_down : bool

	var space_state := get_world_3d().direct_space_state
	var shape := BoxShape3D.new()
	shape.size = Vector3.ONE

	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis.IDENTITY, self.global_position)
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var result := space_state.intersect_shape(query, 1)

	if result.size() != 0:
		pass
	else:
		energy -= 1
		_generate()