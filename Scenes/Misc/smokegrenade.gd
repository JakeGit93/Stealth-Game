class_name SmokeGrenade extends Node3D

@export var grid : Volume3D


func _ready() -> void:
	if grid == null:
		push_error("Grid resource is required!")
		set_process(false)
		return

func _process(delta: float) -> void:
	var tween = get_tree().create_tween()
	#tween.tween_method(expand_nade.bind()) #finish this off!

func expand_nade(voxel_array : Array[Vector3i], radius : int, pos : Vector3) -> Array[Vector3i]:
	var smoke_array : Array[Vector3i] = []
	for i in range(voxel_array.size()):
		var vox = grid.voxelspace_to_worldspace(voxel_array[i])
		var dist = vox - pos
		if dist.length_squared() <= radius * radius:
			smoke_array.append(vox)
			grid.visualize_voxel(vox)

	return smoke_array

func generate_nade(pos: Vector3) -> Array[Vector3i]:
	var full_size = 100
	var diameter = full_size * 0.1
	var radius = floor(diameter * 0.5)
	var center_voxel = grid.worldspace_to_voxelspace(pos)
	print(to_global(pos))
	var bounds_voxels: Array[Vector3i] = []
	for x in range(-diameter, diameter):
		for y in range(-diameter, diameter):
			for z in range(-diameter, diameter):
					bounds_voxels.append(center_voxel + Vector3i(x,y,z))
	
	return bounds_voxels
