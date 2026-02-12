#TODO:
#add setters/getters for the radius property so we can access them with the tween to expand the smoke radius
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class_name SmokeGrenade extends Node3D

@export var grid : Volume3D
@onready var radius : float:
	set(value):
		pass
		#expand_smoke()



func _ready() -> void:
	if grid == null:
		push_error("Grid resource is required!")
		set_process(false)
		return

	generate_nade(Vector3(5,0,5))
	var smoke_tween = create_tween().tween_property(self, "radius", 5.0, 10.0)

func _process(delta: float) -> void:
	pass

	

func generate_nade(pos : Vector3) -> Array[Vector3i]:
	var full_size = 100
	var diameter = full_size * 0.1
	var center_voxel = grid.worldspace_to_voxelspace(pos)

	var bounds_voxels: Array[Vector3i] = []
	for x in range(-diameter, diameter):
		for y in range(-diameter, diameter):
			for z in range(-diameter, diameter):
					bounds_voxels.append(center_voxel + Vector3i(x,y,z))
		
	return bounds_voxels

func expand_smoke(arr : Array[Vector3i], pos : Vector3) -> void:
	var smoke_array: Array[Vector3] = []
	for i in range(arr.size()):
		var vox = grid.voxelspace_to_worldspace(arr[i])
		var dist = vox - pos
		if dist.length_squared() <= radius * radius:
			smoke_array.append(vox)
			grid.visualize_voxel(vox)
	
