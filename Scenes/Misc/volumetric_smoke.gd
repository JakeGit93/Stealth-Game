# TODO

#fix all the errors with combining smokegrenade.gd into this file
#change from generating meshes per voxel to surface tool
#change the grid generation so it flood fills, and delete flood fill function
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class_name Volume3D extends Node3D

@export var grid_width := 256
@export var grid_height := 256
@export var grid_depth := 256
@export var voxel_size := 1.0
@export var curve : Curve

@onready var grid_origin := self.global_position
@onready var shared_mesh := BoxMesh.new()
@onready var shared_mat := StandardMaterial3D.new()
@onready var mesh := BoxMesh.new()
@onready var radius : float:
	set(value):
		radius = value
		expand_smoke(bounds_voxels, pos)

var smoke_tween : Tween
var bounds_voxels : Array[Vector3i]
var pos : Vector3

func _ready() -> void:
	generate_nade(Vector3(0,0,0))

	if smoke_tween:
		smoke_tween.kill()
	else:
		smoke_tween = create_tween()
		smoke_tween.set_trans(Tween.TRANS_EXPO)
		smoke_tween.set_ease(Tween.EASE_OUT)
		smoke_tween.tween_property(self, "radius", 5.0, 10.0)


func generate_grid() -> PackedByteArray:
	var grid_array := PackedByteArray()
	

	for z in grid_depth:
		for y in grid_height:
			for x in grid_width:
				var local_pos := Vector3(
					x * voxel_size,
					y * voxel_size,
					z * voxel_size
				)
				
				var world_pos := global_transform * local_pos
				var occupied : bool = voxel_intersects_geometry(world_pos)

				#creating the array of occupied values
				if occupied == true:
					grid_array.append(1)
				else:
					grid_array.append(0)
	return grid_array

func voxel_intersects_geometry(world_pos: Vector3) -> bool:
	var space_state := get_world_3d().direct_space_state
	var shape := BoxShape3D.new()
	shape.size = Vector3.ONE * voxel_size
	
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis.IDENTITY, world_pos)
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.collision_mask = 0xFFFFFFFF #maybe we don't want to set this manually just in case there are objects not on this layer

	
	var result := space_state.intersect_shape(query, 1)
	if result.size() > 0:
		return true
	else:
		return false


func worldspace_to_voxelspace(pos: Vector3):
	var object_voxel_position : Vector3i = floor((pos - grid_origin) / voxel_size) 
	return object_voxel_position

func voxelspace_to_worldspace(index: Vector3i) -> Vector3:
	var true_pos := Vector3(
		grid_origin.x + (index.x * voxel_size),
		grid_origin.y + (index.y * voxel_size),
		grid_origin.z + (index.z * voxel_size)
		)
	
	return true_pos
	
func visualize_voxel(pos: Vector3) -> void:
	var cube := MeshInstance3D.new()
	cube.mesh = shared_mesh
	cube.scale = Vector3.ONE * voxel_size * 0.99
	shared_mat.albedo_color = Color(0.5,0.5,0.5)
	cube.position = pos - grid_origin
	cube.set_material_override(shared_mat)
	add_child(cube)

func check_occupancy(index: Vector3i) -> bool:
	return true
	
func generate_nade(posi : Vector3) -> Array[Vector3i]:
	var full_size = 100
	var diameter = full_size * 0.1
	var center_voxel = worldspace_to_voxelspace(posi)

	for x in range(-diameter, diameter):
		for y in range(-diameter, diameter):
			for z in range(-diameter, diameter):
					bounds_voxels.append(center_voxel + Vector3i(x,y,z))
		
	return bounds_voxels

func expand_smoke(arr : Array[Vector3i], posi : Vector3) -> void:
	var smoke_array: Array[Vector3] = []
	for i in range(arr.size()):
		var vox = voxelspace_to_worldspace(arr[i])
		var dist = vox - posi
		if dist.length_squared() <= radius * radius:
			smoke_array.append(vox)
			visualize_voxel(vox)
			#multi.instance_count = smoke_array.size()
	
func flood_fill():
	pass

#this will cast a ray from the screen to the world so we can place the grenade
func screen_to_world():
	pass
