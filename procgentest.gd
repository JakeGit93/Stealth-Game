extends MeshInstance3D

#need to implement everything and then merge with volumetric_smoke.gd once finished

func _ready() -> void:
	pass

func _generate_shells() -> Dictionary:
	var dict = []
	return dict

func intersects_geometry(pos: Vector3) -> bool:
	var space_state := get_world_3d().direct_space_state
	var shape := BoxShape3D.new()
	shape.size = Vector3.ONE

	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis.IDENTITY, pos)
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var result := space_state.intersect_shape(query, 1)

	if result.size() != 0:
		return false
	else:
		return true
