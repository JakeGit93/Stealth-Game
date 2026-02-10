# TODO

#In generate_nade(), diameter values below a certain point break the sphere generation
#Voxel size below 1.0 also breaks sphere generation
#Need to read from vxl file correctly for occupancy values
#Shouldn't need to generate grid every time, should be able to infer positions from grid origin and grid dimensions
#Need to move generate_nade() into its own file so it can be a node that retrieves voxel grid data from volume node in the scene tree
#Need to add floodfill propagation for smoke shape, will do this in the grenade file 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class_name Volume3D extends Node3D

@export var grid_width := 256
@export var grid_height := 256
@export var grid_depth := 256
@export var voxel_size := 1.0
@export var debug := false
@export var test_object : Node3D

@onready var grid_origin := self.global_position
@onready var shared_mesh := BoxMesh.new()
@onready var shared_mat := StandardMaterial3D.new()
@onready var is_grenade := false

func _ready():
	var grid := generate_grid()
	write_grid_to_file(grid)


	#read_file("res://Assets/Volumes/TestVolume.vxl")

func _physics_process(_delta: float) -> void:
	if is_grenade == false:
		generate_nade(Vector3(0,0,0))
		is_grenade = true
	
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

				#debug visuals
				if occupied && debug == true:
					visualize_occupied(local_pos)

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

func write_header(file: FileAccess) -> void:
	#this header is **not** for storing any chunk data or occupancy values!
	file.seek(0)

	# Magic
	file.store_pascal_string("vxl")       

	# Version
	file.store_8(1)

	# Voxel size
	file.store_float(voxel_size)

	# Grid origin (world-space)
	file.store_float(grid_origin.x)
	file.store_float(grid_origin.y)
	file.store_float(grid_origin.z)

	# Grid dimensions (total grid size)
	file.store_32(grid_width)
	file.store_32(grid_height)
	file.store_32(grid_depth)

func write_grid_to_file(grid: PackedByteArray) -> void:
	var path := "res://Assets/Volumes/TestVolume.vxl"

	var file := FileAccess.open(path, FileAccess.WRITE_READ)
	write_header(file)
	file.store_buffer(grid)
	file.close()

func read_file(path: String):
	var file := FileAccess.open(path, FileAccess.READ)
	var file_type := file.get_pascal_string()
	var grid_data: PackedByteArray

	print("read file has started")

	if file_type != "vxl":
		assert(file_type == "vxl", "file type incorrect")
		return null
	else:
		print("vxl")

		var version := file.get_8()
		print("version: ", version)

		var voxel_size_temp := file.get_float()
		print("voxel size: ", voxel_size_temp)

		var grid_origin_x := file.get_float()
		print("grid origin x: ", grid_origin_x)

		var grid_origin_y := file.get_float()
		print("grid origin y: ", grid_origin_y)

		var grid_origin_z := file.get_float()
		print("grid origin z: ", grid_origin_z)

		var grid_size_x_temp := file.get_32()
		print("grid size x: ", grid_size_x_temp)

		var grid_size_y_temp := file.get_32()
		print("grid size y: ", grid_size_y_temp)

		var grid_size_z_temp := file.get_32()
		print("grid size z: ", grid_size_z_temp)

		#the data after the header gets returned as a packedbytearray
		var remaining_data := file.get_length() - file.get_position()
		grid_data = file.get_buffer(remaining_data)
		return grid_data

func worldspace_to_voxelspace(pos: Vector3):
	if pos.x < grid_origin.x or pos.y < grid_origin.y or pos.z < grid_origin.z:
		push_error("Position outside voxel grid: ", pos)
	else:
		var object_voxel_position : Vector3i = floor((pos - grid_origin) / voxel_size) 
		return object_voxel_position

func voxelspace_to_worldspace(index: Vector3i) -> Vector3:
	var true_pos := Vector3(
		grid_origin.x + (index.x * voxel_size),
		grid_origin.y + (index.y * voxel_size),
		grid_origin.z + (index.z * voxel_size)
		)

	return true_pos

func visualize_occupied(pos: Vector3) -> void:
	var shared_cube := MeshInstance3D.new()
	shared_cube.mesh = shared_mesh
	var mat := StandardMaterial3D.new()
	shared_cube.scale = Vector3.ONE * voxel_size * 0.99
	mat.albedo_color = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1),1.0)
	shared_cube.position = pos
	shared_cube.set_surface_override_material(0, mat)
	add_child(shared_cube)
					
	#wireframe visuals
	#~~~~~~~~~~~~~~
	#if use_wireframe_debug:
		#RenderingServer.set_debug_generate_wireframes(true)
		#get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	
func visualize_voxel(pos: Vector3) -> void:
	var cube := MeshInstance3D.new()
	cube.mesh = shared_mesh
	cube.scale = Vector3.ONE * voxel_size * 0.99
	shared_mat.albedo_color = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1))
	cube.position = pos
	cube.set_material_override(shared_mat)
	add_child(cube)

#some stuff still broken
func generate_nade(pos: Vector3) -> void:
	var diameter := 10.0 / voxel_size
	var radius = floor(diameter / 2)
	var center_voxel = worldspace_to_voxelspace(to_local(pos))
	var bounds_voxels: Array[Vector3i] = []
	for x in range(-radius, radius):
		for y in range(-radius, radius):
			for z in range(-radius, radius):
					bounds_voxels.append(center_voxel + Vector3i(x,y,z))

	print("number of voxels: ",bounds_voxels.size())	
	for i in range(bounds_voxels.size()):
		var vox = voxelspace_to_worldspace(bounds_voxels[i])
		var dist = vox - to_local(pos)
		if dist.length_squared() <= radius * radius:
			visualize_voxel(vox)
		
